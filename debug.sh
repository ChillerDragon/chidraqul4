#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function print_dbg {
    if [[ "$arg_debug" == "1" ]]
    then
        printf "$1\n"
    fi
}

function testarea2 {
    local iks
    local yps
    read -p "index " tindex
    clear
    echo ""
    echo "-"
    printf "${world[$tindex]}"
    echo ""
    echo "-"
    echo ""
    read -n 1 -s -p ""
    GameTick
}

function testarea {
    local iks
    local yps
    read -p "x " iks
    read -p "y " yps
    clear
    echo ""
    echo "-"
    GetTileIndex $iks $yps
    printf "Index: $TileIndex Value [${world[$TileIndex]}]"
    echo ""
    echo "-"
    echo ""
    read -n 1 -s -p ""
    GameTick
}

function test_set_tile {
    local tile
    local iks
    local yps
    read -p "x " iks
    read -p "y " yps
    read -p "tile " tile
    SetTileSave $iks $yps $tile
    clear
    echo ""
    echo "-"
    GetTileIndex $iks $yps
    printf "Index: $TileIndex Value [${world[$TileIndex]}]"
    echo ""
    echo "-"
    echo ""
    read -n 1 -s -p ""
    GameTick
}
