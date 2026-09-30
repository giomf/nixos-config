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

## C idioms (C only)

- `static` for file-local symbols, `const` on pointer params, include guards / `#pragma once`.
- Opaque structs/handles for module encapsulation.
- Macros: parenthesised args and bodies, `do { } while (0)`; prefer `static inline`, enums or `const`.
- Fixed-width types for hardware/protocol data; explicit endianness for wire formats; `_Static_assert` on struct layout assumptions.

## Readability

- Names consistent with the codebase; early returns over deep nesting.
- Comments explain *why* (datasheet section, errata, timing requirement); no stale or commented-out code.
- Magic numbers and register bits named.

## Report

Verify each finding against the code before reporting; drop anything you can't point to. No nits a formatter would fix. Use the findings format from SKILL.md section 6. Extra tags:

- `bug`: correctness, UB, unchecked errors, unbounded waits.
- `concurrency`: ISR, RTOS, shared-state and peripheral races.
- `resource`: stack, flash/RAM, power, watchdog, persistent data.
- `style`: C idioms and readability.

Order: `constraint` and `bug` first, then `concurrency`, `design`, `resource`, `cost`, `style`. Add open questions about intent or hardware separately. End with a 2–3 sentence verdict on design quality and merge readiness.

If the user passes `--comment` and the target is a GitHub PR, post findings as inline review comments via `gh api` only after showing them the list and getting confirmation.
