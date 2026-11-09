---
name: cpp-review
description: Review C++ pull requests, branches, commits or diffs for Linux userspace applications, services and libraries, covering correctness, ownership and lifetime, exception safety, concurrency, syscall/POSIX use, security and software design (modern C++23 in the spirit of Klaus Iglberger's "C++ Software Design": SOLID, YAGNI, value semantics, concepts, std::variant, Type Erasure). Use when the user asks to review a C++ PR or C++ changes for a normal Linux machine, or says "cpp review", "c++ review", "review this C++", or invokes /cpp-review.
---

# C++ PR Review (Linux userspace)

Review C++ changes against this guide. Sections 1–5 are the design criteria; `references/review.md` holds the review workflow and the platform checks (bugs, concurrency, syscalls, security, performance).

Design is about managing dependencies so code stays easy to change and test. On a normal Linux machine the heap, exceptions and RTTI are available, but ownership must still be explicit and every resource must have exactly one owner.

## 1. Baseline rules

Flag every violation in the diff, and never propose one in a fix:

- **RAII for every resource.** Memory, file descriptors, sockets, locks, mmaps, `FILE*`, library handles: each owned by an object whose destructor releases it. No naked `new`/`delete`, `malloc`/`free`, or `close()` on a path that an early return or exception can skip. Use `std::unique_ptr` (with a custom deleter for C handles), containers, `std::lock_guard`/`std::scoped_lock`, or a small `unique_fd`.
- **Rule of zero.** Classes that hold only RAII members declare no destructor or copy/move operations. A class that does declare one declares or deletes all five, and moves are `noexcept`.
- **Ownership in the type.** `std::unique_ptr` = sole owner, `std::shared_ptr` = genuinely shared lifetime (justify it), raw pointer / reference / `std::span` / `std::string_view` = non-owning and must not outlive the owner. No `shared_ptr` "to be safe".
- **Errors follow the project's policy.** Detect it first (`-fno-exceptions`, existing `std::expected`/error-code use, or exceptions). Within it: exceptions for exceptional failures that callers can't handle locally; `std::expected<T, E>` or `std::optional<T>` for expected failures (parse errors, not-found, I/O on untrusted input). Never mix both styles for the same kind of failure. Destructors, move operations and `swap` never throw.
- **No RTTI-driven design.** `dynamic_cast`/`typeid` chains that switch on type are a missing `std::variant` or virtual function; flag them as `design`.
- **No C-style casts, no `reinterpret_cast` type punning** (use `std::bit_cast` or `memcpy`), no `const_cast` to write through.

## 2. Read the project first

Before recommending anything:

- **Agent instructions (mandatory):** read the repo's agent entry point: `AGENTS.md`, `CLAUDE.md`, or whatever file the project or user named as the jump-in point, plus any files it links to. Its rules override the defaults in this guide. Turn every coding rule in those files (naming, documentation, formatting, error policy) into a check on the diff. If none exists, say so in the review.
- **Standard and flags:** look in `CMakeLists.txt` / `meson.build` / build files for `CMAKE_CXX_STANDARD` or `-std=`, plus `-fno-exceptions`, `-fno-rtti`, warning flags and sanitizer options. Assume C++23 if nothing is found; don't suggest newer features than the project uses or than its minimum compiler supports.
- **Libraries:** reuse what is already a dependency (Boost, Abseil, fmt, spdlog, Qt, GLib, ASIO, range-v3, …) before suggesting hand-written code. Never add a dependency without asking. If the project is Qt or GLib, its ownership model (parent/child, ref counting) and event loop rules apply.
- **Existing conventions:** reuse the project's error types, logging, RAII wrappers and utility headers before introducing new ones.

## 3. Principles

SOLID, applied to concepts, templates and Type Erasure as much as to class hierarchies:

- **SRP / separation of concerns:** isolate what changes for different reasons (business logic vs I/O vs OS calls vs formatting). OS and network access sits behind a thin layer; logic above it is plain C++ testable without a filesystem, network or clock.
- **OCP:** add new variants without editing existing code, using the mechanism from section 4 that fits whether the set of variants is open or closed.
- **LSP:** every type that satisfies an abstraction must honour its *semantic* contract, not just compile against it. A concept checks syntax only, so document the semantics next to it (thread safety, blocking or not, units, which errors it reports and how). A fake that never fails, or an override that blocks where callers expect it not to, breaks LSP even though it compiles.
- **ISP:** requirements (concepts, interfaces) ask only for what the user calls. A log rotator needs `write(span)` and `flush()`, not the full file API.
- **DIP:** high-level logic depends on an abstraction it owns (a concept or a small interface), not on a concrete OS/library type. The OS boundary (filesystem, sockets, clock, process) is the canonical seam: production injects the real thing, tests inject a fake.

Beyond SOLID:

- **Design for change, not for every change:** separate the aspects that are *expected* to vary (storage backend, transport, output format). Don't add seams on speculation.
- **YAGNI:** build only what a current requirement needs. Flag speculative generality: unused parameters, template parameters or interfaces with a single implementation and no test fake, config knobs nobody sets, plugin systems for one plugin, "for later" hooks. Deleting them is the fix; add them back when the second real use arrives.
- **DRY:** one source of truth for constants, protocol definitions and configuration defaults (`constexpr`, `enum class`).
- **Value semantics over reference semantics:** prefer types that behave like `int` (copyable or movable, comparable, no shared mutable state). `shared_ptr` graphs and base-class pointers spread lifetime and thread-safety questions through the code.
- **Non-intrusive design:** don't force types to inherit from your base class to take part. Free functions, concepts and Type Erasure let existing types (including third-party ones) fit in unchanged.

## 4. Decision guide

### Polymorphism: pick the first row that fits

| Situation | Mechanism |
|---|---|
| Behaviour fixed at compile time | Template + **concept** (static polymorphism) |
| Shared implementation for derived types (old CRTP use) | **Deducing `this`** (`this auto& self`) instead of CRTP |
| Closed, known set of alternatives (messages, states, AST nodes, config shapes) | **`std::variant` + `std::visit`** with an `overloaded` lambda set |
| Open set, needs runtime heterogeneity (`std::vector` of mixed types) | **Type Erasure** (value semantics, owning; small-buffer optimisation if it's hot) |
| Same, but non-owning (pass-through view) | `std::function_ref` (C++26) or a hand-written one |
| Plugin boundary, ABI boundary, or a small stable interface with runtime selection | Virtual interface, owned by `std::unique_ptr`. Never intrusive base classes for data types. |

Adding **operations** often while types stay fixed → `std::variant` (a Visitor makes new operations cheap). Adding **types** often while operations stay fixed → Type Erasure, templates or virtual functions.

### Callbacks and behaviour injection (Strategy, Command)

| Situation | Use |
|---|---|
| Known at compile time | Template parameter constrained with `std::invocable<...>` |
| Passed down the stack; caller outlives it | `std::function_ref` (C++26) or a hand-written one; else a template parameter |
| Stored, copyable | `std::function` |
| Stored, move-only captures (`unique_ptr`, sockets) | `std::move_only_function` (C++23) |
| Registering with a C API (`void(*)(void*)`) | Function pointer + context; make the context's lifetime outlast the registration |

`std::function_ref` accepts temporaries, which makes it unsafe to *store*. Use it only as a function parameter.

### Other patterns

- **Singleton:** avoid. Create services once in a **composition root** (`main` or the app's setup function) and pass references or owning handles down. Loggers and global config are the usual excuses; they are still injectable.
- **Pimpl / Bridge:** for a compile firewall or a stable ABI in a shared library. `std::unique_ptr<Impl>` with the destructor defined in the `.cpp`. Not for every class.
- **Observer:** state who owns whom. Return a connection/subscription RAII token that unsubscribes in its destructor, or hold observers as `std::weak_ptr`. Never call observers while holding a lock they might take.
- **Decorator:** a wrapper satisfying the same concept or interface (e.g. `Retrying<Client>`, `Buffered<Writer>`).
- **Adapter:** a thin type that makes a third-party or C API satisfy your abstraction; keeps those headers out of logic code.

## 5. Every abstraction has a price

For every abstraction the PR introduces (concept, variant, Type Erasure, interface, wrapper, seam), and every one you suggest, check:

- **Why it earns its place:** ≥2 real variants, a test seam, or an OS/library/ABI boundary.
- **What it costs:** allocations, indirection and lost inlining in hot paths, compile time (heavy templates in headers), binary size, readability.

If the case is weak, report it as `cost` with the plain alternative. Likewise, don't suggest a new seam without stating its price.

## 6. How to review

Load `references/review.md` and follow it. Start the review with a summary of what the changes do, in no more than 10 sentences. Then output a findings list, most severe first:

```
[tag] file:line: problem → suggested fix (one line why)
```

`ownership` = breaks section 1 (RAII, rule of zero, ownership, error policy). `design` = a principle from section 3 or a mismatch with section 4. `cost` = an abstraction whose price in section 5 isn't justified. `review.md` adds `bug`, `security`, `concurrency`, `perf`, `style` and `question`. Close with the one or two changes that matter most.

Never post to GitHub unless the user passes `--comment`; then always as a **pending** review, never submitted (see "Posting to GitHub" in `references/review.md`).

## 7. References

Load `references/patterns.md` when a suggested fix needs one of these patterns. It has C++23 sketches: concept seam, deducing `this`, variant visitor, owning Type Erasure, `function_ref`, `unique_fd` / custom-deleter RAII, Pimpl, Observer with RAII subscription, Decorator, composition root, `std::expected` errors.
