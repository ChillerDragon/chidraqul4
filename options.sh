#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

aOptionName=()
aOptionFunc=()
NumOptions=0
NumOptionsM=0
SelectedOpt=0

function AddOption {
    aOptionName[$NumOptions]=$1
    aOptionFunc[$NumOptions]=$2
    NumOptions=$((NumOptions + 1))
    NumOptionsM=$((NumOptions - 1))
}

function ListOptions {
    local i
    clear
    echo "[ OPTIONS ]"
    echo "press w,s to navigate e to select and q to quit."
    echo "---------------"
    for ((i=0;i<NumOptions;i++)) do
        if [[ "$i" == "$SelectedOpt" ]]
        then
            echo "» ${aOptionName[$i]} «"
        else
            echo "  ${aOptionName[$i]}"
        fi
    done
}

function SelectOption {
    clear
    ${aOptionFunc[$SelectedOpt]}
    GameTick
}

function PrevOption {
    if [[ "$SelectedOpt" -gt "0" ]]
    then
        SelectedOpt=$((SelectedOpt - 1))
    fi
}

function NextOption {
    if [[ "$SelectedOpt" -lt "$NumOptionsM" ]]
    then
        SelectedOpt=$((SelectedOpt + 1))
    fi
}

function OptionsInput {
    local inp
    read -n 1 -s -p "" inp
    if [[ "$inp" == "w" ]]; then
        PrevOption
    elif [[ "$inp" == "s" ]]; then
        NextOption
    elif [[ "$inp" == "e" ]]; then
        SelectOption
    elif [[ "$inp" == "q" ]]; then
        GameTick
    elif [[ "$inp" == "x" ]]; then
        GameTick
    fi
    OptionsMain
}

function OptionsMain {
    ListOptions
    OptionsInput
}

AddOption "renderdistance" ConRenderdist
AddOption "sample opt1" ConSampleopt1
AddOption "sample opt2" ConSampleopt2

function ConRenderdist {
    read -p "Renderdistance: " render_dist
}

function ConSampleopt1 {
    read -p "sampleopt1: "
}

function ConSampleopt2 {
    read -p "sampleopt2: "
}
