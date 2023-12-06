#!/bin/bash
array=(5 3 2 1 4)
echo "${array[*]}"

size=${#array[@]}

for (( i=0; i<size-1; i++ )); do

   for (( j=0; j<size-i-1; j++ )); do
      if (( array[j] > array[j+1] )); then
         tmp=${array[j]}
         array[j]=${array[j+1]}
         array[j+1]=$tmp
      fi
   done

done

echo "Sorted array:"
echo "${array[*]}"