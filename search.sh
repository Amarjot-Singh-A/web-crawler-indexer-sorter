#!/bin/bash

echo "SEARCH PROCEDURE"
echo "Counting occurrences for the word $1 in files"
echo

TOTAL_COUNT=0

# treating uppercase words
word=$(echo $1 | tr '[:upper:]' '[:lower:]')

for file in statistics/*.txt
do
	echo "${file}"
    FIND_ARRAY=(`grep " $word\>" $file`)
    if [ "${FIND_ARRAY[0]}" != "" ];
    then
        echo "$file : ${FIND_ARRAY[@]}"
    fi
    TOTAL_COUNT=$((TOTAL_COUNT + FIND_ARRAY[0]))
done > "count-result.txt"
sort -rk 3 count-result.txt -o count-result.txt
echo "$TOTAL_COUNT occurrences were found in all files."
echo
echo "count-result.txt generated. Would you like to display the detail? (y/n)"
read input
if [ $input == "y" ] || [ $input == "Y" ];
then
    cat count-result.txt
else
    echo "Done!"
fi
echo