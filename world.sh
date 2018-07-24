#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4


world_sizeX=500
world_sizeY=20
world_sizeXm=$((world_sizeX - 1))
world_sizeYm=$((world_sizeY - 1))

function SpawnGold {
    local Ymax=$(( world_sizeYm - 4 ))
    rand_x=$(( $RANDOM % world_sizeXm ))
    rand_y=$(( $RANDOM % 5 + Ymax ))
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

    #add some obstacelz to the world
    #GetTileIndex 10 10
    #world[$TileIndex]="t"

    SetShield 19015

    for ((i=0;i<200;i++)) do
        SpawnGold
    done

    clear
}
   
