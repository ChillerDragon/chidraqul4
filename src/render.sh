#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

render_mode="3"

function AddToFrame() {
    pFrame="${pFrame}$1"
}

function PrintFrame {
    # rendering the frames from a file is much faster but it is not 100% done yet
    if [[ "$render_mode" == "4" ]]
    then
        FileMapRender
    else # render mode 3 (chunks)
        pFrame=""
        PrintTopHUD
        CreateGameChunk
        PrintBotHUD
        clear
        printf "$pFrame"
    fi
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
        #AddToFrame "fps: $rand\n\n"
        AddToFrame "tick: $TotalTicks\n"
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
        AddToFrame "\n"
        AddToFrame "pos:  $posX|$posY pindex: $PlayerTileIndex \n"
        AddToFrame "world: $world_sizeX x $world_sizeY tiles $world_tiles\n"
        AddToFrame "AimPos: $AimPos AimDirX: $AimDir AimDirY: $AimDirY\n"
        AddToFrame "network: $NetRead netcatsupport: $IsNcSupport\n"
        #AddToFrame "bot[0] Alive: ${aBotAlive[0]} \n"
        #AddToFrame "IsLeftHand: $IsLeftHand IsRightHand: $IsRightHand"
        #AddToFrame "render distance: $render_dist\n"
        #AddToFrame "AimDir: $AimDir \n"
        #AddToFrame "IsGrounded: $IsGrounded AliveBullets: $AliveBullets \n"
    elif [[ "$IsHUD" == "2" ]]
    then
        CreateHPstr
        AddToFrame "\n"
        AddToFrame "$hp_str \n"
        AddToFrame "gold: $gold blocks: $blocks\n"
    fi
    PrintChat $ShowFullChat
}

# not finished yet (features missing) but performance seems way better
function FileMapRender { #PrintFrame4
    local x
    local y
    x=$((posX - 1))
    y=$((posY + 1))
    clear
    cat .chidraqul_tmp/world.txt
    tput cup $y $x
    printf "$skin"
    # tput cup 2 $NetRead
    # printf "$botskin"
    tput cup 0 0
}

function CreateGameChunk { #PrintFrame3
    local i
    local p_startX=$((posX - render_dist * 2))
    local p_startY=$((posY - render_dist))
    local pF_index_X=$((p_startX - 1))
    local pF_index_Y=$p_startY
    local render_tiles=$(((render_dist * 2) * (render_dist * 4) - 1)) #2:4 colum/row rate to get nice resolution
    local render_sizeX=$((render_dist * 4))
    local render_sizeY=$((render_dist * 2))

    local IsAir=0
    local tile_counterX=0


    for ((i=0;i<=render_tiles;i++)) do
        IsAir=0
        let "pF_index_X++" 

        if [[ "$tile_counterX" -ge "$render_sizeX" ]]
        then
            tile_counterX=0
            AddToFrame "\n"
            pF_index_X=$p_startX
            let "pF_index_Y++"
        fi
        let "tile_counterX++"

        GetTileIndex $pF_index_X $pF_index_Y
        pF_index=$TileIndex

        if [[ "$is_debug" == "1" ]]
        then
            AddToFrame "i:$pF_index|x:$pF_index_X|y:$pF_index_Y"
        fi

        if [[ "$pF_index" -lt "0" ]]
        then
            IsAir=1
        elif [[ "$pF_index_Y" -lt "0" ]] || [[ "$pF_index_Y" -gt "$world_sizeYm" ]]
        then
            IsAir=1
        elif [[ "$pF_index_X" -lt "0" ]] || [[ "$pF_index_X" -gt "$world_sizeXm" ]]
        then
            IsAir=1
        fi

        if [[ "$IsAir" == "1" ]]
        then
            equal=$((pF_index_Y % 2))
            if [[ "$equal" == "0" ]]
            then
                equal=$((pF_index % 2))
                if [[ "$equal" == "0" ]]
                then
                    AddToFrame "$OOM2"
                else
                    AddToFrame "$OOM1"
                fi
            else
                equal=$((pF_index % 2))
                if [[ "$equal" == "0" ]]
                then
                    AddToFrame "$OOM1"
                else
                    AddToFrame "$OOM2"
                fi
            fi
    
        else
            if [[ "$pF_index" == "$PlayerTileIndexL" ]] && [[ "$IsLeftHand" == "1" ]]
            then
                AddToFrame "$LeftHand"
            elif [[ "$pF_index" == "$PlayerTileIndexR" ]] && [[ "$IsRightHand" == "1" ]]
            then
                AddToFrame "$RightHand"
            elif [[ "$pF_index" == "$AimPos" ]] && [[ "$CurrentWeapon" == "2" ]]
            then
                AddToFrame "-"
            elif [[ "$pF_index" == "$AimPos" ]] && [[ "$is_debug" == "2" ]]
            then
                AddToFrame "."
            else
                if [[ "${aBomb[$pF_index]}" == "1" ]]
                then
                    AddToFrame "$bomb"
                else
                    AddToFrame "${world[$pF_index]}"
                fi
            fi
        fi
    done
}
