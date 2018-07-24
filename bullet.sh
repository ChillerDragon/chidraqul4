#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function BulletTick {
    local i
    local prev_pos
    local pos
    for ((i=0;i<=AliveBullets;i++)) do
        if [[ "${aBulletAlive[$i]}" == "1" ]]
        then
            pos=${aBulletIndex[$i]}
            prev_pos=$((pos - aBulletDir[i]))
            next_pos=$((aBulletIndex[i] + aBulletDir[i]))
            CheckBulletHit $i $next_pos
            #SetTileIndex $prev_pos "_"
            ClearTileIndex $prev_pos "+" "_"
            SetTileIndex ${aBulletIndex[$i]} "+"
            #world[$prev_pos]="_"
            #world[${aBulletIndex[$i]}]="+"
            aBulletIndex[$i]=$next_pos
            aBulletTick[$i]=$((aBulletTick[i] + 1))
            if [[ "${aBulletTick[$i]}" -gt "$BulletLifetime" ]]
            then
                DeleteBullet $i $pos
            fi
        fi
    done
    ClearDeadBullets #TODO: maybe move this to an slow tick func to gain performance
}

function CheckBulletHit {
    local i
    local id
    local pos
    id=$1
    pos=$2
    if [[ "${world[$pos]}" == "_" ]] #ignore normal world tiles
    then
        return
    fi

    for ((i=0;i<MAX_BOTS;i++)) do
        if [[ "${aBotAlive[$i]}" == "1" ]]
        then
            if [[ "${aBotIndex[$i]}" == "$pos" ]]
            then
                DeleteBullet $i $pos
                KillBot $i
                SendChat "[*] killed bot id=$i"
            fi
        fi
    done
}

function ClearDeadBullets {
    local i
    # Start from the highest index and delete until alive found
    for ((i=$AliveBullets;i>0;i--)) do
        if [[ "${aBulletAlive[$i]}" == "1" ]]
        then
            return #found alive -> stop cleaning
        else
            DeleteBullet $i
        fi
    done
}

function DeleteBullet {
    local i
    local old_pos
    i=$1
    old_pos=$2
    world[$old_pos]="_"
    #printf " deleted at index $old_pos "
    #read -n 1 -s -p ""
    aBulletAlive[$i]=0
    aBulletTick[$i]=0
    #if highest bullet pop array
    if [[ "$AliveBullets" == "$i" ]]
    then
        if [[ "$AliveBullets" -gt "0" ]]
        then
            #SendChat "[--] Alive: $AliveBullets Index: $i"
            let "AliveBullets--"
        fi
    fi
}

function AddBullet {
    local i
    let "AliveBullets++"
    for ((i=0;i<=AliveBullets;i++)) do
        if [[ "${aBulletAlive[$i]}" == "1" ]]
        then
            test
            #printf "index[$i] full\n"
        else
            aBulletIndex[$i]=$1
            aBulletAlive[$i]=1
            aBulletDir[$i]=$2
            #printf "Add bullet at index: $i \n"
        fi
    done
}


