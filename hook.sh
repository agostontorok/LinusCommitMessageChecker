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
    local pattern1='^[A-Z]'
    local error_msg="I'm aborting this commit. Why aren't you starting the commit message with a capital letter like everyone else?"

    if ! head -1 "$message" | grep "$pattern1" "$1"; then
    echo "$error_msg" >&2
    exit 1
fi
}

# Actual hook logic:

# regex to validate in commit msg

check_message $1

exit
