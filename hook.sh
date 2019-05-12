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


update_xp(){
    xp=$(git config --get hooks.xp)
    if [ -z "$xp" ]; then
        xp=100
    fi
    xp=$(($xp+$1))
    git config --add hooks.xp "$xp"
}

check_message() {
    echo "Linus is checking your commit message ..."

    local message=$1 # refer as message to the first arg
    local message_string=$( cat "$message" ) # the actual string of the message

    # here collect the list of possible checks in 
    # RegexCheck:Reason:ErrorCode format
    local ChecksAndReasons=("^[A-Z]:Why aren't you starting the commit message with a capital letter like everyone else?:255"
        "^(Add|Cut|Fix|Bump|Make|Start|Stop|Refactor|Reformat|Optimize|Document):Why do you want to invent a starting word for your commit? Use one of Add, Fix etc. that we usually use.:254"
        "^(Add|Cut|Fix|Bump|Make|Start|Stop|Refactor|Reformat|Optimize|Document)(?!ed):Don't use past tense, your commit has not been accepted yet.:253"
        "^.{1,50}(?!.):Seriously? You expected me to read this overly verbose commit message?:252")
    for KeyValPair in "${ChecksAndReasons[@]}"
        do
            # let's split the list items to parts
            pattern=`echo "$KeyValPair" | cut -d':' -f1`
            reason=`echo "$KeyValPair" | cut -d':' -f2`
            error_code=`echo "$KeyValPair" | cut -d':' -f3`

            ### DEBUG part
            # echo "$pattern $message_string"
            # echo `head -1 "$message" | grep -P "$pattern" "$1"`
            if ! head -1 "$message" | grep -P "$pattern" "$1"; then
                # some check detected an error
                action=$(get_review_action)
                echo "$action $reason Error code: $error_code" >&2
                update_xp -5
                echo "For this, you earned -5XP that means you have a total of ${xp}XP now."
                exit $error_code
            fi
          
        done

    ## all good
    update_xp 1
    echo "Good job, I give you 1XP that means you have a total of ${xp}XP now."
    
}

# Actual hook logic:

# regex to validate in commit msg

check_message $1