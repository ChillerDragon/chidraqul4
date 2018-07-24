#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

is_collision=0

function GameLogic {
    #GetLowerIndex_Y $posX $posY
    CheckGrounded
    Gravity
}

function CheckCollision {
    IsBlock $1
    if [[ "$is_block" == "1" ]]
    then
        is_collision=1
        return 1
    fi
    is_collision=0
    return 0
}

function Gravity {
    if [[ "$IsJump" == "1" ]]
    then
        let "TilesJumped++"
        if [[ "$posY" -gt "0" ]]
        then
            NewY=$((posY - 1))
            GetTileIndex $posX $NewY
            CheckCollision $TileIndex
            if [[ "$is_collision" == "1" ]]
            then
                IsJump=0 #Touch the roof -> stop jump
            else
                posY=$NewY
            fi
        fi
        
        if [[ "$TilesJumped" -gt "$MaxJump" ]]
        then
            IsJump=0
        fi
    elif [[ "$posY" -lt "$world_sizeYm" ]]
    then
        GetHigherIndex_Y $posX $posY
        CheckCollision $HigherIndex_Y
        if [[ "$is_collision" == "1" ]]
        then
            IsGrounded=1 #TODO: Move this to CheckGrounded()
            HasDoubleJump=1
        else
            let "posY++"
        fi
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
