#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

aChatLog=()
aChatLifetime=()
MAX_CHAT_LEN=4
CHAT_DELAY=5

function ChatTick {
    local i
    for ((i=0;i<=MAX_CHAT_LEN;i++)) do
        aChatLifetime[$i]=$((aChatLifetime[i] - 1))
    done
}

function SendChat {
    local next
    local i
    for ((i=MAX_CHAT_LEN;i>=0;i--)) do
        next=$((i + 1))
        aChatLog[$next]=${aChatLog[$i]}
        aChatLifetime[$next]=${aChatLifetime[$i]}
    done
    aChatLog[0]=$1
    aChatLifetime[0]=$CHAT_DELAY
}

function PrintChat {
    local i
    pFrame+="\n"
    for ((i=MAX_CHAT_LEN;i>=0;i--)) do
        if [[ "$1" == "1" ]] || [[ "${aChatLifetime[$i]}" -gt "0" ]]
        then
            pFrame+="${aChatLog[$i]}\n"
        else
            pFrame+="\n"
        fi
    done
}
