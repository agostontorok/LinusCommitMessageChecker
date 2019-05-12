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
    local ChecksAndReasons=("^[A-Z]:I'm aborting this commit. Why aren't you starting the commit message with a capital letter like everyone else?")


    for KeyValPair in $ChecksAndReasons
        do
          pattern=`echo "$KeyValPair" | cut -d':' -f1`
          reason=`echo "$KeyValPair" | cut -d':' -f2`
          echo "$pattern$reason"
          if ! head -1 "$message" | grep "$pattern" "$1"; then
            echo "$reason" >&2
            exit 1
            fi
          
    done
    
}

# Actual hook logic:

# regex to validate in commit msg

check_message $1

exit
