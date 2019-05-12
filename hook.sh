#!/bin/bash

# If we have a STDIN, use it, otherwise get one
if tty >/dev/null 2>&1; then
    TTY=$(tty)
else
    TTY=/dev/tty
fi

IFS=$'\n'

check_message() {
    local message=$1
    local message_string=$( cat "$message" )
    local pattern1='test'
    local error_msg="Aborting commit. Your commit message is missing $pattern1, it is $message_string"

    if ! grep -iqE "$pattern1" "$message"; then
    echo "$error_msg" >&2
    exit 1
fi
}

# Actual hook logic:

# regex to validate in commit msg

check_message $1

exit
