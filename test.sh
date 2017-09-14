#!/bin/bash
while inotifywait -r -e modify ./test ./lib; do
  mix test test/exkml_test.exs
done
