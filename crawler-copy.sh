#! /bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Bash Web Crawler"
echo "Student: Amarjot Singh"
echo "ID: 100280797"

MAXADDRESS=100
filename="cloud_computing.html"
PAGES="./pages"
SORTED="./sorted"
INDEXED="./indexed"
BEG_TIME=$(date +%s)
url=${1:-'https://en.wikipedia.org/wiki/cloud_computing'}

if [ -d "$PAGES" ]; then
	echo "Deleting Old Directory: $PAGES"
	rm -rf $PAGES
	echo "Creating New DIRECTORY: $PAGES"
	mkdir "$PAGES"
fi

if [ -d "$SORTED" ]; then
	echo "Deleting Old Directory: $SORTED"
	rm -rf $SORTED
	echo "Creating DIRECTORY: $SORTED"
	mkdir "$SORTED"
fi

if [ -d "$INDEXED" ]; then
	echo "Deleting Old Directory: $INDEXED"
	rm -rf $INDEXED
	echo "Creating DIRECTORY: $INDEXED"
	mkdir "$INDEXED"
fi

wget $url -O "$PAGES/${filename}"

ARRAY_TEMP=($(grep -i "\(href=\"\/wiki\/\w*\"\)" "$PAGES/${filename}" -o))

COUNT_LINKS=0
COUNT_ARRAY_MAIN=0
COUNT_ARRAY_TEMP=0
COUNT_CONTROL=0
ARRAY_MAIN_LEN=0
ARRAY_TEMP_LEN=${#ARRAY_TEMP[@]}
TOINSERT=1


while [ "$COUNT_ARRAY_TEMP" -lt "$ARRAY_TEMP_LEN" ] && [ "$COUNT_LINKS" -lt "$MAXADDRESS" ]
do
	while [ "$COUNT_ARRAY_MAIN" -lt "$ARRAY_MAIN_LEN" ] && [ "$TOINSERT" -eq 1 ]
	do
		if [ "${ARRAY_TEMP[$COUNT_ARRAY_TEMP]}" == "${ARRAY_MAIN[$COUNT_ARRAY_MAIN]}" ]; then
			TOINSERT=0
		else
			TOINSERT=1
		fi
		COUNT_ARRAY_MAIN=$(( $COUNT_ARRAY_MAIN + 1 ))
	done

	if [ "$TOINSERT" -eq 1 ]; then
		ARRAY_MAIN=(${ARRAY_MAIN[*]} ${ARRAY_TEMP[$COUNT_ARRAY_TEMP]})
		ARRAY_MAIN_LEN=${#ARRAY_MAIN[@]}
		CONTROL=(${CONTROL[*]} ${ARRAY_TEMP[$COUNT_ARRAY_TEMP]})
		COUNT_LINKS=$(( $COUNT_LINKS + 1 ))
	else
		TOINSERT=1		
	fi

	COUNT_ARRAY_MAIN=0

	COUNT_ARRAY_TEMP=$(( $COUNT_ARRAY_TEMP + 1 ))

	if [ "$COUNT_ARRAY_TEMP" -ge "$ARRAY_TEMP_LEN" ]; then
		echo -n "."
		filename=$(echo ${CONTROL[$COUNT_CONTROL]} | cut -d '"' -f 2)
		filename=${filename:6}
		url="https://en.wikipedia.org/wiki/${filename}"
		curl -s "https://en.wikipedia.org/wiki/${filename}" > "$PAGES/${filename}.html"

		ARRAY_TEMP=($(grep -i "\(href=\"\/wiki\/\w*\"\)" "$PAGES/${filename}.html" -o))
		COUNT_CONTROL=$(( $COUNT_CONTROL + 1 ))
		ARRAY_TEMP_LEN=${#ARRAY_TEMP[@]}
		COUNT_ARRAY_TEMP=0
	fi

done 

while [ "$COUNT_CONTROL" -lt "$ARRAY_MAIN_LEN" ]
do
	echo -n "."
	filename=$(echo ${CONTROL[$COUNT_CONTROL]} | cut -d '"' -f 2)
	filename=${filename:6}
	url="https://en.wikipedia.org/wiki/${filename}"
	curl -s "https://en.wikipedia.org/wiki/${filename}" > "$PAGES/${filename}.html"

	COUNT_CONTROL=$(( $COUNT_CONTROL + 1 ))
done

ARRAY_MAIN_LEN=${#ARRAY_MAIN[@]}
COUNT_CONTROL=0

while [ "$COUNT_CONTROL" -lt "$ARRAY_MAIN_LEN" ]
do
	filename=$(echo ${ARRAY_MAIN[$COUNT_CONTROL]} | cut -d '"' -f 2)
	filename=${filename:6}
    lynx -dump $PAGES/"$filename".html > $SORTED/"$filename".txt
    cat "$SORTED/$filename.txt" | tr -dc "[:alpha:] \-\/\_\.\n\r" | tr "[:upper:]" "[:lower:]" > "$SORTED/$filename.v1.txt"
    for w in `cat $SORTED/"$filename".v1.txt`
    do
    	echo "$w"
    done > "$SORTED/"$filename".v2.txt"

    sed -i "s/^file\/\/.*//g; s/^https\/\/.*//g; s/^http\/\/.*//g; s/^android-app\/\/.*//g; s/^-//g; s/^-//g; s/^-//g; s/^-//g; s/-$//g; s/,$//g; s/\.$//g; s/\.$//g; s/\.$//g; s/\/$//g; s/\.$//g; s/\.$//g; s/\.$//g; s/:$//g; s/\;$//g; /^$/d" $SORTED/${filename}.v2.txt

    echo "Sorting file $filename ..."
    sort "$SORTED/$filename.v2.txt" --output="$SORTED/$filename.sorted.txt"

    uniq -c "$SORTED/$filename.sorted.txt" > "$INDEXED/$filename.txt"

    rm -f "$SORTED/${filename}.v1.txt"
    rm -f "$SORTED/${filename}.v2.txt"

	COUNT_CONTROL=$(( $COUNT_CONTROL + 1 ))
done

END_TIME=$(date +%s)
echo "Process finished!!! $(($END_TIME - $BEG_TIME)) seconds"
exit


