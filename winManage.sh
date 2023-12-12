#!/bin/bash

# simple window tiler using, xdotool & wmctrl 
# Best used for ultrawide monitors 
# 
# use case:
#           horizontally tiles your open windows
#           Ignores all minized windows
#
#    F7: auto-tiles all windows into horizontal stacks
#    F8: swaps the active window to center tile
#    F9: hides active window   
#
#    If a window is closed or another is open you can re-tile
#    by pressing F7
#
# **** x_pos controls the left margin 
# **** x_width (trim_W) controls the right margin

xinput test-xi2 --root 3 | grep -A2 --line-buffered RawKeyRelease | while read -r line;
do

    if [[ $line == *"detail"* ]];
    then
        key=$( echo $line | sed "s/[^0-9]*//g")

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
        centralWinID=${arr_IDs[$center_tile]} # central tile ID
       
        # add cases 
        case "${key}" in
            73) # F7 -> initialize tiling and adjust for new or closed window 
                
                # check if any windows are minimized and ignore them
                # also account for differences in the FRAME size of each window 
                # which i refer to as padding here
                arr_IDs=()
                w_padding=() # width padding 
                x_padding=() # x-pos padding
                
                for id in $(wmctrl -l | cut -f1 -d' '); do
                    #check if minimized
                    isMin=$(xprop -id "$id" | grep -F 'window state: Iconic')
                    
                    if [ -z "$isMin" ];
                    then
                        arr_IDs+=($id)
                        
                        if [[ $(xprop -id "$id" | grep FRAME | awk '{print $5}') ]]; then
                            w_padding+=($(xprop -id "$id" | grep FRAME | awk '{print $5}'))
                        else
                            w_padding+=(0) #to append to an array need (*)
                        fi
                        
                        if [[ $(xprop -id "$id" | grep FRAME | awk '{print $4}') ]]; then
                            x_padding+=($(xprop -id "$id" | grep FRAME | awk '{print $4}'))
                        else
                            x_padding+=(0)
                        fi
                    fi
                done
                # compute length of ID array
                winTiles=${#arr_IDs[@]}
                
                
                # compute the average padding
                total_x=0; total_w=0
                for ((ii=0; ii < ${#x_padding[ii]} ; ii++)); do
                    # remove the stupid trailing commas
                    temp_w=${w_padding[ii]}; temp_w=${temp_w[@]%,}
                    temp_x=${x_padding[ii]}; temp_x=${temp_w[@]%,}
                    total_x=$(($total_x+$temp_x))
                    total_w=$(($total_w+$temp_w)) 
                done
                x_avg=$(($total_x/$winTiles))
                w_avg=$(($total_w/$winTiles))

                # get monitor resolution -- first col
                resolution=$(xrandr | grep "*" | awk '{print $1}')

                # split by horizontal and vertical pixel count
                horiz_res=$(echo $resolution | cut -d "x" -f 1)
                vert_res=$(echo $resolution | cut -d "x" -f 2)

                # get horizontal pixel length for each window 
                # returned as integer
                horiz_len=$(($horiz_res/$winTiles))

                # account for only one window
                # dont want one tile to be super large
                if [[ ${winTiles} == 1 ]]; then
                    # make the tile a little smaller
                    horiz_len=$(($horiz_len*99/100)) # only 90% and not 100%
                    x_pos=$(($horiz_res-$horiz_len))
                else
                    # get the x position of each window
                    x_pos=$(seq 0 $horiz_len $horiz_res)
                fi
                # turn IDs and x_pos into array so that they're interable
                arr_xPos=($x_pos)

                # automatically tile the windows into vertical columns
                count=0 # count number of windows
                st_trim_w=(); st_trim_x=()
               
                #account for window padding summing
                padd=$(($winTiles*2))
                for ((ii=0; ii < ${#arr_IDs[@]} ; ii++)) ; do    
               
                    # adjust padding
                    w_pad=${w_padding[ii]}; w_pad=${w_pad[@]%,} #remove traling comma for arithmetic
                    x_pos=${arr_xPos[ii]}; x_pad=${x_padding[ii]};x_pad=${x_pad[@]%,}
                    if [[ -z "$w_pad" ]]; then
                        # add average padding if none exists
                        trim_w=$(($horiz_len-$x_avg*2))
                        trim_x=$(($x_pos+$x_avg*2))
                    else
                        trim_w=$(($horiz_len-$x_pad/$padd))
                        trim_x=$(($x_pos+$x_pad/$padd))
                    fi

                    #custom padding if only one window
                    if [[ ${winTiles} == 1 ]]; then
                        trim_x=$x_pos
                        trim_w=$(($horiz_len-$x_pos))
                    fi

                    st_trim_w+=($trim_w); st_trim_x+=($trim_x)
                    $(wmctrl -ir ${arr_IDs[ii]} -e 0,$trim_x,0,$trim_w,$vert_res)
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
                    $(wmctrl -ir ${arr_IDs[ii]} -e 0,${st_trim_x[ii]},0,${st_trim_w[ii]},$vert_res)
                done
                
                #swap active win to center
                $(wmctrl -ir $activeID -e 0,${st_trim_x[center_tile]},0,${st_trim_w[activeIdx]},$vert_res);
                $(wmctrl -ir $centralWinID -e 0,${st_trim_x[activeIdx]},0,${st_trim_w[center_tile]},$vert_res);
                ;;
            75) # F9 -> hide active window
                $(xdotool windowminimize $(xdotool getactivewindow))

        esac
    fi
done
