#! /bin/bash

clear
echo "Student: Alexandre Santiago da Silva"
echo "ID: 100285742"
echo "bash web crawler"

# Configuration Variables
MAXADDRESS=100
filename="cloud_computing.html"
DIRECTORY="./sites"

echo
echo "Web crawler from https://en.wikipedia.org/wiki/Cloud_computing"
echo
echo "Max number of links: $MAXADDRESS"
echo
START_TIME=$(date +%s)
echo "Process started at $(date)"
echo
echo
echo "Step 1 - BFS Algorithm - Web Crawler"
echo "Start Executing..."
echo ""

# Assign a default url if it's none is passed as a parameter
url=${1:-'https://en.wikipedia.org/wiki/cloud_computing'}
echo "Processing url: $url"

# Test if url is well formated if not show error msg

# Check if the download diectory exist
if [ ! -d "$DIRECTORY" ]; then
	echo "Creating DIRECTORY: $DIRECTORY"
	mkdir "$DIRECTORY"
fi

# get the start file
wget $url -O "sites/${filename}"

ARRAY_TEMP=($(grep -i "\(href=\"\/wiki\/\w*\"\)" "sites/${filename}" -o))

# ARRAY_TEMP=(Banana Maca Limao Banana Maca Kiwi)

# echo "ARRAY_MAIN"
# echo ${ARRAY_MAIN[*]}

#star counter
COUNT_LINKS=0
COUNT_ARRAY_MAIN=0
COUNT_ARRAY_TEMP=0
COUNT_CONTROL=0
ARRAY_MAIN_LEN=0
ARRAY_TEMP_LEN=${#ARRAY_TEMP[@]}
TOINSERT=1

# echo "INITIAL LENGTH: ${#ARRAY_TEMP[@]}"

while [ "$COUNT_ARRAY_TEMP" -lt "$ARRAY_TEMP_LEN" ] && [ "$COUNT_LINKS" -lt "$MAXADDRESS" ]
do
	# echo "COUNT_ARRAY_MAIN: $COUNT_ARRAY_MAIN  ARRAY_MAIN_LEN: $ARRAY_MAIN_LEN"
	# echo "COUNT_ARRAY_TEMP: $COUNT_ARRAY_TEMP  ARRAY_TEMP_LEN: $ARRAY_TEMP_LEN"
	# echo ""
	while [ "$COUNT_ARRAY_MAIN" -lt "$ARRAY_MAIN_LEN" ] && [ "$TOINSERT" -eq 1 ]
	do
		if [ "${ARRAY_TEMP[$COUNT_ARRAY_TEMP]}" == "${ARRAY_MAIN[$COUNT_ARRAY_MAIN]}" ]; then
			# Flags that item found in main array and is not to be inserted
			TOINSERT=0
		else
			# Flags that item not found in main array
			TOINSERT=1
			# restart count for main array list
			# COUNT_ARRAY_MAIN=0
		fi
		# move to next array item
		COUNT_ARRAY_MAIN=$(( $COUNT_ARRAY_MAIN + 1 ))
		# echo "COUNT_ARRAY_MAIN: $COUNT_ARRAY_MAIN  ARRAY_MAIN_LEN: $ARRAY_MAIN_LEN"
	done

	if [ "$TOINSERT" -eq 1 ]; then
		# insert TEMP item into main array list
		ARRAY_MAIN=(${ARRAY_MAIN[*]} ${ARRAY_TEMP[$COUNT_ARRAY_TEMP]})
		# updates array length
		ARRAY_MAIN_LEN=${#ARRAY_MAIN[@]}
		# insert TEMP item into control array list
		CONTROL=(${CONTROL[*]} ${ARRAY_TEMP[$COUNT_ARRAY_TEMP]})
		# updates the link counter
		COUNT_LINKS=$(( $COUNT_LINKS + 1 ))
		# echo "COUNT_LINKS: $COUNT_LINKS"
	else
		# resets flag for item not found
		TOINSERT=1		
	fi

	# restart count for main array list
	COUNT_ARRAY_MAIN=0

	# move to next array item in TEMP
	COUNT_ARRAY_TEMP=$(( $COUNT_ARRAY_TEMP + 1 ))

	# echo "size: $COUNT_ARRAY_TEMP max_size: $ARRAY_TEMP_LEN"
	if [ "$COUNT_ARRAY_TEMP" -ge "$ARRAY_TEMP_LEN" ]; then
		# Get next array to process
		# get the start file
		# removes href="
		echo -n "."
		filename=$(echo ${CONTROL[$COUNT_CONTROL]} | cut -d '"' -f 2)
		# removes /wiki/
		filename=${filename:6}
		url="https://en.wikipedia.org/wiki/${filename}"
		# wget $url -O "sites/${filename}.html"
		# wget $url -q -O "sites/${filename}.html"
		# In server use curl instead of wget
		curl -s "https://en.wikipedia.org/wiki/${filename}" > "sites/${filename}.html"

		ARRAY_TEMP=($(grep -i "\(href=\"\/wiki\/\w*\"\)" "sites/${filename}.html" -o))
		# echo ${CONTROL[$COUNT_CONTROL]}
		# Moves to next item in control list
		COUNT_CONTROL=$(( $COUNT_CONTROL + 1 ))
		# ARRAY_TEMP=(Uva Maca Jaca Banana Kiwi Kaki)
		# Resets length of temp array
		ARRAY_TEMP_LEN=${#ARRAY_TEMP[@]}
		# Resets index for temp array
		COUNT_ARRAY_TEMP=0
		# echo "new size: $COUNT_ARRAY_TEMP new max_size: $ARRAY_TEMP_LEN"
	fi

done 

# After reaching the processing cap keep downloading the rest of the pages
while [ "$COUNT_CONTROL" -lt "$ARRAY_MAIN_LEN" ]
do
	# Get next array to process
	# get the start file
	# removes href="
	echo -n "."
	filename=$(echo ${CONTROL[$COUNT_CONTROL]} | cut -d '"' -f 2)
	# removes /wiki/
	filename=${filename:6}
	url="https://en.wikipedia.org/wiki/${filename}"
	# wget $url -O "sites/${filename}.html"
	# wget $url -q -O "sites/${filename}.html"

	# In server use curl instead of wget
	curl -s "https://en.wikipedia.org/wiki/${filename}" > "sites/${filename}.html"

	# echo ${CONTROL[$COUNT_CONTROL]}
	# Moves to next item in control list
	COUNT_CONTROL=$(( $COUNT_CONTROL + 1 ))
done

echo
END_TIME_1=$(date +%s)
echo "Step 1 finished at $(date) - $(($END_TIME_1 - $START_TIME)) seconds"
echo
echo
echo

# STEP 2 - CREATI INDEX FILES FOR WORDS
echo "Step 2 - Create Index for words"
echo "Executing..."

# Check if the temp diectory exist
if [ ! -d "temp" ]; then
	echo "Creating DIRECTORY: temp"
	mkdir "temp"
fi

# Check if the statistics diectory exist
if [ ! -d "statistics" ]; then
	echo "Creating DIRECTORY: statistics"
	mkdir "statistics"
fi

# updates array length
ARRAY_MAIN_LEN=${#ARRAY_MAIN[@]}
# resets counter
COUNT_CONTROL=0

while [ "$COUNT_CONTROL" -lt "$ARRAY_MAIN_LEN" ]
do

    echo "Treating file $filename: transforming from HTML to txt, separating words, removing characters..."
	# get the start file
	# removes href="
	filename=$(echo ${ARRAY_MAIN[$COUNT_CONTROL]} | cut -d '"' -f 2)
	# removes /wiki/
	filename=${filename:6}

    # echo "Treating file $filename: transforming from HTML to txt..."
    # using lynx to transform html file into text file to remove tags
    lynx -dump sites/"$filename".html > temp/"$filename".txt
    # echo ""

    # echo "Treating file $filename: removing numbers and special characters..."
    # treating the file, removing numbers and some special characters
    cat "temp/$filename.txt" | tr -dc "[:alpha:] \-\/\_\.\n\r" | tr "[:upper:]" "[:lower:]" > "temp/$filename.v1.txt"
    # echo ""

    # echo "Treating file $filename: separating words..."
    # treating the file, separating each word in a line
    for w in `cat temp/"$filename".v1.txt`
    do
    	echo "$w"
    done > "temp/"$filename".v2.txt"

    # treating the file, removing some more special characters
    # removing files links "file://"
    # removing real links "https://" "http://" "android-app://"
    # removing special characters starting with -,:. etc
    # echo "removing aditional characters from file: ${filename}.v2.txt"
    # version for Amazon Linux
    sed -i "s/^file\/\/.*//g; s/^https\/\/.*//g; s/^http\/\/.*//g; s/^android-app\/\/.*//g; s/^-//g; s/^-//g; s/^-//g; s/^-//g; s/-$//g; s/,$//g; s/\.$//g; s/\.$//g; s/\.$//g; s/\/$//g; s/\.$//g; s/\.$//g; s/\.$//g; s/:$//g; s/\;$//g; /^$/d" temp/${filename}.v2.txt
    # version for mac OS
    # sed -i "" "s/^file\/\/.*//g; s/^https\/\/.*//g; s/^http\/\/.*//g; s/^android-app\/\/.*//g; s/^-//g; s/^-//g; s/^-//g; s/^-//g; s/-$//g; s/,$//g; s/\.$//g; s/\.$//g; s/\.$//g; s/\/$//g; s/\.$//g; s/\.$//g; s/\.$//g; s/:$//g; s/\;$//g; /^$/d" temp/${filename}.v2.txt
    # echo ""

    echo "Sorting file $filename ..."
    # sorting the words for better counting algorithm
    sort "temp/$filename.v2.txt" --output="temp/$filename.sorted.txt"

    #count word occurrance inside the file and moving the final file to the right directory "statistics"
    uniq -c "temp/$filename.sorted.txt" > "statistics/$filename.txt"

    #remove intermediate files
    rm -f "temp/${filename}.v1.txt"
    rm -f "temp/${filename}.v2.txt"

	# Moves to next item in control list
	COUNT_CONTROL=$(( $COUNT_CONTROL + 1 ))
done

# final display with the total time spent
echo
END_TIME_2=$(date +%s)
echo "Step 2 completed at $(date) - $(($END_TIME_2 - $END_TIME_1)) seconds"
echo
echo "Process finished!!! $(($END_TIME_2 - $START_TIME)) seconds"



