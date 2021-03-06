#!/bin/bash

# If we have a STDIN, use it, otherwise get one
if tty >/dev/null 2>&1; then
    TTY=$(tty)
else
    TTY=/dev/tty
fi

IFS=$'\n'

negative_start_lines=("Stop freaking around already. YOU DO NOT SEEM TO UNDERSTAND WHAT A COMMIT MESSAGE IS ACTUALLY FOR" 
        "You are a person with zero taste, don't care about commit logs and can't be bothered. You're a moron." 
        "Seriously, WTF? I made the mistake your utter nonsense message." 
        "You know what? I just hate you, period.")

positive_start_lines=("It's ok. Or did you expect cookies for making a nice commit message?"
    "I'm sure it doesn't work or causes warnings for various reasons, but
the commit message is a thing of beaty."
"You are either a genius, or a seriously diseased mind.")

get_quote() {
    # seed random generator
    RANDOM=$$$(date +%s)
    quotes=("$@")
    # pick a random entry from the domain list to check against
    current_starting_line=${quotes[$RANDOM % ${#quotes[@]}]}
    echo "$current_starting_line" 
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
    echo ""
    echo  -e "\033[0;31mLinus is checking your commit message ..."

    local message=$1 # refer as message to the first arg
    # local message_string=$( cat "$message" ) # the actual string of the message

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
            is_violating=$(! head -1 "$message" | grep -P "$pattern" "$1")
            if [ -z "$is_violating" ]; then
                # some check detected an error
                negative_quote=$(get_quote "${negative_start_lines[@]}")
                echo -e "\033[0;31m$negative_quote $reason Error code: $error_code" >&2
                update_xp -5
                echo -e "\033[0;31mFor this, you earned -5XP that means you have a total of ${xp}XP now."
                exit $error_code
            fi
          
        done

    ## all good
    update_xp 1
    positive_quote=$(get_quote "${positive_start_lines[@]}")
    echo -e "\033[0;31m$positive_quote I give you 1XP that means you have a total of ${xp}XP now."
    
}

# Actual hook logic:

# regex to validate in commit msg

check_message $1