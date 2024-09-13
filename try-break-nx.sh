#!/usr/bin/env bash

export RUST_BACKTRACE=full

nx start crew &
crew_pid=$!

echo "crew PID: $crew_pid"

sleep 0.3

kill -9 $crew_pid
