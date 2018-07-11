#!/bin/bash
#chidraqul4 made by ChillerDragon
#all rights reserved (c) Copyrigth to ChillerDragon
#official code repository https://github.com/ChillerDragon/chidraqul4

echo -n -e "\033]0;chidraqul4\007"


posX=0
posY=0
method=0
skin="#"
kill_skin="a"
block="_"
render_dist=2
is_debug=0

function testarea2 {
    read -p "index " tindex
    clear
    echo ""
    echo "-"
    printf "${world[$tindex]}"
    echo ""
    echo "-"
    echo ""
    read -n 1 -s -p ""
    GameTick
}

function testarea {
    read -p "x " iks
    read -p "y " yps
    clear
    echo ""
    echo "-"
    GetTileIndex $iks $yps
    printf "${world[$TileIndex]}"
    echo ""
    echo "-"
    echo ""
    read -n 1 -s -p ""
    GameTick
}

function GameOver {

    clear
    echo ""
    echo ""
    echo "GAME OVER"
    echo ""
    read -n 1 -s -p ""

    posX=0
    posY=0
    method=0
    skin="#"
    kill_skin="a"
    block="_"
    render_dist=20
    CreateWorld
    GameTick
}

function ChatCmd {
    read -p "command: " cmd
    if [[ "$cmd" == "debug 1" ]]
    then
        is_debug=1
    elif [[ "$cmd" == "debug 0" ]]
    then
        is_debug=0
    elif [[ "$cmd" == "testarea2" ]]
    then
        testarea2
    elif [[ "$cmd" == "testarea" ]]
    then
        testarea
    elif [[ "$cmd" == "help" ]]
    then
        echo "debug 1, debug 0, testarea, testarea2, help, q"
        ChatCmd
    elif [[ "$cmd" == "q" ]]
    then
        GameTick
    else
        echo "unkown command 'q' to quit 'help' to help"
        ChatCmd
    fi
}

function options {
    read -p "Renderdistance: " render_dist
    GameTick

    #while true;
    #do
    #    sleep 0.01
    #    clear
    #    stty -icanon time 0 min 0
    #    read -s input
    #
    #    if [ "$input" = "w" ] && [ $posX -gt 0 ]; then
    #        posX=$((posX - 1))
    #    elif [ "$input" = "c" ]; then
    #        posX=$((posX + 1))
    #    elif [ "$input" = "q" ]; then
    #        stty sane
    #        clear
    #        GameTick
    #    elif [ "$input" = "x" ]; then
    #        stty sane
    #        clear
    #        echo "good game."
    #        exit
    #       fi
    #    stty sane
    #done
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

function CreateWorld {
    echo "creating world..."
    world_sizeX=200
    world_sizeY=500
    world_sizeXm=$((world_sizeX - 1))
    world_sizeYm=$((world_sizeY - 1))
    #declare -a world

    world_tiles=$((world_sizeX * world_sizeY - 1))

    for ((i=0;i<=world_tiles;i++)) do
        world[$i]="_"
    done

    #add some obstacelz to the world
    GetTileIndex 10 10
    world[$TileIndex]="t"

    clear
}

function PrintWorld {
    #create world string
    #if [[ "$i" -eq 100 || "$i" -eq 200 || "$i" -eq 300 || "$i" -eq 400 || "$i" -eq 500 || "$i" -eq 600 || "$i" -eq 700 || "$i" -eq 800 || "$i" -eq 900 || "$i" -eq 1000 || "$i" -eq 1100 ]]

    pWorld=()
    tile_counter=0
    #echo "tiles: $world_tiles"
    for ((i=0;i<=world_tiles;i++)) do
        if [ "$tile_counter" -ge "$world_sizeX" ]
        then
            pWorld+="\n"
            tile_counter=0
        fi

        pWorld+="${world[$i]}"
        tile_counter=$((tile_counter + 1))
    done
    printf "$pWorld"
    echo ""
}

function PrintFrame2 {

    local p2_startX=$((posX - render_dist * 2))
    local p2_startY=$((posY - render_dist))
    #GetTileIndex $p2_fromX $p2_fromY
    GetTileIndex $p2_startX $p2_startY
    local tile=$((TileIndex))
    local pF_index=$TileIndex
    local pF_index_X=$p2_startX
    local pF_index_Y=$p2_startY
    local render_tiles=$(((render_dist * 2) * (render_dist * 4))) #2:4 colum/row rate to get nice resolution
    local render_sizeX=$((render_dist * 4))
    local render_sizeY=$((render_dist * 2))


    tile_counter=0
    pFrame=()


    for ((i=0;i<=render_tiles;i++)) do


        #let "pF_index_X++" #there is a X increment needed for the world border to work
        # but idk how where and how to do it. Maybe here maybe not
        if [ "$tile_counter" -ge "$render_sizeX" ]
        then
            pFrame+="\n"
            tile_counter=0

            let "pF_index_Y++"
            GetTileIndex $pF_index_X $pF_index_Y
            pF_index=$TileIndex
        fi

        #   this makes no sense because of 2d many values are out of map effected not only these
        #   pls fix this if you get back to this technique
        if [[ "$pF_index" -lt "0" ]] #|| [[ "$pF_index_X" -gt "world_sizeX" ]]
        then
            pFrame+=" "
            let "pF_index = 0"
        fi
    
        IsAir=0
        if [[ "$pF_index_Y" -lt "0" ]] || [[ "$pF_index_Y" -gt "world_sizeY" ]]
        then
#            pFrame+=" "
#            tile_counter=$((tile_counter + 1))
#            pF_index=$((pF_index + 1))
#            continue
            IsAir=1
        fi

        if [[ "$pF_index_X" -lt "0" ]] #|| [[ "$pF_index_X" -gt "world_sizeX" ]]
        then
#            pFrame+=" "
#            tile_counter=$((tile_counter + 1))
#            pF_index=$((pF_index + 1)) #2:4 colum/row rate to get nice resolution
#            continue
            IsAir=1
        fi

        if [[ "$is_debug" == "1" ]]
        then
            pFrame+="i:$pF_index|x:$pF_index_X|y:$pF_index_Y"
        fi
        if [[ "$IsAir" == "1" ]]
        then
            pFrame+=" "
        else
            pFrame+="${world[$pF_index]}"
        fi
        tile_counter=$((tile_counter + 1))
        pF_index=$((pF_index + 1))

    done
    printf "$pFrame"
    echo ""
}

function PrintFrame {
    pFrame=()
    tile_counter=0
    #local p_from=$((GetPlayerTileIndex - render_dist * world_sizeY))
    #local p_to=$((GetPlayerTileIndex + render_dist * world_sizeY))
    # leave em local only made global for debugging
    p_fromX=$((posX - render_dist))
    p_fromY=$((0))
    GetTileIndex $p_fromX $p_fromY
    p_from=$((TileIndex))

    p_toX=$((posX + render_dist))
    p_toY=$((world_sizeY))
    GetTileIndex $p_toX $p_toY
    p_to=$((TileIndex))

    if [ "$p_from" -lt 0 ]
    then
        p_from=0
    fi
    if [ "$p_to" -gt "$world_tiles" ]
    then
        p_to=$((world_tiles))
    fi

    for ((i=p_from;i<=p_to;i++)) do
        if [[ "$i" -lt 0 || "$i" -gt "$world_tiles" ]]
        then
    # dont add tiles because in 2d its messed up
    #       pFrame+=" "
            pFrame+=""
        else
            if [ "$tile_counter" -ge "$world_sizeX" ]
            then
                pFrame+="\n"
                tile_counter=0
            fi

            pFrame+="${world[$i]}"
            tile_counter=$((tile_counter + 1)) #keep it in else to ignore out of map tiles
        fi
    done
    printf "$pFrame"
    echo ""
}

function CreateWorldOld {
    #read -p "world sizeX: " world_sizeX
    echo "creating world..."
    world_sizeX=100
    world_sizeY=3
    world_sizeXm=$((world_sizeX - 1))
    world_sizeYm=$((world_sizeY - 1))
    #declare -A world #makes stuff invisible

    for ((y=0;y<=world_sizeY;y++)) do
        for ((x=0;x<=world_sizeX;x++)) do
            world[$x,$y]="_"
        done
    done


    #c=0
    #while [  $c -lt $world_sizeX ]; do
    #world[$c]="$block"
    #c=$((c + 1))
    #done
    world[5,1]="T"
    world[2,3]="x"
    clear
}

function CreateChunkOld {
    Chunk=()
    posX=$1
    posY=$2
    cfrom=$((pos - render_dist))
    cto=$((pos + render_dist))

    for ((y=0;y<=world_sizeY;y++)) do
        for ((x=$cfrom;x<=$cto;x++)) do
            if [ "$x" = "$posX" ] && [ "$y" = "$posY" ]
            then
                Chunk+="a"
            elif [ $x -lt 0 ]
            then
                Chunk+=" "
            else
                Chunk+="${world[$x,$y]}"
            fi
        done
        Chunk+="\n"
    done
}

function GameTick {
    while true;
    do
        sleep 0.01
        clear
        rand=$(( $RANDOM % 10 + 60 ))
        #tophud
        echo "fps: $rand"
        echo ""

        stty -icanon time 0 min 0
        read -s input

        if [ "$input" = "a" ] && [ "$posX" -gt 0 ]; then
            posX=$((posX - 1))
        elif [[ "$input" = "d" && "$posX" -lt "$world_sizeXm" ]]; then
            posX=$((posX + 1))
        elif [ "$input" = "w" ] && [ "$posY" -gt 0 ]; then
            posY=$((posY - 1))
        elif [ "$input" = "s" ] && [ "$posY" -lt "$world_sizeYm" ]; then
            posY=$((posY + 1))
        elif [ "$input" = "o" ]; then
            stty sane
            clear
            options
        elif [ "$input" = "t" ]; then
            stty sane
            ChatCmd
        elif [ "$input" = "r" ]; then
            stty sane
            clear
            CreateWorld
        elif [ "$input" = "p" ]; then
            if [ "$skin" = "#" ]
            then
                skin="a"
                kill_skin="#"
            else
                skin="#"
                kill_skin="a"
            fi
        elif [ "$input" = "x" ]; then
            stty sane
            clear
            echo "good game."
            exit
        fi

        stty sane

        GetTileIndex $posX $posY
        PlayerTileIndex=$TileIndex
        world[$TileIndex]="$skin"
        echo ""
        PrintFrame2
    #   PrintWorld

    #    CreateChunk $posX $posY
    #    printf "$Chunk"


    #    world[$posX]="#"

    #    c=0
    #    while [  $c -lt $chunk_size ]; do
    #        printf "${world[$c]}"
    #        c=$((c + 1))
    #    done

        #subhud
        echo ""
        echo "pos:  $posX|$posY"
        echo "world: $world_sizeX x $world_sizeY tiles $world_tiles"
        echo "render distance: $render_dist"
        echo "<debug> f $p_from t $p_to pindex $PlayerTileIndex"
    #    echo "'t' test 'o' options 'x' eXit 'w''a''s''d' move"
    done
}


CreateWorld
GameTick

