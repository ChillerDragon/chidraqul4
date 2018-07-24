#!/bin/bash
# Copyright 2018 ChillerDragon. All Rights Reserved.
# Get the full official release at:
# https://github.com/ChillerDragon/chidraqul4

#SIZE
world_sizeX=50
world_sizeY=20
world_sizeXm=$((world_sizeX - 1))
world_sizeYm=$((world_sizeY - 1))
world_tiles=$((world_sizeX * world_sizeY - 1))
#TEXTURE
world_air=" "
world_floor="_"

function SpawnGold {
    local Ymax=$(( world_sizeYm - 4 ))
    local rand_x=$(( $RANDOM % world_sizeXm ))
    local rand_y=$(( $RANDOM % 5 + Ymax ))
    GetTileIndex $rand_x $rand_y
    SetGold $TileIndex
}

function DeleteWorld {
    local i
    for ((i=0;i<=world_tiles;i++)) do
        world[$i]="$world_air"
        aGold[$i]=0
        aShield[$i]=0
        aBlock[$i]=0
        aBlockHP[$i]=0
        #aBulletIndex[$i]=0
        #aBulletAlive[$i]=0
        #aBulletTick[$i]=0
    done
}

function GenerateTiles {
    local x
    local y
    local line_y=$(( world_sizeY / 2 ))
    local line_y_dir=$(( $RANDOM % 3 ))
    local is_change=0
    local r=0
    for ((x=0;x<world_sizeX;x++)) do
        print_dbg "[$x/$world_sizeX] y: $line_y"
        line_y_dir=$(( $RANDOM % 3 - 1 ))
        is_change=$(( $RANDOM % 2 ))
        if [[ "$is_change" == "1" ]]
        then
            line_y=$(( line_y + line_y_dir ))
        fi
        for ((y=0;y<world_sizeY;y++)) do
            GetTileIndex $x $y
            if [[ "$line_y" -lt "$y" ]]
            then
                SetBlock $TileIndex
            elif [[ "$line_y" == "$y" ]] #top line on the world
            then
                r=$(( $RANDOM % 15 ))
                if [[ "$r" == "1" ]]
                then
                    SetShield $TileIndex
                elif [[ "$r" -gt "10" ]]
                then
                    SetGold $TileIndex
                fi
            fi
        done
    done
}

function CreateWorld {
    local i
    echo "deleting world..."
    DeleteWorld
    echo "creating world..."
    #declare -a world


    for ((i=0;i<=world_tiles;i++)) do
        #LoadingFullScreen $i $world_tiles #works but eats too much ressources
        world[$i]="$world_air"
    done

    echo "adding tiles..."

    GenerateTiles
#    for ((i=0;i<200;i++)) do
#        SpawnGold
#    done

    clear
}

function CreateRandStuff { #TODO: old block and money creation (bad)
    local x
    local y
    local RandShieldX=$(( $RANDOM % world_sizeXm ))
    for ((y=0;y<world_sizeY;y++)) do
        if [[ "$y" -lt "10" ]]
        then
            if [[ "$y" == "9" ]]
            then
                GetTileIndex $RandShieldX $y
                SetShield $TileIndex
            fi
        else
            for ((x=0;x<world_sizeX;x++)) do
                local r=$(( $RANDOM % 12 ))
                if [[ "$r" -gt "2" ]]
                then
                    GetTileIndex $x $y
                    SetBlock $TileIndex
                    GetLowerIndex_Y $TileIndex
                    if [[ "${world[$LowerIndex_Y]}" == "_" ]]
                    then
                        if [[ "$r" -gt "5" ]]
                        then
                            SetGold $LowerIndex_Y
                        fi
                    fi
                fi
            done
        fi
    done
}
