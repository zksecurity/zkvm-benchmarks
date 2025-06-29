#!/bin/bash

if command -v bash >/dev/null 2>&1; then
  exec bash -cu "$@"
elif command -v zsh >/dev/null 2>&1; then
  exec zsh -cu "$@"
else
  echo "Neither bash nor zsh found!" >&2
  exit 1
fi