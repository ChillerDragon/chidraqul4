#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

aGold=()

function SetGold {
    world[$1]="$"
    aGold[$1]=1
}

function CollectGold {
    if [[ "${aGold[$1]}" == "1" ]]
    then
        let "gold++"
        SendChat "[+] collected gold \$\$\$"
        aGold[$1]=0
    fi
}
