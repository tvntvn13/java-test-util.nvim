#!/usr/bin/env bash

tempfile=$(mktemp)


if [[ -n $1 ]] && [[ $1 == "--fail-fast" ]]; then
  echo "Running tests with --fail-fast"
  nvim --headless --noplugin -u tests/testrc.vim \
    -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/testrc.vim', sequential = true, keep_going = false}" | tee "${tempfile}"
elif [[ -n $1 ]]; then
  nvim --headless --noplugin -u tests/testrc.vim -c "PlenaryBustedFile $1" | tee "${tempfile}"
else
  nvim --headless --noplugin -u tests/testrc.vim \
    -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/testrc.vim'}" | tee "${tempfile}"
fi

# Plenary doesn't emit exit code 1 when tests have errors during setup
errors=$(sed 's/\x1b\[[0-9;]*m//g' "${tempfile}" | awk '/(Errors|Failed) :/ {print $3}' | grep -v '0')

rm "${tempfile}"

if [[ -n $errors ]]; then
  echo "Tests failed"
  exit 1
fi

exit 0
