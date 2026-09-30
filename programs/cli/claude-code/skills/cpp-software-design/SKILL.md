---
name: cpp-software-design
description: Modern C++23 software design for heap-free embedded firmware, in the spirit of Klaus Iglberger's "C++ Software Design" (separation of concerns, value semantics, non-intrusive design, Type Erasure, std::variant, concepts). Use whenever writing, designing, refactoring, or reviewing C++ code, choosing between templates/concepts, std::variant, Type Erasure or virtual functions, designing callbacks, drivers, HAL layers or dependency injection, or when asked to review C++ design.
---

# C++ Software Design (embedded, C++23)

Design is about managing dependencies so code stays easy to change and test. Every recommendation here must also fit on a microcontroller: no heap, no exceptions, no RTTI.

## 1. Hard constraints

Never violate these, in code you write or code you propose:

- **No heap.** No `new`/`delete`, `malloc`, `std::make_unique`/`make_shared`, and no types that may allocate: `std::function`, `std::move_only_function`, `std::copyable_function`, `std::any`, `std::vector`, `std::string`, `std::map`, `std::list`, `std::deque`, `std::unordered_*`. Storage is static, on the stack, or a fixed-size member buffer.
- **No exceptions.** Report errors with `std::expected<T, E>` (E = small `enum class`) or `std::optional<T>`. Never call `.value()` on them (it throws); check `has_value()` / use `*`, `and_then`, `transform`, `or_else`. No `throw`, `try`, `catch`.
- **No RTTI.** No `dynamic_cast`, `typeid`, `std::type_info`.
- Heap-free standard types are fine: `std::array`, `std::span`, `std::string_view`, `std::optional`, `std::variant`, `std::expected`, `std::bitset`, `<algorithm>`, `<ranges>` views, `<bit>`, `<chrono>` durations.

## 2. Read the project first

Before recommending anything:

- **Standard:** look in `CMakeLists.txt` / build files for `CMAKE_CXX_STANDARD` or `-std=`. Assume C++23 if nothing is found; don't suggest newer features than the project uses.
- **ETL:** if `etl/` (Embedded Template Library) is on the include path or in the dependencies, prefer it for fixed-capacity containers (`etl::vector<T, N>`, `etl::string<N>`, `etl::map`) and non-owning callbacks (`etl::delegate`). Otherwise use the standard-only sketches in `references/patterns.md`. Never add ETL as a dependency without asking.
- **Existing conventions:** reuse the project's HAL wrappers, error enums and container types before introducing new ones.

## 3. Principles

SOLID, applied to concepts, templates and Type Erasure as much as to class hierarchies:

- **SRP / separation of concerns:** isolate what changes for different reasons (protocol logic vs register access vs timing). Hardware access sits behind a thin driver; logic above it is plain C++ testable on the host.
- **OCP:** add new variants without editing existing code, using the mechanism from section 4 that fits whether the set of variants is open or closed.
- **LSP:** every type that satisfies an abstraction must honour its *semantic* contract, not just compile against it. A concept checks syntax only, so document the semantics next to it (units, blocking or non-blocking, ISR-safe or not, error behaviour). A fake driver that never times out, or a `set()` that blocks where callers expect it not to, breaks LSP even though it compiles.
- **ISP:** requirements (concepts) ask only for what the user calls. A `Blinker` needs `set(bool)`, not the full GPIO API.
- **DIP:** high-level logic depends on a requirement (a concept), not on a concrete driver, and the requirement belongs to the high-level side. The HAL boundary is the canonical seam: firmware injects the real driver, host tests inject a fake.

Beyond SOLID:

- **Design for change, not for every change:** separate the aspects that are *expected* to vary (board variants, sensor models, transport). Don't add seams on speculation.
- **DRY:** one source of truth for register maps, pin assignments, protocol constants (`constexpr`, `enum class`).
- **Value semantics over reference semantics:** prefer types that behave like `int` (copyable, comparable, no shared ownership). Pointers and base-class references spread lifetime questions through the code.
- **Non-intrusive design:** don't force types to inherit from your base class to take part. Free functions and concepts let existing types (including vendor structs) fit in unchanged.

## 4. Decision guide

### Polymorphism: pick the first row that fits

| Situation | Mechanism |
|---|---|
| Behaviour fixed at compile time (almost always on firmware) | Template + **concept** (static polymorphism, zero overhead) |
| Shared implementation for derived types (old CRTP use) | **Deducing `this`** (`this auto& self`) instead of CRTP |
| Closed, known set of alternatives (events, states, message types) | **`std::variant` + `std::visit`** with an `overloaded` lambda set |
| Open set, needs runtime heterogeneity (mixed objects in one array) | **Type Erasure with fixed internal buffer** (value semantics, owning) |
| Same, but non-owning (pass-through view) | Erased reference / `function_ref`-style (two pointers) |
| Plain virtual interface | Only for a small, stable interface with runtime selection where Type Erasure isn't worth the code. Never intrusive base classes for data types. |

Adding **operations** often while types stay fixed → `std::variant` (a Visitor makes new operations cheap). Adding **types** often while operations stay fixed → Type Erasure or templates.

### Callbacks and behaviour injection (Strategy, Command)

| Situation | Use |
|---|---|
| Known at compile time | Template parameter constrained with `std::invocable<...>` |
| Passed down the stack; caller outlives it | `etl::delegate` if ETL is present, else hand-written `function_ref` |
| Registering with a C HAL (`void(*)(void*)`) | Function pointer + context, wrapped by `function_ref` |
| Stored with captured state (timer queue, command table) | Owning fixed-capacity callable: fixed-buffer Type Erasure with `static_assert(sizeof(F) <= N)`. An oversized capture must be a compile error, not an allocation. |

`std::function_ref` (C++26) standardises the non-owning case but accepts temporaries, which makes it unsafe to *store*. Use it only as a function parameter once the toolchain supports C++26.

### Other patterns

- **Singleton:** avoid. Create drivers and services once in a **composition root** (`main`, which never returns) and pass references down. Hardware that really is unique is still injected, so tests can fake it.
- **Pimpl / Bridge:** only for a compile-time firewall (vendor headers, long builds). Use **fast Pimpl** (fixed aligned buffer + `static_assert` on size), never `unique_ptr<Impl>`.
- **Observer:** fixed-capacity slot array; `connect` returns `bool` / `std::expected` when full. Observers must outlive the subject.
- **Decorator:** a template wrapper satisfying the same concept (e.g. `InvertedGpio<Inner>`), no virtual chain.
- **Adapter:** a thin type that makes a vendor/HAL API satisfy your concept; keeps vendor headers out of logic code.

## 5. Every abstraction has a price

When you introduce an abstraction (concept, variant, Type Erasure, wrapper, seam), briefly state:

- **Why it earns its place:** ≥2 real variants, a test seam, or a hardware/board boundary.
- **What it costs:** flash (template instantiations, vtables, dispatch tables), RAM (buffers, pointers), indirection in hot/ISR paths, readability.

If the case is weak, say so and offer the plain alternative. The user decides; don't silently add seams, and don't silently refuse them either.

## 6. How to work

- **Writing code:** apply this guide directly. In your reply (not in code comments) name the guideline behind each design choice in one line, e.g. "closed set of events → `std::variant`".
- **Reviewing code:** output a findings list, most severe first:

  ```
  [constraint|design|cost] file:line: problem → suggested mechanism (one line why)
  ```

  `constraint` = breaks section 1 (heap, exceptions, RTTI). `design` = a principle from section 3 or a mismatch with section 4. `cost` = an abstraction whose price in section 5 isn't justified. Close with the one or two changes that matter most.

## 7. References

Load `references/patterns.md` when you implement one of these patterns. It has embedded-safe C++23 sketches: concept-based HAL, deducing `this`, variant visitor, fixed-buffer Type Erasure, `function_ref`, fast Pimpl, fixed-capacity Observer, static Decorator, composition root, `std::expected` errors.
