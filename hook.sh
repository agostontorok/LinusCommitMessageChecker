#!/bin/bash

# If we have a STDIN, use it, otherwise get one
if tty >/dev/null 2>&1; then
    TTY=$(tty)
else
    TTY=/dev/tty
fi

IFS=$'\n'

check_file() {
    local message=$1
}

# Actual hook logic:


check_file "hello"
exit
