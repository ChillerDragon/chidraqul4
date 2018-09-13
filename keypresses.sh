#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function KeyPresses {
        stty -icanon time 0 min 0
        read -s input

        if [ "$input" = "a" ] && [ "$posX" -gt 0 ]; then
            MoveLeft
            AimDirY=0
        elif [[ "$input" = "d" && "$posX" -lt "$world_sizeXm" ]]; then
            MoveRight
            AimDirY=0
        elif [ "$input" = "w" ] && [ "$posY" -gt 0 ]; then
            #posY=$((posY - 1))
            DoJump
            AimDirY=1
            AimDir=0
        elif [ "$input" = "s" ] && [ "$posY" -lt "$world_sizeYm" ]; then
            #posY=$((posY + 1))
            AimDirY=-1
            AimDir=0
        elif [ "$input" = "o" ]; then
            stty sane
            clear
            options
        elif [ "$input" = "k" ]; then
            die
        elif [ "$input" = "q" ]; then
            ShowFullChat=1
        elif [ "$input" = "b" ]; then
            DoSetBlock
            #damage
            #AddBot $PlayerTileIndex
        elif [ "$input" = "h" ]; then
            if [[ "$IsHUD" == "0" ]]
            then
                IsHUD=1
            elif [[ "$IsHUD" == "1" ]]
            then
                IsHUD=2
            else
                IsHUD=0
            fi
        elif [ "$input" = "t" ]; then
            stty sane
            ShowFullChat=1
            PrintFrame #rerender frame to show chat
            ChatCmd
        elif [ "$input" = "r" ]; then
            stty sane
            clear
            CreateWorld
        elif [ "$input" = "p" ]; then
            #local r=$((PlayerTileIndex + AimDir))
            #DamageBlock $AimPos 20
            #AddBomb $posX $posY
            #Explode $posX $posY 2
            AddBullet $PlayerTileIndex $AimDir
#            if [ "$skin" = "#" ]
#            then
#                skin="a"
#                kill_skin="#"
#            else
#                skin="#"
#                kill_skin="a"
#            fi
        elif [ "$input" = "x" ]; then
            stty sane
            clear
            echo "good game."
            exit
        fi

        stty sane
}
