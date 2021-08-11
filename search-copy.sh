#!/bin/bash

echo "SEARCH PROCEDURE"
echo "Counting occurrences for the word $1 in files"
echo

TOTAL_COUNT=0

# treating uppercase words
word=$(echo $1 | tr '[:upper:]' '[:lower:]')

for file in indexed/*.txt
do
    FIND_ARRAY=(`grep " $word\>" $file`)
    if [ "${FIND_ARRAY[0]}" != "" ];
    then
        echo "$file : ${FIND_ARRAY[@]}"
    fi
    TOTAL_COUNT=$((TOTAL_COUNT + FIND_ARRAY[0]))
done > "search_result.txt"
sort -rk 3 search_result.txt -o search_result.txt
echo "$TOTAL_COUNT occurrences were found in all files."
echo
echo "search_result.txt generated. Would you like to display the detail? (y/n)"
read input
if [ $input == "y" ] || [ $input == "Y" ];
then
    cat search_result.txt
else
    echo "Done!"
fi
echo