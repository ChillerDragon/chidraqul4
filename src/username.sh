#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

pUsername=""
UsernameLen=0
MaxUsernameLen=16

function UsernamePrint {
    clear
    local i
    printf "+"
    for ((i=0;i<MaxUsernameLen;i++))
    do
        printf "-"
    done
    printf "+\n"

    printf "|$pUsername"


    for ((i=$UsernameLen;i<MaxUsernameLen;i++))
    do
        printf " "
    done
    printf "|\n"


    printf "+"
    for ((i=0;i<MaxUsernameLen;i++))
    do
        printf "-"
    done
    printf "+"
}

function UsernameInp {
    local inp
    tput cup 1 $UsernameLen
    read -n 1 -p "" inp
    if [ "$inp" == $'^?' ]
    then
        pUsername=""
    fi
    pUsername+=$inp
    UsernameLen=$((UsernameLen + 1))
}

function UsernameMain {
    SendChat "username is currently in development"
    return #TODO: finish me

    UsernamePrint
    UsernameInp
    UsernameMain
}
