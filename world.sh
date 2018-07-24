#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4


world_sizeX=50
world_sizeY=20
world_sizeXm=$((world_sizeX - 1))
world_sizeYm=$((world_sizeY - 1))

function SpawnGold {
    local Ymax=$(( world_sizeYm - 4 ))
    local rand_x=$(( $RANDOM % world_sizeXm ))
    local rand_y=$(( $RANDOM % 5 + Ymax ))
    GetTileIndex $rand_x $rand_y
    SetGold $TileIndex
}

function CreateWorld {
    local i
    echo "creating world..."
    #declare -a world

    world_tiles=$((world_sizeX * world_sizeY - 1))

    for ((i=0;i<=world_tiles;i++)) do
        world[$i]="_"
    done

    echo "adding tiles..."

    local x
    local y
    local RandShieldX=$(( $RANDOM % world_sizeXm ))
    for ((y=0;y<world_sizeY;y++)) do
        if [[ "$y" -lt "10" ]]
        then
            if [[ "$y" == "9" ]]
            then
                GetTileIndex $RandShieldX $y
                SetShield $TileIndex
            fi
        else
            for ((x=0;x<world_sizeX;x++)) do
                local r=$(( $RANDOM % 12 ))
                if [[ "$r" -gt "2" ]]
                then
                    GetTileIndex $x $y
                    SetBlock $TileIndex
                    GetLowerIndex_Y $TileIndex
                    if [[ "${world[$LowerIndex_Y]}" == "_" ]]
                    then
                        if [[ "$r" -gt "5" ]]
                        then
                            SetGold $LowerIndex_Y
                        fi
                    fi
                fi
            done
        fi
    done

#    for ((i=0;i<200;i++)) do
#        SpawnGold
#    done

    clear
}
   
