#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function LoadingFullScreen {
    local max=$2
    local status=$(( $1 * 10 ))
    local bar="["
    local mapped_status=$((status / max))
    local i
    for ((i=0;i<10;i++)) do
        if [[ "$i" -lt "$mapped_status" ]]
        then
            bar+=":"
        else
            bar+=" "
        fi
    done
    bar+="]"
    clear
    echo "$bar"
    echo "$mapped_status %"
}
