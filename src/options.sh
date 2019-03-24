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
            tput bold
            echo "» ${aOptionName[$i]} «"
            tput sgr0
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

AddOption "render distance" ConRenderdist
AddOption "render mode" ConRenderMode
AddOption "username" ConUsername
AddOption "multiplayer" ConMultiplayer
AddOption "quit" ConQuit

function ConRenderdist {
    read -p "Renderdistance: " render_dist
}

function ConRenderMode {
    read -p "Render Mode 3=chunk 4=file q=quit: " render_mode
    if [[ "$render_mode" == "q" ]]
    then
        OptionsMain
    elif [[ "$render_mode" != "3" ]] && [[ "$render_mode" != "4" ]]
    then
        echo "invalid mode valid=3,4,q"
        ConRenderMode
    fi
    SaveWorldToFile
}

function ConUsername {
    # UsernameMain
    read -p "Username: " username
}

function ConMultiplayer {
  local server_ip
  if [ "$IsNcSupport" == "0" ]
  then
    SendChat "netcat is wrong version or not installed"
    return
  fi
  read -p "server ip: " server_ip
  ConnectToServer $server_ip
}

function ConQuit {
    exit
}
