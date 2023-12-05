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

# swap active window to center tile [if even then one of center]
if [ $((count%2)) -eq 0 ];
    then
        center_tile=$(($count/2-1)); #if even
    else
        center_tile=$(($count/2)); # if odd
fi

#start a counter
count=0
# read global keyboard inputs i.e. not just from the terminal
# important keycodes:
xinput test-xi2 --root 3 | grep -A2 --line-buffered RawKeyRelease | while read -r line;
do
    if [[ $line == *"detail"* ]];
    then
        key=$( echo $line | sed "s/[^0-9]*//g")

        # add cases 
        case "${key}" in

            73) # F7 -> swap active window to center
                # get active window ID
                act_winID=$(wmctrl -lp | grep $(xprop -root | grep _NET_ACTIVE_WINDOW | head -1 | \
                    awk '{print $5}' | sed 's/,//' | sed 's/^0x/0x0/') | awk '{print $1}')

                
                #get the index of the active window
                for i in "${!arr_IDs[@]}"; do
                    if [[ "${arr_IDs[$i]}" = "$act_winID" ]]; then
                        activeIdx=${i};
                    fi
                done
                if [ $((count)) -gt 0 ]; 
                    then
                        echo $count
                    else
                        #swap active win to center
                        $(wmctrl -ir ${arr_IDs[$activeIdx]} -e 0,${arr_xPos[$center_tile]},0,$horiz_len,$vert_res);
                        $(wmctrl -ir ${arr_IDs[$center_tile]} -e 0,${arr_xPos[$activeIdx]},0,$horiz_len,$vert_res);
                        echo "done"
                fi
                ((count++))
                ;;
            74) # F8 -> reset to initial window positions
                
                for ((ii=0; ii < ${#arr_IDs[@]} ; ii++)) ; do    
                    
                    $(wmctrl -ir ${arr_IDs[ii]} -e 0,${arr_xPos[ii]},0,$horiz_len,$vert_res)
                    $(wmctrl -ir ${arr_IDs[ii]} -b toggle,maximized_vert)
                done
                ;;
        esac
    fi
done