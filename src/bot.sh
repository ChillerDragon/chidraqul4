#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function BotTick {
    local i
    for ((i=0;i<MAX_BOTS;i++)) do
        if [[ "${aBotAlive[$i]}" == "1" ]]
        then
            MoveBot "$i"
        fi
    done
}

function BotStatus {
    local i
    clear
    for ((i=0;i<MAX_BOTS;i++)) do
        echo "bot[$i] Alive:${aBotAlive[$i]} Index:${aBotIndex[$i]}"
    done
    read -r -n 1 -s -p ""
}

function AddBot {
    local i
    for ((i=0;i<MAX_BOTS;i++)) do
        if [[ "${aBotAlive[$i]}" == "1" ]]
        then
            test
        else
            aBotAlive[$i]=1
            aBotIndex[$i]=$1
            SendChat "[+] bot index($1) id($i)"
            return
        fi
    done
}

function KillBot {
    local id
    id=$1
    aBotAlive[$id]=0
    SetGold "${aBotIndex[$id]}"
}

function MoveBot {
    local id
    local mov
    #mov=$(( RANDOM % 2 - 1 ))
    BotWalked=$((BotWalked + 1))
    if [[ "$BotWalked" -gt "6" ]]
    then
        if [[ "$BotDir" == "1" ]]
        then
            BotDir=-1
        else
            BotDir=1
        fi
        BotWalked=0
    fi
    mov=$BotDir

    id=$1
    aBotLastIndex[$id]=${aBotIndex[$i]}
    aBotIndex[$id]=$((aBotIndex[i] + mov))

    world[${aBotLastIndex[$id]}]="$world_air"
    world[${aBotIndex[$id]}]="$botskin"
}

