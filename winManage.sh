#!/bin/bash

# simple window tiler using shell script,
# wmctrl, and linux command line tools
xinput test-xi2 --root 3 | grep -A2 --line-buffered RawKeyRelease | while read -r line;
do

    if [[ $line == *"detail"* ]];
    then
        key=$( echo $line | sed "s/[^0-9]*//g")

        # add cases 
        case "${key}" in
            73) # F7 -> initialize tiling and adjust for new or closed window 
                
                # check if any windows are minimized and ignore them
                arr_IDs=()
                for id in $(wmctrl -l | cut -f1 -d' '); do
                    #check if minimized
                    isMin=$(xprop -id "$id" | grep -F 'window state: Iconic')
                    
                    if [ -z "$isMin" ];
                    then
                        #echo $"not min"
                        arr_IDs+=($id)
                    #else
                        #echo $"is min"
                    fi
                done
                #printf '%s\n' "${windowIDs[@]}"

                #windowIDs=$(wmctrl -lG | awk '{print $1}')

                # get number of windows to tile
                #winTiles=$(wmctrl -lG | awk 'END {print NR}')
                # compute length of ID array
                winTiles=${#arr_IDs[@]}

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

            ;;
            74) # F8 -> swap active window to center
                for ((ii=0; ii < ${#arr_IDs[@]} ; ii++)) ; do    
                    
                    $(wmctrl -ir ${arr_IDs[ii]} -e 0,${arr_xPos[ii]},0,$horiz_len,$vert_res)
                    $(wmctrl -ir ${arr_IDs[ii]} -b toggle,maximized_vert)
                done
                # get active window ID
                act_winID=$(wmctrl -lp | grep $(xprop -root | grep _NET_ACTIVE_WINDOW | head -1 | \
                    awk '{print $5}' | sed 's/,//' | sed 's/^0x/0x0/') | awk '{print $1}')

                
                #get the index of the active window
                for i in "${!arr_IDs[@]}"; do
                    if [[ "${arr_IDs[$i]}" = "$act_winID" ]]; then
                        activeIdx=${i};
                    fi
                done

                #rename some variables to keep whats left of my sanity 
                activeID=${arr_IDs[$activeIdx]}       # active window ID
                activeLoc=${arr_xPos[$activeIdx]}     # active window location
                centralLoc=${arr_xPos[$center_tile]}  # central location
                centralWinID=${arr_IDs[$center_tile]} # central tile ID
                
                #swap active win to center
                $(wmctrl -ir $activeID -e 0,$centralLoc,0,$horiz_len,$vert_res);
                $(wmctrl -ir $centralWinID -e 0,$activeLoc,0,$horiz_len,$vert_res);
                ;;
        esac
    fi
done