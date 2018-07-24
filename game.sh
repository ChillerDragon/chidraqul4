#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function GameLogic {
    #GetLowerIndex_Y $posX $posY
    CheckGrounded

    Gravity
}

function Gravity {
    if [[ "$IsJump" == "1" ]]
    then
        let "TilesJumped++"
        if [[ "$posY" -gt "0" ]]
        then
            let "posY--"
        fi
        
        if [[ "$TilesJumped" -gt "$MaxJump" ]]
        then
            IsJump=0
        fi
    elif [[ "$posY" -lt "$world_sizeYm" ]]
    then
        let "posY++"
    fi
}

function CheckGrounded {
    IsGrounded=0
    if [[ "$posY" == "$world_sizeYm" ]]
    then
        IsGrounded=1
        HasDoubleJump=1
    fi
}
