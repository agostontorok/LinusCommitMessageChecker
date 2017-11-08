#!/bin/bash

# If we have a STDIN, use it, otherwise get one
if tty >/dev/null 2>&1; then
    TTY=$(tty)
else
    TTY=/dev/tty
fi

IFS=$'\n'

get_review_action() {
    echo "I'm aborting this commit." 
}


check_message() {
    local message=$1
    local message_string=$( cat "$message" )
    local ChecksAndReasons=("^[A-Z]:Why aren't you starting the commit message with a capital letter like everyone else?"
        "^(Add|Cut|Fix|Bump|Make|Start|Stop|Refactor|Reformat|Optimize|Document):Why do you want to invent a starting word for your commit? Use one of Add, Fix etc. that we usually use.")

    for KeyValPair in "${ChecksAndReasons[@]}"
        do
          pattern=`echo "$KeyValPair" | cut -d':' -f1`
          reason=`echo "$KeyValPair" | cut -d':' -f2`
          echo "$pattern $message_string"
          if ! head -1 "$message" | grep -E "$pattern" "$1"; then
            action=$(get_review_action)
            echo "$action $reason" >&2
            exit 1
            fi
          
        done
    
}

# Actual hook logic:

# regex to validate in commit msg

check_message $1

exit
