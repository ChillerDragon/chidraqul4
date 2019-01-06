#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

aBlock=()
aBlockHP=()
Block="O"
is_block=0

function DamageBlock {
    local index=$1
    local dmg=$2
    IsBlock $index
    if [[ "$is_block" == "1" ]]
    then
        aBlockHP[$index]=$((aBlockHP[$index] - dmg))
        if [[ "${aBlockHP[$index]}" -lt "1" ]]
        then
            let "blocks++"
            aBlock[$index]=0
            world[$index]="$world_air"
            SaveWorldToFile
        fi
    fi
}

function SetBlock {
    if [[ "$1" -gt "-1" ]]
    then
        world[$1]="$Block"
        aBlock[$1]=1
        aBlockHP[$1]=10
    else
        clear
        echo "[SetBlock] ERROR index $1 out of range"
        exit
    fi
}

function IsBlock {
    if [[ "${aBlock[$1]}" == "1" ]]
    then
        is_block=1
        return 1
    fi
    is_block=0
    return 0
}


