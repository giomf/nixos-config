# PR review checklist (embedded C and C++)

Design, principles and the heap/exception/RTTI constraints come from SKILL.md. This file adds the review workflow and the firmware checks SKILL.md doesn't cover. For C code, apply the principles from SKILL.md and skip the C++-only mechanisms.

## Gather context

- Target: PR number/URL (`gh pr view <n>`, `gh pr diff <n>`), branch (`git diff <base>...HEAD`), or the working tree (`git diff HEAD`). Default to the current branch against its merge base with main.
- Read the PR description and linked issue to learn the intent.
- Read every changed file **in full**, plus the headers and callers the change touches. Never judge a hunk without its surroundings.
- Detect the platform: MCU/SoC, toolchain flags, RTOS or bare-metal superloop, HAL/SDK (Zephyr, nRF Connect SDK, STM32 HAL, ESP-IDF, FreeRTOS, …), coding standard (MISRA, Barr) and formatting config.

## Correctness

- Undefined behaviour: signed overflow, out-of-bounds, uninitialised reads, strict aliasing via pointer casts on buffers, misaligned access on packed structs, shifts ≥ width, null deref, dangling `std::span`/`std::string_view`.
- Integers: implicit narrowing, signed/unsigned comparisons, `size_t` underflow in loops, `sizeof` on decayed pointers, promotion surprises in `uint8_t`/`uint16_t` arithmetic.
- Buffers & strings: unchecked lengths from radio/UART/sensor input, `strcpy`/`sprintf`/`strncpy` misuse, missing terminators, off-by-one in ring buffers.
- Errors: every return code / `std::expected` checked and propagated; no ignored HAL/driver errors; defined safe state on unrecoverable errors.
- Timeouts: no unbounded busy-waits on hardware flags; every wait has a timeout and a recovery path.
- Tick wraparound: `(now - start) >= timeout` with unsigned arithmetic, not `now >= start + timeout`.

## Concurrency, ISRs & timing

- State shared with ISRs or tasks: `volatile` where needed (never as a substitute for atomicity); atomics or critical sections for multi-byte and read-modify-write access.
- ISRs short and deterministic: no blocking calls, no logging, no non-ISR-safe RTOS APIs, no long loops; defer work to a task/workqueue.
- Critical sections minimal; interrupts never left disabled on an error path.
- RTOS: priority inversion, lock ordering, mutex vs semaphore misuse, stack size of new threads, blocking calls from the wrong context.
- Peripherals: register read-modify-write races, required barriers (`__DSB`/`__ISB`), DMA buffer alignment and cache coherency, buffers not reused while DMA is in flight.

## Resources

- Buffers sized at compile time with justified sizes and handled overflow.
- Stack: large local arrays, deep or unbounded recursion, large structs passed by value.
- Flash/RAM: lookup tables not `const` (land in RAM), template bloat, heavy stdlib pulls (`printf` floats, iostream).
- Floating point on MCUs without an FPU or inside ISRs.
- Power: polling where an interrupt would do, peripherals and clocks left enabled, wakeups that prevent sleep.
- Watchdog: long operations still feed it; it isn't fed from an ISR in a way that masks a hung main loop.
- Persistent data (flash/EEPROM/NVS): wear, power-loss-safe updates, versioning of stored structs.
- No heavy work or cross-TU dependencies in global constructors.

## Design additions

- Layering: application → services → drivers → HAL; no upward includes or cycles.
- APIs hard to misuse: units in names or types (`timeout_ms`, `std::chrono`), no bool-parameter traps, clear buffer ownership and lifetime.
- Explicit state machines over flag combinations; defined behaviour on reset and brownout.
- Tests included and covering error and timeout paths.

## Modern C++ idioms (C++ only)

Hunt C-style code in C++ files; the types in SKILL.md section 1 are allowed, so use them. Don't report how much the codebase already uses them; the user knows the codebase.

- Output parameters and `bool` + `T&` / `bool* ok = nullptr` → return `std::optional<T>`. A defaulted `ok` pointer lets callers ignore failure, which makes it a `bug` risk, not just `style`.
- `bool` + a reason only in the log (enum result, several failure paths) → `std::expected<T, E>`. Not when the error path must also return data (e.g. bytes consumed by a decoder): return a small struct there.
- Pointer + length pairs → `std::span`. Copying into a fixed buffer without checking the length against its capacity is a `bug`.
- C arrays → `std::array`, especially where it replaces element-wise compare/copy loops with `==` / `=`.
- `valid` / `has_x` flags and sentinel values (`unit == 0`) next to the data → `std::optional` members (usually the same size after padding).
- Parallel arrays, or pointer arrays to sibling members → `std::array` of a struct.
- Hand-rolled stdlib: parity/bit loops → `std::popcount` / `<bit>`; `memcpy` type punning → `std::bit_cast`; `sizeof(a)/sizeof(a[0])` → `std::size`; copy/shift loops → `std::copy` / `memmove`.
- Mutable globals swapped temporarily to change a callee's behaviour → pass the values as parameters.

Ask for the fixes to API signatures in this PR; leave internal idiom fixes as follow-ups.

## C idioms (C only)

- `static` for file-local symbols, `const` on pointer params, include guards / `#pragma once`.
- Opaque structs/handles for module encapsulation.
- Macros: parenthesised args and bodies, `do { } while (0)`; prefer `static inline`, enums or `const`.
- Fixed-width types for hardware/protocol data; explicit endianness for wire formats; `_Static_assert` on struct layout assumptions.

## Readability

- Names follow the project's documented naming conventions (e.g. a `conventions.md` linked from `AGENTS.md`); only if none exist, stay consistent with the surrounding code. Flag violations in new or moved code, even if the old code broke them too.
- Early returns over deep nesting.
- Comments explain *why* (datasheet section, errata, timing requirement); no stale or commented-out code.
- Magic numbers and register bits named.

## Report

Verify each finding against the code before reporting; drop anything you can't point to. No nits a formatter would fix. Use the findings format from SKILL.md section 6. Extra tags:

- `bug`: correctness, UB, unchecked errors, unbounded waits.
- `concurrency`: ISR, RTOS, shared-state and peripheral races.
- `resource`: stack, flash/RAM, power, watchdog, persistent data.
- `style`: C idioms, modern C++ idioms and readability.
- `question`: open questions about intent or hardware.

Order: `constraint` and `bug` first, then `concurrency`, `design`, `resource`, `cost`, `style`, `question`. List questions separately in the terminal report. End with a 2–3 sentence verdict on design quality and merge readiness.

## Posting to GitHub

- Post only when the user passes `--comment` and the target is a GitHub PR. Never post otherwise.
- Always create a **pending** review: `POST /repos/{owner}/{repo}/pulls/{n}/reviews` with `commit_id` and `comments`, and **no `event` field**. Never submit, approve or request changes; the user finishes the review.
- Post every finding, including the ones without a single line (anchor those on line 1 of the file). To add a comment to an existing pending review, use the GraphQL `addPullRequestReviewThread` mutation with the review's `node_id`.
- Start each comment body with its tag: `[bug] …`, `[style] …`, `[design] …`, `[question] …`.
- Keep comments short and follow the repo's rules for PR text (e.g. `AGENTS.md`), but never post a bare fix. Each comment states, in one or two sentences, what is wrong or could be better, why it matters, and the fix. The reader must understand it without opening the code. Not `` `std::size(CHANNEL_CS)` `` but `` [style] `sizeof(CHANNEL_CS) / sizeof(CHANNEL_CS[0])` silently breaks if the array ever becomes a pointer; `std::size(CHANNEL_CS)` says the same and won't compile then. ``
- Afterwards, list the review's comments via the API and check the count matches the findings.
