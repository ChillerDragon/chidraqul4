#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

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
            pFrame+="\n"
            pF_index_X=$p_startX
            let "pF_index_Y++"
        fi
        let "tile_counterX++"

        GetTileIndex $pF_index_X $pF_index_Y
        pF_index=$TileIndex

        if [[ "$is_debug" == "1" ]]
        then
            pFrame+="i:$pF_index|x:$pF_index_X|y:$pF_index_Y"
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
                    pFrame+="$OOM2"
                else
                    pFrame+="$OOM1"
                fi
            else
                equal=$((pF_index % 2))
                if [[ "$equal" == "0" ]]
                then
                    pFrame+="$OOM1"
                else
                    pFrame+="$OOM2"
                fi
            fi
    
        else
            if [[ "$pF_index" == "$PlayerTileIndexL" ]] && [[ "$IsLeftHand" == "1" ]]
            then
                pFrame+="$LeftHand"
            elif [[ "$pF_index" == "$PlayerTileIndexR" ]] && [[ "$IsRightHand" == "1" ]]
            then
                pFrame+="$RightHand"
            else
                if [[ "${aBomb[$pF_index]}" == "1" ]]
                then
                    pFrame+="$bomb"
                else
                    pFrame+="${world[$pF_index]}"
                fi
            fi
        fi
    done
}
