#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

source render.sh
source debug.sh
source world.sh
source game.sh
source bullet.sh
source bot.sh
source cmd.sh
source chat.sh
source gold.sh
source shield.sh

echo -n -e "\033]0;chidraqul4\007"

LeftHand="_"
RightHand="_"
IsLeftHand=0
IsRightHand=0
Air="O"
TotalTicks=0
gold=0
bhp=10
hp=$bhp
hp_str="[+]"
posX=0
posY=0
spawnX=0
spawnY=0
skin="#"
kill_skin="a"
block="_"
render_dist=6
is_debug=0
IsHUD=0
ShowFullChat=0
AimDir=1
aPrevPosTime=()
aPrevPos=()
history_len=10
IsTail=0
#JUMPS
IsJump=0
HasDoubleJump=1
TilesJumped=0
MaxJump=4
IsGrounded=0
#BULLETS
aBulletIndex=() #tileindex int
aBulletDir=()   #-1 and 1
aBulletAlive=() #bool
aBulletTick=()  #alive ticks
AliveBullets=0
BulletLifetime=20
#BOTS
aBotIndex=()
aBotLastIndex=()
aBotAlive=()
MAX_BOTS=10
botskin="◊"
BotWalked=0
BotDir=1


function UnsetRightHand {
    SetRightHand "_"
    IsRightHand=0
    SendChat "RECHTS $IsRightHand"
}

function UnsetLeftHand {
    SetLeftHand "_"
    IsLeftHand=0
}

function SetRightHand {
    if [[ "$AimDir" == "1" ]]
    then
        RightHand="$1"
        IsRightHand=1
    else
        LeftHand="$1"
        IsLeftHand=1
    fi
}

function SetLeftHand {
    if [[ "$AimDir" == "-1" ]]
    then
        RightHand="$1"
        IsRightHand=1
    else
        LeftHand="$1"
        IsLeftHand=1
    fi
}

function AddTail {
    if [[ "$IsTail" == "1" ]]
    then
        world[${aPrevPosTime[0]}]="+"
        world[${aPrevPosTime[$history_len]}]="_"
    else
        world[${aPrevPosTime[0]}]="_"
    fi
}

function UpdatePosHistory {
    local next
    local i
    # Time based history
    for ((i=$history_len;i>0;i--)) do
        next=$((i - 1))
        aPrevPosTime[$i]=${aPrevPosTime[$next]}
    done
    aPrevPosTime[0]=$1
    # Change based history
    if [[ "$1" == "${aPrevPos[0]}" ]]
    then
        return
    fi
    for ((i=$history_len;i>0;i--)) do
        next=$((i - 1))
        aPrevPos[$i]=${aPrevPos[$next]}
        #printf "${aPrevPos[$i]}[$i] <- ${aPrevPos[$next]}[$next] \n" #debug delete me
    done
    aPrevPos[0]=$1
}

function ShowHistory {
    local i
    clear
    echo "time | change"
    for ((i=0;i<=history_len;i++)) do
        echo "[$i] ${aPrevPosTime[$i]} ${aPrevPos[$i]}"
    done


    read -n 1 -s -p ""
}

function damage {
    hp=$((hp - 1))
    if [[ "$hp" == "0" ]]
    then
        die
    fi
}

function die {
    hp=$bhp
    spawn
}

function spawn {
    posX=$spawnX
    posY=$spawnY
}

function GameOver {
    clear
    echo ""
    echo ""
    echo "GAME OVER"
    echo ""
    read -n 1 -s -p ""

    die
    skin="#"
    kill_skin="a"
    block="_"
    CreateWorld
    GameTick
}

function options {
    read -p "Renderdistance: " render_dist
    GameTick
}

function GetHigherIndex_Y {
    #keep in mind we start from the top
    #--> Higher Y == lower visual
    local paraX=$1
    local paraY=$2
    local paraY=$((paraY + 1))
    GetTileIndex $paraX $paraY
    HigherIndex_Y=$((TileIndex))
}

function GetLowerIndex_Y {
    #keep in mind we start from the top
    #--> Lower Y == higher visual
    local paraX=$1
    local paraY=$2
    local paraY=$((paraY - 1))
    GetTileIndex $paraX $paraY
    LowerIndex_Y=$((TileIndex))
}

function GetTileIndex {
    local paraX=$1
    local paraY=$2
    TileIndex=$((world_sizeX * paraY + paraX))
}

function GetTileIndexSave { #dropping weird errors
    local paraX=$1
    local paraY=$2
    TileIndex=-1
    if [[ "$paraX" -lt "0" ]] || [[ "$paraX" -gt "$world_sizeXm" ]]
    then
        return
    elif [[ "$paraY" -lt "0" ]] || [[ "$paraY" -gt "$world_sizeYm" ]]
    then
        return
    fi
#    if [[ "$paraX" -lt "0" ]] || [[ "$paraX" -gt "$world_sizeXm" ]]
#    then
#        return
#    elif [[ "$paraY" -lt "0" ]] || [[ "$paraY" -gt "$world_sizeYm" ]]
#    then
#        return
#    fi
    TileIndex=$((world_sizeX * paraY + paraX))
}

function PrintFrame {
    pFrame=()
    PrintTopHUD
    CreateGameChunk
    PrintBotHUD
    clear
    printf "$pFrame"
}

function CreateHPstr {
    local i
    hp_str="["
    for ((i=0;i<bhp;i++)) do
        if [[ "$i" -lt "$hp" ]]
        then
            hp_str+="+"
        else
            hp_str+=" "
        fi
    done
    hp_str+="]"
}

function PrintTopHUD {
    if [[ "$IsHUD" == "1" ]]
    then
        #rand=$(( $RANDOM % 10 + 60 ))
        #pFrame+="fps: $rand\n\n"
        pFrame+="tick: $TotalTicks\n"
    fi
}

function PrintBotHUD {
#    echo ""
#    echo "pos:  $posX|$posY"
#    echo "world: $world_sizeX x $world_sizeY tiles $world_tiles"
#    echo "render distance: $render_dist"
#    echo "<debug> f $p_from t $p_to pindex $PlayerTileIndex"
#    echo "'t' test 'o' options 'x' eXit 'w''a''s''d' move"

    if [[ "$IsHUD" == "1" ]]
    then
        pFrame+="\n"
        pFrame+="pos:  $posX|$posY pindex: $PlayerTileIndex \n"
        pFrame+="world: $world_sizeX x $world_sizeY tiles $world_tiles\n"
        pFrame+="bot[0] Alive: ${aBotAlive[0]} \n"
        pFrame+="IsLeftHand: $IsLeftHand IsRightHand: $IsRightHand"
        #pFrame+="render distance: $render_dist\n"
        #pFrame+="AimDir: $AimDir \n"
        #pFrame+="IsGrounded: $IsGrounded AliveBullets: $AliveBullets \n"
    elif [[ "$IsHUD" == "2" ]]
    then
        CreateHPstr
        pFrame+="\n"
        pFrame+="$hp_str \n"
        pFrame+="gold: $gold"
    fi
    PrintChat $ShowFullChat
}

function DoJump {
    if [[ "$HasDoubleJump" == "1" ]]
    then
        if [[ "$IsGrounded" == "1" ]]
        then
            IsJump=1
            TilesJumped=0
        else #double jump in air
            IsJump=1
            TilesJumped=2
            HasDoubleJump=0
        fi
    fi
}

function SwapHands {
    local slh
    slh=$LeftHand
    LeftHand=$RightHand
    RightHand=$slh
    slh=$IsLeftHand
    IsLeftHand=$IsRightHand
    IsRightHand=$slh
}

function MoveRight {
    local OldAimDir
    OldAimDir=$AimDir
    AimDir=1
    if [[ "$OldAimDir" != "$AimDir" ]]
    then
        SwapHands
    fi
    posX=$((posX + 1))
}

function MoveLeft {
    local OldAimDir
    OldAimDir=$AimDir
    AimDir=-1
    if [[ "$OldAimDir" != "$AimDir" ]]
    then
        SwapHands
    fi
    posX=$((posX - 1))
}

function GameTick {
    while true;
    do
        sleep 0.01

        stty -icanon time 0 min 0
        read -s input

        if [ "$input" = "a" ] && [ "$posX" -gt 0 ]; then
            MoveLeft
        elif [[ "$input" = "d" && "$posX" -lt "$world_sizeXm" ]]; then
            MoveRight
        elif [ "$input" = "w" ] && [ "$posY" -gt 0 ]; then
            #posY=$((posY - 1))
            DoJump
        elif [ "$input" = "s" ] && [ "$posY" -lt "$world_sizeYm" ]; then
            posY=$((posY + 1))
        elif [ "$input" = "o" ]; then
            stty sane
            clear
            options
        elif [ "$input" = "k" ]; then
            die
        elif [ "$input" = "q" ]; then
            ShowFullChat=1
        elif [ "$input" = "b" ]; then
            damage
            AddBot $PlayerTileIndex
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

        tmod=$((TotalTicks % 20))
        if [[ "$tmod" == "0" ]]
        then
            SlowTick
        fi
        BulletTick
        AddTail
        GameLogic
        SetPlayer
        BotTick
        CollectGold $PlayerTileIndex
        CollectShield $PlayerTileIndex
        PrintFrame
        let "TotalTicks++"
    done
}

function SlowTick {
    ShowFullChat=0
    ChatTick
}

function SetPlayer {
    #GetTileIndex $posX $posY
    #world[$TileIndex]="$skin"
    SetTileXY $posX $posY $skin
    PlayerTileIndex=$TileIndex
    PlayerTileIndexL=$((PlayerTileIndex - 1))
    PlayerTileIndexR=$((PlayerTileIndex + 1))
    UpdatePosHistory $PlayerTileIndex
}

function ClearTileIndex {
    #parameter 1=Index
    #parameter 2=TileToClear
    #parameter 3=ClearTile
    #This func is used to remove past
    #postions of moving tiles
    #it only overrides if the $2 tile is found
    if [[ "${world[$1]}" == "$2" ]]
    then
        world[$1]=$3
    fi
}

function SetTileXY {
    #parameter 1=X
    #parameter 2=Y
    #parameter 3=Value
    GetTileIndex $1 $2
    SetTileSave $TileIndex $3
}

function SetTileIndex {
    #parameter 1=Index
    #parameter 2=Value
    SetTileSave $1 $2
}

function SetTileSave {
    #parameter 1=TileIndex
    #parameter 2=Value
    if [[ "$1" -gt "0" ]]
    then
        if [[ "${world[$1]}" == "_" ]]
        then
            world[$1]="$2"
        else
            # don't overwrite
            test
        fi
    fi
}

#TODO: remove this debug message
#echo "sizeX: $world_sizeX"
#echo "Xm: $world_sizeXm"
#echo "sizeY: $world_sizeY" 
#echo "Ym: $world_sizeYm"
#
#
#read -n 1 -s -p ""

CreateWorld
GameTick

