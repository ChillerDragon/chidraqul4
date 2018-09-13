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
source block.sh
source loading.sh
source bomb.sh
source options.sh
source keypresses.sh
source username.sh

echo -n -e "\033]0;chidraqul4\007"

LeftHand=$world_air
RightHand=$world_air
IsLeftHand=0
IsRightHand=0
CurrentWeapon=1
#OOM1="~" #OutOfMap
#OOM2="@" #OutOfMap
OOM1=" "
OOM2=" "
TotalTicks=0
gold=0
blocks=0
bhp=10
hp=$bhp
hp_str="[+]"
posX=0
posY=0
spawnX=0
spawnY=0
skin="#"
kill_skin="a"
render_dist=6
is_debug=0
IsHUD=2
ShowFullChat=0
AimDir=1
AimDirY=0
AimPos=0
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
#ARGS
arg_debug=0


function SetArgs {
    arg_debug=$1
}

function UnsetRightHand {
    SetRightHand "$world_air"
    IsRightHand=0
}

function UnsetLeftHand {
    SetLeftHand "$world_air"
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
        world[${aPrevPosTime[$history_len]}]=$world_air
    else
        world[${aPrevPosTime[0]}]=$world_air
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
    CreateWorld
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
        pFrame+="AimPos: $AimPos AimDirX: $AimDir AimDirY: $AimDirY\n"
        #pFrame+="bot[0] Alive: ${aBotAlive[0]} \n"
        #pFrame+="IsLeftHand: $IsLeftHand IsRightHand: $IsRightHand"
        #pFrame+="render distance: $render_dist\n"
        #pFrame+="AimDir: $AimDir \n"
        #pFrame+="IsGrounded: $IsGrounded AliveBullets: $AliveBullets \n"
    elif [[ "$IsHUD" == "2" ]]
    then
        CreateHPstr
        pFrame+="\n"
        pFrame+="$hp_str \n"
        pFrame+="gold: $gold blocks: $blocks\n"
    fi
    PrintChat $ShowFullChat
}

function DoSetBlock {
    if [[ "$blocks" -gt "0" ]]
    then
        SetBlock $AimPos
        blocks=$((blocks - 1))
    fi
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

function CheckNewX {
    local NewX
    NewX=$1
    GetTileIndex $NewX $posY
    CheckCollision $TileIndex
    if [[ "$is_collision" == "1" ]]
    then
        return
    else
        posX=$NewX
    fi
}

function MoveRight {
    local OldAimDir
    local NewX
    OldAimDir=$AimDir
    AimDir=1
    if [[ "$OldAimDir" != "$AimDir" ]]
    then
        SwapHands
    fi
    NewX=$((posX + 1))
    CheckNewX $NewX
}

function MoveLeft {
    local OldAimDir
    OldAimDir=$AimDir
    AimDir=-1
    if [[ "$OldAimDir" != "$AimDir" ]]
    then
        SwapHands
    fi
    NewX=$((posX - 1))
    CheckNewX $NewX
}

function GetAimPos { #TODO: if aim is out of world (left side) it aims at world border right side
    if [[ "$AimDirY" == "0" ]]
    then
        AimPos=$((PlayerTileIndex + AimDir))
    elif [[ "$AimDirY" == "-1" ]]
    then
        GetHigherIndex_Y $PlayerTileIndex
        AimPos=$((HigherIndex_Y + AimDir))
    elif [[ "$AimDirY" == "1" ]]
    then
        GetLowerIndex_Y $PlayerTileIndex
        AimPos=$((LowerIndex_Y + AimDir))
    fi
}

function GameTick {
    while true;
    do
        sleep 0.01

        KeyPresses

        tmod=$((TotalTicks % 20))
        if [[ "$tmod" == "0" ]]
        then
            SlowTick
        fi
 
        GetAimPos
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
    BombTick
    ClearDeadBullets
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
        if [[ "${world[$1]}" == "$world_air" ]]
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

SetArgs $1
CreateWorld
GameTick

