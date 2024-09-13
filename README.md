# Nx Debug panic on SIGKILL

We've noticed that if we send SIGKILL to an Nx process sometimes it will crash from within the Rust Nx code. This issue is much more prevalent on our private monorepo which has ~650 projects total.

Here's the the result of running the `try-break-nx.sh`.
```sh
~/projects/nx-debug-stalled-process > ./try-break-nx.sh              
crew PID: 25368
~/projects/nx-debug-stalled-process > 
 NX   Running target start for project crew and 1 task it depends on:

———————————————————————————————————————————————————————————————————————————————————————————————————————————————

> nx run crew:build

thread '<unnamed>' panicked at packages/nx/src/native/pseudo_terminal/pseudo_terminal.rs:61:27:
Failed to enter raw terminal mode: Os { code: 5, kind: Uncategorized, message: "Input/output error" }
stack backtrace:
   0:        0x10f108188 - <std::sys::backtrace::BacktraceLock::print::DisplayBacktrace as core::fmt::Display>::fmt::h243268f17d714c7f
   1:        0x10ee99f94 - core::fmt::write::hb3cfb8a30e72d7ff
   2:        0x10f0d8aac - std::io::Write::write_fmt::hfb2314975de9ecf1
   3:        0x10f10a4d4 - std::panicking::default_hook::{{closure}}::h14c7718ccf39d316
   4:        0x10f109f24 - std::panicking::default_hook::hc62e60da3be2f352
   5:        0x10f10bc3c - std::panicking::rust_panic_with_hook::h09e8a656f11e82b2
   6:        0x10f10aecc - std::panicking::begin_panic_handler::{{closure}}::h1230eb3cc91b241c
   7:        0x10f10ae40 - std::sys::backtrace::__rust_end_short_backtrace::hc3491307aceda2c2
   8:        0x10f10ae34 - _rust_begin_unwind
   9:        0x10f308c1c - core::panicking::panic_fmt::ha4b80a05b9fff47a
  10:        0x10f308fac - core::result::unwrap_failed::h441932a0bca0dd7f
  11:        0x10ef8052c - nx::native::pseudo_terminal::rust_pseudo_terminal::RustPseudoTerminal::run_command::h3aa77d1a0a088207
  12:        0x10efb4800 - napi::tokio_runtime::within_runtime_if_available::hbb1699d95c763d42
  13:        0x10efb358c - nx::native::pseudo_terminal::rust_pseudo_terminal::__napi_impl_helper__RustPseudoTerminal__7::__napi__fork::h80ad27e8195d0428
thread '<unnamed>' panicked at library/core/src/panicking.rs:221:5:
panic in a function that cannot unwind
stack backtrace:
   0:        0x10f108188 - <std::sys::backtrace::BacktraceLock::print::DisplayBacktrace as core::fmt::Display>::fmt::h243268f17d714c7f
   1:        0x10ee99f94 - core::fmt::write::hb3cfb8a30e72d7ff
   2:        0x10f0d8aac - std::io::Write::write_fmt::hfb2314975de9ecf1
   3:        0x10f10a4d4 - std::panicking::default_hook::{{closure}}::h14c7718ccf39d316
   4:        0x10f109f24 - std::panicking::default_hook::hc62e60da3be2f352
   5:        0x10f10bc3c - std::panicking::rust_panic_with_hook::h09e8a656f11e82b2
   6:        0x10f10aea4 - std::panicking::begin_panic_handler::{{closure}}::h1230eb3cc91b241c
   7:        0x10f10ae40 - std::sys::backtrace::__rust_end_short_backtrace::hc3491307aceda2c2
   8:        0x10f10ae34 - _rust_begin_unwind
   9:        0x10f309090 - core::panicking::panic_nounwind_fmt::h91ee161184879b56
  10:        0x10f3090ec - core::panicking::panic_nounwind::heab7ebe7a6cd845c
  11:        0x10f3090a4 - core::panicking::panic_cannot_unwind::hedc43d82620205bf
  12:        0x10efb3738 - nx::native::pseudo_terminal::rust_pseudo_terminal::__napi_impl_helper__RustPseudoTerminal__7::__napi__fork::h80ad27e8195d0428
thread caused non-unwinding panic. aborting.
```

The script itself is pretty simple:
```bash
#!/usr/bin/env bash

export RUST_BACKTRACE=full

nx start crew &
crew_pid=$!

echo "crew PID: $crew_pid"

sleep 0.3

kill -9 $crew_pid

wait

```

# Acknowledgements

This reproduction repository is made from a fork of https://github.com/vsavkin/large-monorepo
