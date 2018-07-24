#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

aCommandName=()
aCommandExec=()
aCommandDesc=()
NumCommands=0
CommandID=-1

function AddCmd {
#    echo "Name[$NumCommands]=$1"
#    echo "Exec[$NumCommands]=$2"
#    echo "Desc[$NumCommands]=$3"
#    echo "---------------------"
    aCommandName[$NumCommands]=$1
    aCommandExec[$NumCommands]=$2
    aCommandDesc[$NumCommands]=$3
    NumCommands=$((NumCommands + 1))
}

function GetCommandID {
    local i
    CommandID=-1
    for ((i=0;i<NumCommands;i++)) do
        if [[ "$1" == "${aCommandName[$i]}" ]]
        then
            CommandID=$i
            return
        fi
    done
}

function ShowCmds {
    local i
    clear
    for ((i=0;i<NumCommands;i++)) do
        echo "Name[$i]=${aCommandName[$i]}"
        echo "Exec[$i]=${aCommandExec[$i]}"
        echo "Name[$i]=${aCommandDesc[$i]}"
        echo "----------------------------"
    done
    read -n 1 -s -p ""
}

function ChatCmd {
    TryChat
    #read -n 1 -s -p ""
}

function TryChat {
    read -p "command: " cmd
    local plain_cmd
    local aArgs
    local IsName
    local i
    IsName=1
    plain_cmd=""
    aArgs=()
    for arg in $cmd; do
        if [[ "$IsName" == "1" ]]
        then
            IsName=0
            plain_cmd=$arg
        else
            aArgs+="$arg "
        fi
    done

    for ((i=0;i<NumCommands;i++)) do
        #echo "[i=$i]"
        if [[ "$plain_cmd" == "${aCommandName[$i]}" ]]
        then
            #this debug messages causes bad array index on next linde idk why
            #SendChat "Exec cmd: $plain_cmd exec: ${aCommandExec[$i]} index: $i arg: $aArgs"
            ${aCommandExec[$i]} $aArgs
            return
        fi
    done

    if [[ "$plain_cmd" != "" ]]
    then
        SendChat "unkown command"
    fi
}

AddCmd "help" ConHelp "shows help"
AddCmd "cmdlist" ConCmdlist "shows all commands"
AddCmd "tail" ConTail "adds a tail"
AddCmd "bazooka" ConBazooka "adds a bazooka"
AddCmd "test" ConTest "does stuff"
AddCmd "debug" ConDebug "does debug"
AddCmd "set" ConSet "set custom tile"
AddCmd "history" ConHistory "shows player history"
AddCmd "testarea" ConTestarea "debug stuff"
AddCmd "testarea2" ConTestarea2 "debug stuff"
AddCmd "bot" ConBot "shows bot status"

function ConBot {
    BotStatus
}

function ConTestarea {
    testarea
}

function ConTestarea2 {
    testarea2
}

function ConHistory {
    ShowHistory
}

function ConSet {
    test_set_tile
}

function ConBazooka {
    if [[ "$1" == "1" ]]
    then
        SetRightHand "-"
        SetLeftHand "|"
    elif [[ "$1" == "0" ]]
    then
        UnsetRightHand
        UnsetLeftHand
    else
        SendChat "get an arg u brain"
    fi
}

function ConTail {
    if [[ "$#" == "0" ]]
    then
        #no parameter --> toggle
        if [[ "$IsTail" == "1" ]]
        then
            IsTail=0
        else
            IsTail=1
        fi
        return
    fi
    
    IsTail=$1
}

function ConTest {
    clear
    echo "test failed"
    read -n 1 -s -p ""
}

function ConDebug {
    local value
    value=$1
    if [[ "$value" == "0" ]]
    then
        is_debug=0
    elif [[ "$value" == "1" ]]
    then
        is_debug=1
    else
        printf " error only debug 1/0 allowed "
        read -n 1 -s -p ""
    fi
}

function ConHelp {
    if [[ "$#" == "0" ]]
    then
        SendChat "help (commandname)"
        return
    fi

    GetCommandID "$1"
    if [[ "$CommandID" == "-1" ]]
    then
        SendChat "unkown command '$1'"
    else
        SendChat "[$1] ${aCommandDesc[$CommandID]}"
    fi
}

function ConCmdlist {
    local i
    local aCmdBuf=""
    local LastCmd=$((NumCommands - 1))
    for ((i=0;i<$NumCommands;i++)) do
        aCmdBuf+="${aCommandName[$i]}"
        if [[ "$i" == "$LastCmd" ]]
        then
            aCmdBuf+=""
        else
            aCmdBuf+=", "
        fi
    done
    SendChat "$aCmdBuf"
}
