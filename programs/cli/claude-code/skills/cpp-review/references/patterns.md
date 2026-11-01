# Pattern sketches (C++23, Linux userspace)

Minimal shapes to adapt, not libraries to paste whole. Headers assumed: `<concepts> <cstddef> <expected> <functional> <memory> <mutex> <span> <string> <string_view> <type_traits> <unistd.h> <utility> <variant> <vector>`.

## Concept at the OS seam (DIP, ISP, Strategy)

```cpp
template <typename T>
concept Clock = requires(const T& c) {
    { c.now() } -> std::same_as<std::chrono::steady_clock::time_point>;
};

template <Clock C>
class RateLimiter {
public:
    RateLimiter(const C& clock, std::chrono::milliseconds interval)
        : clock_{clock}, interval_{interval} {}
    bool allow() {
        auto now = clock_.now();
        if (now - last_ < interval_) return false;
        last_ = now;
        return true;
    }
private:
    const C& clock_;
    std::chrono::milliseconds interval_;
    std::chrono::steady_clock::time_point last_{};
};

// Production: RateLimiter<SteadyClock>. Test: RateLimiter<FakeClock>. No sleeps in tests.
```

## Deducing `this` instead of CRTP

```cpp
struct Writer {
    // Shared implementation; `self` is the derived type, no virtual, no CRTP template argument.
    void write_line(this auto& self, std::string_view s) {
        self.write(s);
        self.write("\n");
    }
};

struct FileWriter : Writer {
    void write(std::string_view s);
};
```

## Closed set: `std::variant` visitor

```cpp
template <class... Fs> struct overloaded : Fs... { using Fs::operator()...; };

struct Connect { std::string host; std::uint16_t port; };
struct Send { std::vector<std::byte> payload; };
struct Close {};

using Command = std::variant<Connect, Send, Close>;

void handle(const Command& c) {
    std::visit(overloaded{
        [](const Connect& x) { /* ... */ },
        [](const Send& x)    { /* ... */ },
        [](const Close&)     { /* ... */ },
    }, c);  // missing alternative = compile error
}
```

## Open set: owning Type Erasure (value semantics)

Non-intrusive (types only need a free `draw` function), copyable, no base class for users. Add a small buffer only if profiling shows the allocation matters.

```cpp
template <typename T>
concept Drawable = requires(const T& t) { draw(t); };

class Shape {
public:
    template <Drawable T>
        requires (!std::same_as<std::remove_cvref_t<T>, Shape>)
    Shape(T value) : pimpl_{std::make_unique<Model<T>>(std::move(value))} {}

    Shape(const Shape& other) : pimpl_{other.pimpl_->clone()} {}
    Shape& operator=(const Shape& other) { return *this = Shape{other}; }
    Shape(Shape&&) noexcept = default;
    Shape& operator=(Shape&&) noexcept = default;

    friend void draw(const Shape& s) { s.pimpl_->do_draw(); }

private:
    struct Concept {
        virtual ~Concept() = default;
        virtual void do_draw() const = 0;  // not `draw`: would hide the free function
        virtual std::unique_ptr<Concept> clone() const = 0;
    };
    template <typename T>
    struct Model final : Concept {
        explicit Model(T v) : value{std::move(v)} {}
        void do_draw() const override { draw(value); }
        std::unique_ptr<Concept> clone() const override { return std::make_unique<Model>(*this); }
        T value;
    };

    std::unique_ptr<Concept> pimpl_;
};

struct Circle { double r; };
void draw(const Circle&);
struct Square { double side; };
void draw(const Square&);

std::vector<Shape> shapes{Circle{1.0}, Square{2.0}};
// for (const auto& s : shapes) draw(s);
```

For callables, this already exists: `std::function` (copyable) and `std::move_only_function` (C++23).

## Non-owning callable: `function_ref`

Use `std::function_ref` when the project is on C++26.

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

## RAII for C handles

```cpp
// File descriptor: move-only, closes once.
class unique_fd {
public:
    unique_fd() = default;
    explicit unique_fd(int fd) noexcept : fd_{fd} {}
    unique_fd(unique_fd&& o) noexcept : fd_{std::exchange(o.fd_, -1)} {}
    unique_fd& operator=(unique_fd o) noexcept { std::swap(fd_, o.fd_); return *this; }
    ~unique_fd() { if (fd_ >= 0) ::close(fd_); }

    int get() const noexcept { return fd_; }
    int release() noexcept { return std::exchange(fd_, -1); }
    explicit operator bool() const noexcept { return fd_ >= 0; }
private:
    int fd_ = -1;
};

// Pointer handles: unique_ptr with a stateless lambda deleter (taking &std::fclose is unspecified).
using unique_file = std::unique_ptr<FILE, decltype([](FILE* f) { std::fclose(f); })>;
// unique_file f{std::fopen(path, "re")};  // "e" = O_CLOEXEC
```

## Pimpl (compile firewall, stable ABI)

```cpp
// client.hpp — no third-party headers here
class Client {
public:
    explicit Client(std::string endpoint);
    ~Client();                         // defined in .cpp, where Impl is complete
    Client(Client&&) noexcept;
    Client& operator=(Client&&) noexcept;
    std::expected<Response, ClientError> get(std::string_view path);
private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

// client.cpp
struct Client::Impl { /* libcurl handles, ... */ };
Client::Client(std::string endpoint) : impl_{std::make_unique<Impl>(std::move(endpoint))} {}
Client::~Client() = default;
Client::Client(Client&&) noexcept = default;
Client& Client::operator=(Client&&) noexcept = default;
```

## Observer with RAII subscription

```cpp
template <typename... Args>
class Signal {
public:
    using Slot = std::function<void(Args...)>;

    class Subscription {  // unsubscribes on destruction
    public:
        Subscription(Signal* s, std::size_t id) : sig_{s}, id_{id} {}
        Subscription(Subscription&& o) noexcept
            : sig_{std::exchange(o.sig_, nullptr)}, id_{o.id_} {}
        Subscription& operator=(Subscription&&) = delete;
        ~Subscription() { if (sig_) sig_->disconnect(id_); }
    private:
        Signal* sig_;
        std::size_t id_;
    };

    [[nodiscard]] Subscription connect(Slot s) {
        std::scoped_lock lock{mutex_};
        slots_.emplace_back(next_id_, std::move(s));
        return {this, next_id_++};
    }
    void emit(Args... a) {
        std::vector<std::pair<std::size_t, Slot>> copy;
        { std::scoped_lock lock{mutex_}; copy = slots_; }  // never call slots under the lock
        for (auto& [id, s] : copy) s(a...);
    }
private:
    void disconnect(std::size_t id) {
        std::scoped_lock lock{mutex_};
        std::erase_if(slots_, [id](auto& p) { return p.first == id; });
    }
    std::mutex mutex_;
    std::vector<std::pair<std::size_t, Slot>> slots_;
    std::size_t next_id_ = 0;
};
```

The signal must outlive its subscriptions. If it can't, hold a `std::weak_ptr` to shared state instead of `Signal*`. A copied slot can still run once after its subscription is destroyed; if that matters, check a liveness flag in the slot.

## Decorator

```cpp
template <typename T>
concept HttpClient = requires(T& c, std::string_view path) {
    { c.get(path) } -> std::same_as<std::expected<Response, ClientError>>;
};

template <HttpClient Inner>
class Retrying {
public:
    Retrying(Inner& inner, int attempts) : inner_{inner}, attempts_{attempts} {}
    std::expected<Response, ClientError> get(std::string_view path) {
        auto r = inner_.get(path);
        for (int i = 1; i < attempts_ && !r && is_transient(r.error()); ++i) r = inner_.get(path);
        return r;
    }
private:
    Inner& inner_;
    int attempts_;
};
```

## Composition root instead of Singletons

```cpp
int main(int argc, char** argv) {
    auto config = parse_args(argc, argv);
    if (!config) { std::println(stderr, "{}", config.error()); return 2; }

    // Every long-lived object is created here once and passed down.
    SteadyClock clock;
    Logger log{config->log_path};
    Client client{config->endpoint};
    Retrying retrying{client, 3};
    App app{retrying, clock, log};

    return app.run();
}
```

## Errors with `std::expected`

```cpp
enum class ParseError { Empty, BadNumber, OutOfRange };

std::expected<int, ParseError> parse_port(std::string_view s) {
    if (s.empty()) return std::unexpected{ParseError::Empty};
    int v{};
    auto [p, ec] = std::from_chars(s.data(), s.data() + s.size(), v);
    if (ec != std::errc{} || p != s.data() + s.size()) return std::unexpected{ParseError::BadNumber};
    if (v < 1 || v > 65535) return std::unexpected{ParseError::OutOfRange};
    return v;
}

// Caller: if (auto port = parse_port(arg)) use(*port); else report(port.error());
// For syscalls, carry errno: std::expected<unique_fd, std::error_code>,
// with std::error_code{errno, std::system_category()}.
```
