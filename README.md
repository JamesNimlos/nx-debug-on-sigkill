# Nx Debug panic on SIGKILL

We've noticed that if we send SIGKILL to an Nx process sometimes it will crash from within the Rust Nx code. This issue is much more prevalent on our private monorepo which has ~650 projects total.

Here's the the result of running the `try-break-nx.sh`.
```sh
~/projects/nx-debug-stalled-process > ./try-break-nx.sh

 NX   Resetting the Nx workspace cache and stopping the Nx Daemon.

This might take a few minutes.


 NX   Daemon Server - Stopped


 NX   Successfully reset the Nx workspace.

crew PID: 28807
./try-break-nx.sh: line 16: 28807 Killed: 9               nx start crew
~/projects/nx-debug-stalled-process > 
 NX   Running target start for project crew and 1 task it depends on:

———————————————————————————————————————————————————————————————————————————————————————————————————————————————

> nx run crew:build

thread '<unnamed>' panicked at packages/nx/src/native/pseudo_terminal/pseudo_terminal.rs:61:27:
Failed to enter raw terminal mode: Os { code: 5, kind: Uncategorized, message: "Input/output error" }
stack backtrace:
   0:        0x10e7ae488 - <std::sys_common::backtrace::_print::DisplayBacktrace as core::fmt::Display>::fmt::h0aa20ca08aeb683c
   1:        0x10e559d8c - core::fmt::write::h168dbafcf35bac68
   2:        0x10e785244 - std::io::Write::write_fmt::hdb0dd3f09dcf2281
   3:        0x10e7b0334 - std::sys_common::backtrace::print::h57b289e4b951ee17
   4:        0x10e7aff88 - std::panicking::default_hook::{{closure}}::h783b6c512154ec65
   5:        0x10e7b1000 - std::panicking::rust_panic_with_hook::h9aea678ca49d64cf
   6:        0x10e7b0ab4 - std::panicking::begin_panic_handler::{{closure}}::ha16c3377e66deceb
   7:        0x10e7b0a18 - std::sys_common::backtrace::__rust_end_short_backtrace::hea8fdda1ea8a4c0e
   8:        0x10e7b0a0c - _rust_begin_unwind
   9:        0x10e8664c4 - core::panicking::panic_fmt::h1cb43b60f5788132
  10:        0x10e86683c - core::result::unwrap_failed::h71a35eff74d84b68
  11:        0x10e63ab50 - nx::native::pseudo_terminal::rust_pseudo_terminal::RustPseudoTerminal::run_command::h60e83121abdf9912
  12:        0x10e63ca78 - nx::native::pseudo_terminal::rust_pseudo_terminal::RustPseudoTerminal::fork::ha62467a2965935dc
  13:        0x10e6bb49c - nx::native::pseudo_terminal::rust_pseudo_terminal::__napi_impl_helper__RustPseudoTerminal__1::__napi__fork::h55352d7e9a773eee
fatal runtime error: failed to initiate panic, error 5
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
