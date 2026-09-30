# Embedded-safe pattern sketches (C++23, no heap, no exceptions, no RTTI)

Minimal shapes to adapt, not libraries to paste whole. Headers assumed: `<array> <bit> <concepts> <cstddef> <cstdint> <expected> <functional> <memory> <new> <optional> <span> <type_traits> <utility> <variant>`.

## Concept at the HAL seam (DIP, ISP, Strategy)

```cpp
template <typename T>
concept Gpio = requires(T& pin, bool v) {
    pin.set(v);
    { pin.get() } -> std::same_as<bool>;
};

template <Gpio Led>
class Blinker {
public:
    explicit Blinker(Led& led) : led_{led} {}
    void tick() { led_.set(!led_.get()); }
private:
    Led& led_;
};

// Firmware: Blinker<Stm32Pin>. Host test: Blinker<FakePin>. Same logic, zero overhead.
```

## Deducing `this` instead of CRTP

```cpp
struct ByteSink {
    // Shared implementation; `self` is the derived type, no virtual, no CRTP template argument.
    void write_all(this auto& self, std::span<const std::byte> data) {
        for (auto b : data) self.write(b);
    }
};

struct Uart : ByteSink {
    void write(std::byte b);
};
```

## Closed set: `std::variant` visitor

```cpp
template <class... Fs> struct overloaded : Fs... { using Fs::operator()...; };

struct ButtonPressed { std::uint8_t id; };
struct Timeout {};
struct RxFrame { std::array<std::byte, 16> data; std::uint8_t len; };

using Event = std::variant<ButtonPressed, Timeout, RxFrame>;

void handle(const Event& e) {
    std::visit(overloaded{
        [](const ButtonPressed& b) { /* ... */ },
        [](const Timeout&)         { /* ... */ },
        [](const RxFrame& f)       { /* ... */ },
    }, e);  // missing alternative = compile error
}
```

A variant is only valueless if an emplace throws, which can't happen without exceptions. If `std::visit`'s `bad_variant_access` path shows up in the map file, switch on `e.index()` with `std::get_if`.

## Open set: Type Erasure with a fixed buffer (owning, value semantics)

Non-intrusive (types only need a free `draw` function), copyable, no heap, no virtual. The dispatch table is one `constexpr` struct per erased type.

```cpp
template <typename T>
concept Drawable = requires(const T& t) { draw(t); };

template <std::size_t Capacity = 32, std::size_t Alignment = alignof(std::max_align_t)>
class Shape {
public:
    template <Drawable T>
        requires (!std::same_as<std::remove_cvref_t<T>, Shape>)
    Shape(T value) : ops_{&ops_for<T>} {
        static_assert(sizeof(T) <= Capacity, "Shape: increase Capacity");
        static_assert(alignof(T) <= Alignment, "Shape: increase Alignment");
        std::construct_at(reinterpret_cast<T*>(buffer_), std::move(value));
    }

    Shape(const Shape& other) : ops_{other.ops_} { ops_->copy(other.buffer_, buffer_); }
    Shape& operator=(const Shape& other) {
        if (this != &other) {
            ops_->destroy(buffer_);
            ops_ = other.ops_;
            ops_->copy(other.buffer_, buffer_);
        }
        return *this;
    }
    ~Shape() { ops_->destroy(buffer_); }

    friend void draw(const Shape& s) { s.ops_->draw(s.buffer_); }

private:
    struct Ops {
        void (*draw)(const std::byte*);
        void (*copy)(const std::byte* src, std::byte* dst);
        void (*destroy)(std::byte*);
    };

    template <typename T>
    static const T& as(const std::byte* p) { return *std::launder(reinterpret_cast<const T*>(p)); }

    template <typename T>
    static constexpr Ops ops_for{
        [](const std::byte* p) { draw(as<T>(p)); },
        [](const std::byte* src, std::byte* dst) { std::construct_at(reinterpret_cast<T*>(dst), as<T>(src)); },
        [](std::byte* p) { std::destroy_at(std::launder(reinterpret_cast<T*>(p))); },
    };

    alignas(Alignment) std::byte buffer_[Capacity];
    const Ops* ops_;
};

struct Circle { float r; };
void draw(const Circle&);
struct Square { float side; };
void draw(const Square&);

std::array<Shape<>, 2> shapes{Shape<>{Circle{1.f}}, Shape<>{Square{2.f}}};
// for (const auto& s : shapes) draw(s);
```

Add operations by adding an `Ops` member and a free function. The same structure with `operator()` instead of `draw` is the **owning fixed-capacity callable** for stored callbacks (Command, timer queues). Before writing it, check whether the project already has one (`etl::inplace_function` in newer ETL, SG14 `stdext::inplace_function`).

## Non-owning callable: `function_ref`

Use `etl::delegate` instead when ETL is available.

```cpp
template <class> class function_ref;

template <class R, class... Args>
class function_ref<R(Args...)> {
public:
    template <class F>
        requires (!std::same_as<std::remove_cvref_t<F>, function_ref>
                  && std::is_invocable_r_v<R, F&, Args...>)
    function_ref(F& f) noexcept  // lvalues only: binding a temporary lambda is a compile error
        : obj_{const_cast<void*>(static_cast<const void*>(std::addressof(f)))},
          call_{[](void* o, Args... a) -> R {
              return std::invoke(*static_cast<F*>(o), std::forward<Args>(a)...);
          }} {}

    R operator()(Args... a) const { return call_(obj_, std::forward<Args>(a)...); }

private:
    void* obj_;
    R (*call_)(void*, Args...);
};
```

The callable must outlive the `function_ref`. It is two pointers, trivially copyable, one indirect call.

## Fast Pimpl (compile firewall without heap)

```cpp
// radio.hpp — no vendor headers here
class Radio {
public:
    Radio();
    ~Radio();
    Radio(const Radio&) = delete;
    Radio& operator=(const Radio&) = delete;
    std::expected<void, RadioError> send(std::span<const std::byte> frame);
private:
    struct Impl;
    Impl& impl();
    alignas(8) std::byte storage_[64];
};

// radio.cpp — vendor headers only here
struct Radio::Impl { /* vendor handles */ };

Radio::Radio() {
    static_assert(sizeof(Impl) <= sizeof(storage_), "Radio: grow storage_");
    static_assert(alignof(Impl) <= 8, "Radio: raise alignment");
    std::construct_at(reinterpret_cast<Impl*>(storage_));
}
Radio::~Radio() { std::destroy_at(&impl()); }
Radio::Impl& Radio::impl() { return *std::launder(reinterpret_cast<Impl*>(storage_)); }
```

## Fixed-capacity Observer

```cpp
template <std::size_t N, typename... Args>
class Signal {
public:
    using Slot = function_ref<void(Args...)>;  // or etl::delegate<void(Args...)>

    [[nodiscard]] bool connect(Slot s) {
        if (count_ == N) return false;
        slots_[count_++] = s;
        return true;
    }
    void emit(Args... a) const {
        for (std::size_t i = 0; i < count_; ++i) (*slots_[i])(a...);
    }
private:
    std::array<std::optional<Slot>, N> slots_{};
    std::size_t count_ = 0;
};
```

## Static Decorator

```cpp
template <Gpio Inner>
class InvertedGpio {  // active-low LED, same Gpio concept
public:
    explicit InvertedGpio(Inner& pin) : pin_{pin} {}
    void set(bool v) { pin_.set(!v); }
    bool get() { return !pin_.get(); }
private:
    Inner& pin_;
};
```

## Composition root instead of Singletons

```cpp
int main() {
    // Every long-lived object is created here once; main never returns.
    Stm32Pin led_pin{GPIOA, 5};
    InvertedGpio led{led_pin};
    Blinker blinker{led};
    Stm32Uart uart{USART2};
    App app{uart, blinker};  // dependencies passed as references

    for (;;) app.run_once();
}
```

If stack size is tight, move these objects to namespace scope in `main.cpp` (a single translation unit, so initialisation order is defined) and still pass references down.

## Errors with `std::expected`

```cpp
enum class I2cError : std::uint8_t { Nack, Timeout, BusBusy };

std::expected<std::uint8_t, I2cError> read_reg(std::uint8_t dev, std::uint8_t reg);

std::expected<float, I2cError> read_temperature() {
    return read_reg(0x48, 0x00)
        .transform([](std::uint8_t raw) { return raw * 0.5f; });
}

// Caller: if (auto t = read_temperature()) use(*t); else log(t.error());
// Never t.value(): it throws bad_expected_access.
```
