# testing reading background key press
xinput test-xi2 --root 3 | grep -A2 --line-buffered RawKeyRelease | while read -r line;
do
    if [[ $line == *"detail"* ]];
    then
        key=$( echo $line | sed "s/[^0-9]*//g")

        #Do something with the key
        echo $key
    fi

done