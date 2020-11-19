#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

bomb="ø"
aBombTick=()
aBombX=()
aBombY=()
aBomb=() #index is tile index value is 1/0 for alive or not
TotalBombs=0

function AddBomb { #TODO: maybe check if there is a bomb already to avoid double bombs
    local x=$1
    local y=$2
    local i
    TotalBombs=$((TotalBombs + 1))
    for ((i=0;i<=TotalBombs;i++)) do
        if [[ "${aBombTick[$i]}" -gt "0" ]]
        then
            continue #skip alive
        else
            aBombTick[$i]=5
            aBombX[$i]=$x
            aBombY[$i]=$y
            GetTileIndex "$x" "$y"
            aBomb[$TileIndex]=1
            SendChat "add bomb[$i] at x=$x y=$y"
        fi
    done
}

function DeleteBomb {
    local index=$1
    GetTileIndex "${aBombX[$index]}" "${aBombY[$index]}"
    aBomb[$TileIndex]=0
    return
}

function BombTick {
    local i
    for ((i=0;i<=TotalBombs;i++)) do
        if [[ "${aBombTick[$i]}" -gt "0" ]]
        then
            #SendChat "bomb[$i] tickntick=${aBombTick[$i]}"
            aBombTick[$i]=$((aBombTick[i] - 1))
            if [[ "${aBombTick[$i]}" == "0" ]]
            then
                Explode "${aBombX[$i]}" "${aBombY[$i]}" 2
                DeleteBomb "$i"
                #SendChat "EXPLOOOOOOOODE"
            fi
        fi
    done
}

function AddSmoke { #TODO: add clear smoke (best would be with delay and or effect)
    local x=$1
    local y=$2
    local r=$3 #radius
    local m #middle
    GetTileIndex "$x" "$y"
    m=$TileIndex
    local i
    local startX=$((x - r * 2))
    local startY=$((y - r))
    local pX=$((startX - 1))
    local pY=$((startY))
    local pI=0 #pointer to current index (no pointer at all xd)
    local exp_tiles=$(( (r * 2) * (r * 4) - 1 ))
    local size_x=$(( r * 4 ))
    local size_y=$(( r * 2 ))
    local tile_counterX=0

    #SendChat "[exp] startX: $startX startY: $startY ttotal: $exp_tiles"

    for ((i=0;i<=exp_tiles;i++)) do
        pX=$((pX + 1))
        if [[ "$tile_counterX" -gt "$size_x" ]]
        then
            tile_counterX=0
            pX=$startX
            pY=$((pY + 1))
        fi
        tile_counterX=$((tile_counterX + 1))
        GetTileIndex "$pX" "$pY"
        pI=$TileIndex

        if [[ "$pI" -gt "-1" ]] #TODO: also add check for maximum tile index (also in render.sh)
        then
            #also explode out of map since DamageBlock does the check for us
            world[$pI]="~"
            #SendChat "damage index $pI"
        fi
    done
}

function Explode {
    local x=$1
    local y=$2
    local r=$3 #radius
    local m #middle
    GetTileIndex "$x" "$y"
    m=$TileIndex
    local i
    local startX=$((x - r * 2))
    local startY=$((y - r))
    local pX=$((startX - 1))
    local pY=$((startY))
    local pI=0 #pointer to current index (no pointer at all xd)
    local exp_tiles=$(( (r * 2) * (r * 4) - 1 ))
    local size_x=$(( r * 4 ))
    local size_y=$(( r * 2 ))
    local tile_counterX=0

    #SendChat "[exp] startX: $startX startY: $startY ttotal: $exp_tiles"

    for ((i=0;i<=exp_tiles;i++)) do
        pX=$((pX + 1))
        if [[ "$tile_counterX" -gt "$size_x" ]]
        then
            tile_counterX=0
            pX=$startX
            pY=$((pY + 1))
        fi
        tile_counterX=$((tile_counterX + 1))
        GetTileIndex "$pX" "$pY"
        pI=$TileIndex

        if [[ "$pI" -gt "-1" ]] #TODO: also add check for maximum tile index (also in render.sh)
        then
            #also explode out of map since DamageBlock does the check for us
            DamageBlock "$pI" 20
            #SendChat "damage index $pI"
        fi
    done
    AddSmoke "$x" "$y" "$r"
}
