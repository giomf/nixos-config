# PR review checklist (C++ on Linux)

Design, principles and the ownership/error baseline come from SKILL.md. This file adds the review workflow and the platform checks SKILL.md doesn't cover.

## Gather context

- Target: PR number/URL (`gh pr view <n>`, `gh pr diff <n>`), branch (`git diff <base>...HEAD`), or the working tree (`git diff HEAD`). Default to the current branch against its merge base with main.
- Read the PR description and linked issue to learn the intent.
- Read every changed file **in full**, plus the headers and callers the change touches. Never judge a hunk without its surroundings.
- Detect the setup: build system, compiler and minimum version, warning flags, sanitizer and `clang-tidy` config, test framework, `.clang-format`, and whether the code is a library (public API, ABI) or an application.
- If the build and tests run cheaply, build with warnings on and run the affected tests; with sanitizers (`-fsanitize=address,undefined`, or `thread` for concurrency changes) if the project has a preset for it. Report what you ran. Don't install toolchains to do it.

## Correctness

- Undefined behaviour: signed overflow, out-of-bounds, uninitialised reads, strict aliasing via pointer casts, shifts ≥ width, null deref, data races.
- Lifetime: dangling references/`std::span`/`std::string_view`/iterators (to temporaries, to reallocated vectors, to moved-from objects), lambdas capturing `this` or locals by reference and outliving them (threads, callbacks, async), returning references to locals, use after move.
- Iterator and reference invalidation: `push_back`/`insert`/`erase` while holding iterators or references into the container; erasing while iterating.
- Integers: implicit narrowing, signed/unsigned comparisons, `size_t` underflow in loops, `int` for sizes and file offsets (`off_t`, `size_t`, `ssize_t`).
- Exception safety (if exceptions are on): every function gives at least the basic guarantee; no resource leaks or half-updated invariants when something throws; `noexcept` on moves so containers use them; nothing throws out of a destructor or a C callback.
- Errors: every return code / `std::expected` / `[[nodiscard]]` result checked and propagated; `.value()` only where a throw is the intended outcome; errors carry enough context (path, errno text) to diagnose.
- Special members: missing `explicit` on single-argument constructors, slicing (base passed by value), non-virtual destructor in a polymorphic base, self-assignment.
- Initialisation: static initialisation order across translation units; heavy work or I/O in global constructors.

## Linux / POSIX

- Every syscall's return is checked; `errno` read immediately after the failing call, before anything that might overwrite it (logging, destructors).
- `EINTR` handled or `SA_RESTART` relied on knowingly; `read`/`write`/`send`/`recv` loop over partial transfers; `EAGAIN` handled on non-blocking fds.
- File descriptors: `O_CLOEXEC` / `SOCK_CLOEXEC` on everything opened in a process that forks or execs; no double close; no use after close; fds owned by RAII.
- Signals: handlers only call async-signal-safe functions (no `malloc`, `printf`, locks, logging); set a `volatile sig_atomic_t` / atomic flag, or use `signalfd` / self-pipe. Signal masks set before spawning threads.
- `fork` in a multithreaded process: only async-signal-safe calls until `exec`; prefer `posix_spawn`.
- Files: write-to-temp + `fsync` + `rename` for atomic updates; `fsync` the directory when durability matters; TOCTOU between `stat`/`access` and `open`; `umask`/mode on created files.
- Paths: `std::filesystem` over string concatenation; the overloads taking `std::error_code` where failure is expected; symlinks followed only on purpose.
- Time: `std::chrono::steady_clock` for timeouts and durations, `system_clock` only for wall time; no `sleep`-based synchronisation.
- Processes and env: `getenv` results not stored past `setenv`; locale-dependent parsing (`atof`, `strtod`, `std::stod`) on machine-readable input → `std::from_chars`.

## Security

- Untrusted input (network, files, CLI args, env): lengths and ranges validated before use; integer overflow in size computations (`n * sizeof(T)`); recursion depth bounded.
- No `system()`/`popen()` with interpolated strings; `exec*`/`posix_spawn` with an argv array.
- Format strings never come from input (`printf(user)`); fmt/`std::format` with compile-time format strings.
- No `strcpy`/`sprintf`/`gets`/`strncpy` misuse; no fixed-size C buffers for input of unbounded size.
- Secrets: not logged, zeroed when the project requires it, files created with restrictive permissions; random numbers for security from `getrandom`, not `rand`/`std::mt19937`.
- Temp files via `mkstemp`/`O_TMPFILE`, not predictable names in `/tmp`.
- Privilege: dropped as early as possible; return of `setuid`/`setgid` checked.

## Concurrency

- Every piece of shared mutable state names its protection (mutex, atomic, single-thread confinement). Document which mutex guards what.
- Lock ordering consistent; no callbacks, logging into user code, or blocking I/O while holding a lock; `std::scoped_lock` for multiple mutexes.
- `std::condition_variable`: wait with a predicate (spurious wakeups); notify after the state change under the same mutex.
- Atomics: `memory_order` other than `seq_cst` justified in a comment; no check-then-act across two atomic operations; `std::atomic<std::shared_ptr>` instead of unsynchronised `shared_ptr` reassignment.
- Thread lifetime: `std::jthread` with `std::stop_token` over `std::thread` + flag; no detached threads touching objects that can be destroyed; joined before members they use are destroyed (declaration order).
- `static` locals and lazily initialised globals are thread-safe to construct, not to mutate.
- Async/event loop code (ASIO, Qt, epoll): no blocking calls on the loop thread; handlers keep their objects alive (`shared_from_this` or an explicit owner).

## Performance

Only where it plausibly matters (hot paths, large data, per-request code). Don't micro-optimise setup code.

- Unneeded copies: large types by value where `const&` or move fits; `auto` copying from a range-for (`for (auto x : big_vector)`); missing `std::move` on last use; `return std::move(local)` blocking NRVO.
- Allocations in loops: missing `reserve`, string concatenation in loops, `std::function` or `shared_ptr` per call, `std::endl` (flush) in loops.
- Containers: `std::map`/`std::list` where `std::vector` or `std::unordered_map` fits; linear search in a hot path; `std::string` keys looked up with `const char*` (use transparent comparators).
- Syscalls per byte (unbuffered I/O), polling where blocking or `epoll` would do.
- Heavy templates or includes in widely included headers (compile time).

## Design additions

- Layering: application → services → OS/library adapters; no upward includes or cycles.
- APIs hard to misuse: strong types or `std::chrono` for units, no bool-parameter traps, clear ownership in parameter types (`unique_ptr` by value = takes ownership, `T&` = borrows), `[[nodiscard]]` on results that must be checked.
- Libraries: public headers minimal; no `using namespace` in headers; ABI changes noted when the library is shared.
- Explicit state machines (`std::variant` of states) over flag combinations.
- Tests included and covering error, timeout and concurrency paths; tests don't depend on wall clock, real network or test ordering.

## Modern C++ idioms

Hunt C-style and pre-C++11 code. Don't report how much the codebase already uses them; the user knows the codebase.

- Output parameters and `bool` + `T&` / `bool* ok = nullptr` → return `std::optional<T>` or `std::expected<T, E>`. A defaulted `ok` pointer lets callers ignore failure, which makes it a `bug` risk, not just `style`.
- Pointer + length pairs → `std::span`; `const std::string&` parameters that only read → `std::string_view` (if lifetime allows).
- C arrays → `std::array`; manual `new[]` → `std::vector`; owning raw pointers → `std::unique_ptr`.
- `valid` / `has_x` flags and sentinel values next to the data → `std::optional`.
- Hand-rolled algorithms → `<algorithm>` / `<ranges>`; `sizeof(a)/sizeof(a[0])` → `std::size`; `memcpy` punning → `std::bit_cast`; `sprintf`/`stringstream` formatting → `std::format` (or the project's fmt).
- `#define` constants → `constexpr`; plain `enum` → `enum class`; `NULL`/`0` → `nullptr`; `typedef` → `using`.
- Mutable globals swapped temporarily to change a callee's behaviour → pass the values as parameters.

Ask for the fixes to API signatures in this PR; leave internal idiom fixes as follow-ups.

## Readability

- Names follow the project's documented naming conventions (e.g. a `conventions.md` linked from `AGENTS.md`); only if none exist, stay consistent with the surrounding code. Flag violations in new or moved code, even if the old code broke them too.
- Early returns over deep nesting.
- Comments explain *why* (spec reference, kernel quirk, bug link); no stale or commented-out code.
- Magic numbers named.

## Report

Verify each finding against the code before reporting; drop anything you can't point to. No nits a formatter or compiler warning would fix. Use the findings format from SKILL.md section 6. Extra tags:

- `bug`: correctness, UB, lifetime, unchecked errors, syscall misuse.
- `security`: input validation, injection, unsafe temp files, secrets, privilege.
- `concurrency`: data races, deadlocks, thread lifetime, event loop blocking.
- `perf`: copies, allocations, algorithmic complexity in hot paths.
- `style`: modern C++ idioms and readability.
- `question`: open questions about intent or environment.

Order: `bug`, `security` and `ownership` first, then `concurrency`, `design`, `perf`, `cost`, `style`, `question`. List questions separately in the terminal report. End with a 2–3 sentence verdict on design quality and merge readiness.

## Posting to GitHub

- Post only when the user passes `--comment` and the target is a GitHub PR. Never post otherwise.
- Always create a **pending** review: `POST /repos/{owner}/{repo}/pulls/{n}/reviews` with `commit_id` and `comments`, and **no `event` field**. Never submit, approve or request changes; the user finishes the review.
- Post every finding, including the ones without a single line (anchor those on line 1 of the file). To add a comment to an existing pending review, use the GraphQL `addPullRequestReviewThread` mutation with the review's `node_id`.
- Start each comment body with its tag: `[bug] …`, `[security] …`, `[design] …`, `[question] …`.
- Keep comments short and follow the repo's rules for PR text (e.g. `AGENTS.md`), but never post a bare fix. Each comment states, in one or two sentences, what is wrong or could be better, why it matters, and the fix. The reader must understand it without opening the code. Not `` `O_CLOEXEC` `` but `` [bug] The socket is opened without `SOCK_CLOEXEC`, so every child started by `spawn_worker` inherits it and the port stays bound after this process exits; add `SOCK_CLOEXEC` to the `socket()` flags. ``
- Afterwards, list the review's comments via the API and check the count matches the findings.
