#!/bin/bash

# simple window tiler using shell script,
# wmctrl, and linux command line tools

# get all window IDs -- first col
windowIDs=$(wmctrl -lG | awk '{print $1}')

# get number of windows to tile
winTiles=$(wmctrl -lG | awk 'END {print NR}')

# get monitor resolution -- first col
resolution=$(xrandr | grep "*" | awk '{print $1}')

# split by horizontal and vertical pixel count
horiz_res=$(echo $resolution | cut -d "x" -f 1)
vert_res=$(echo $resolution | cut -d "x" -f 2)

# get horizontal pixel length for each window 
# returned as integer
horiz_len=$(($horiz_res/$winTiles))

# get the x position of each window
x_pos=$(seq 0 $horiz_len $horiz_res)

# turn IDs and x_pos into array so that they're interable
arr_IDs=($windowIDs)
arr_xPos=($x_pos)

# automatically tile the windows into vertical columns
count=0 # count number of windows
for ((ii=0; ii < ${#arr_IDs[@]} ; ii++)) ; do    
    
    $(wmctrl -ir ${arr_IDs[ii]} -e 0,${arr_xPos[ii]},0,$horiz_len,$vert_res)
    $(wmctrl -ir ${arr_IDs[ii]} -b toggle,maximized_vert)
    ((count++))
done

# store new window positions
newWin_xPos=$(wmctrl -lG | awk '{print $6}')
newIDs=$(wmctrl -lG | awk '{print $1}')
arr_nWxPos=($newWin_xPois)
arr_newIDs=($newIDs)

# swap active window to center tile [if even then one of center]
if [ $((count%2)) -eq 0 ];
    then
        center_tile=$(($count/2-1)); #if even
    else
        center_tile=$(($count/2)); # if odd
fi

# get active window ID
act_winID=$(wmctrl -lp | grep $(xprop -root | grep _NET_ACTIVE_WINDOW | head -1 | \
    awk '{print $5}' | sed 's/,//' | sed 's/^0x/0x0/') | awk '{print $1}')

#get the index of the active window
for i in "${!arr_newIDs[@]}"; do
    if [[ "${arr_newIDs[$i]}" = "$act_winID" ]]; then
        activeIdx=${i};
    fi
done

# declare a way to read key presses
read_key_press() {
    if read -sN1 key_press; then
        while read -sN1 -t 0.001 ; do
            key_press+="${REPLY}"
        done
    fi
}

#declare -a fnkey
#for x in {1..24}; do
    #raw=$(tput kf$x | cat -A)
    #fnkey[$x]=${raw#^[}
    #echo $raw
    #echo $fnkey[$x]
#done

#Bind diffferent window tiling presets to F-keys
while read_key_press; do
    case "${key_press}" in
        #$'\e'${fnkey[1]}) # F1: move active window to center
        $'\e[1;5P') # ctrl+F1
            # moves the active window to center left
            $(wmctrl -ir ${arr_IDs[$activeIdx]} -e 0,${arr_xPos[$center_tile]},0,$horiz_len,$vert_res);
            $(wmctrl -ir ${arr_IDs[$center_tile]} -e 0,${arr_xPos[$activeIdx]},0,$horiz_len,$vert_res);
            ;;
    esac
done

