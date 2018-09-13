#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

function KeyPresses {
        local input
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
            OptionsMain
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
            if [[ "$CurrentWeapon" == "1" ]]
            then
                DamageBlock $AimPos 20
            elif [[ "$CurrentWeapon" == "2" ]]
            then
                AddBullet $PlayerTileIndex $AimDir
            elif [[ "$CurrentWeapon" == "3" ]]
            then
                AddBomb $posX $posY
            elif [[ "$CurrentWeapon" == "4" ]]
            then
                test
            fi
            #local r=$((PlayerTileIndex + AimDir))
            #Explode $posX $posY 2
#            if [ "$skin" = "#" ]
#            then
#                skin="a"
#                kill_skin="#"
#            else
#                skin="#"
#                kill_skin="a"
#            fi
        elif [ "$input" = "0" ]; then
            CurrentWeapon=0
        elif [ "$input" = "1" ]; then
            CurrentWeapon=1
        elif [ "$input" = "2" ]; then
            CurrentWeapon=2
        elif [ "$input" = "3" ]; then
            CurrentWeapon=3
        elif [ "$input" = "4" ]; then
            CurrentWeapon=4
        elif [ "$input" = "5" ]; then
            CurrentWeapon=5
        elif [ "$input" = "6" ]; then
            CurrentWeapon=6
        elif [ "$input" = "7" ]; then
            CurrentWeapon=7
        elif [ "$input" = "8" ]; then
            CurrentWeapon=8
        elif [ "$input" = "9" ]; then
            CurrentWeapon=9
        elif [ "$input" = "x" ]; then
            stty sane
            clear
            echo "good game."
            exit
        fi

        stty sane
}
