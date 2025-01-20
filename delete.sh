#! /bin/bash


if [ -z "$dbname" ]; then
    # dbname="test"
    while true; do
    read -p "Enter the name of the Database: " dbname
        if [[ "$dbname" =~ ^[a-zA-Z0-9]+$ ]]; then
		    if  [[ -d ".db/$dbname" ]]; then
		        break
            else
                echo "Database does not exist"
            fi
	    else
		    echo "Enter a Valid Table Name"
	    fi
    done
fi

if [ -z "$tablename" ]; then
    # tablename="tableTest"
    while true; do
    read -p "Enter the name of the table: " tablename
        if [[ "$tablename" =~ ^[a-zA-Z0-9]+$ ]]; then
            if  [[ -f ".db/$dbname/$tablename" ]]; then
		        break
            else
                echo "Table does not exist"
            fi
	    else
		    echo "Enter a Valid Table Name"
	    fi
    done
fi

if [ -z "$PS3" ]; then
    PS3="Delete Control db $dbname table $tablename -> "
fi


select deleteChoice in "Delete By Row Number" "Delete by PK"
do
    case $deleteChoice in 
        "Delete By Row Number") echo 'Delete By Row Number!'
            # Number of Tries (Only 3 tries then exit)
            counter=3;
            # read -p "Value: " value
            while [ $counter -gt 0 ]; do
                read -p "Enter The Row Number: " rnum
                counter=$((counter-1))
                if [[ "$rnum" =~ ^[0-9]+$ ]]; then
                    totalrnum=$(wc -l < ".db/$dbname/$tablename")
                    totalrnum=$((totalrnum+1))
                    # echo "Row number entered: $rnum" 
                    # echo "Total rows: $totalrnum"
                    if (( rnum <= totalrnum+1 )); then
                        sed -i "${rnum}d" ".db/${dbname}/${tablename}"
                        echo "deleted row number $rnum"
                        break
                    else
                        echo "The Number you entered Exceeded the total number of row"
                    fi
                else
                    echo "Enter a Valid Row Number"
                fi
                echo "You have $counter tries left"
            done
        break;;

    "Delete by PK") echo 'Delete by PK!'
        # creating .tmp folder , (Delete it in the end of this function)
        if [ -d ".tmp" ]; then
			# do nothing
            # echo "Temp Folder Exists"
            # No op
            :
		else
			mkdir ".tmp"
		fi
        pkcolumnsfile=".tmp/tmppkcolumns"
        pkcount=0
        awk -F: '/PK/ { for (i = 1; i <= NF; i++) if ($i ~ /PK/) print i }' ".db/${dbname}/${tablename}meta" > "$pkcolumnsfile"
        pkcount=$(wc -l < "$pkcolumnsfile")
        # echo "PK columns Number: $pkcount"

        typeline=$(sed -n '2p' ".db/${dbname}/${tablename}meta")
        pknameline=$(sed -n '1p' ".db/${dbname}/${tablename}meta")
        #declaring an array catching the values
        # it will contain for every key the number of its column , the type , the value
        declare -a pkarr

        counter=0
        pkname=""
        
        # echo "The FIle path: $pkcolumnsfile"
        # while read -r -u 3 pkcolnum; do  >>> another way to solve reading from file with reading from keyboard
        while read -r pkcolnum; do
            # First the column number
            # echo "Getting data of pk column number $pkcolnum"

             # First the column number
            # echo "Getting data of pk column number $pkcolnum"
            pkarr[$counter]=$pkcolnum
            # echo ${pkarr[$counter]}
            # Then the type
            pkarr[$((counter+1))]=$(echo "$typeline" | awk -F: -v colnum="$pkcolnum" '{print $colnum}' )
            # echo "THe tyoe of PK column number $pkcolnum is ${pkarr[$((counter+1))]}"
            # Then the value
            pkname=$(echo "$pknameline" | awk -F: -v colnum="$pkcolnum" '{print $colnum}' )
            # Take it from user
            read -p "Enter the value of PK which name is $pkname and its type is ${pkarr[$((counter+1))]} :" value < /dev/tty
            
            # echo "Took the value from user as $value and start checking!"
            
            if [[ ( "${pkarr[$((counter+1))]}"=="<int>" && $value =~ ^[0-9]+$ ) || ( "${pkarr[$((counter+1))]}"=="<str>" && $value =~ ^[a-zA-Z0-9]+$ ) || ( "${pkarr[$((counter+1))]}"=="<float>" && $value =~ ^[0-9]+\.[0-9]+$ ) ]]; then
                pkarr[$((counter+2))]=$value
                # echo "Value taken from user is: $value"
                # echo "Saved as : ${pkarr[$((counter+2))]}"
            else
                echo "Not a valid data Enter a valid $pkname value from type ${pkarr[$((counter+1))]}"
            fi
                     
            counter=$((counter+3))
        done < "$pkcolumnsfile"



        # Deleting Matching Records
        # Open a temporary file to store the new data
        tempfile=".tmp/${tablename}.tmp"
        # Make sure that the tmp file is empty before appending rows on it truncate making the size of file 0 without deleting it (Like truncate in database sql)
        truncate -s 0 "$tempfile"
        # echo "Searching For Matching Row !!!!!!!!!!!!!!!!!!"
        # Read the data file line by line and check for matching rows


        # echo "Lines of the Fle .db/${dbname}/${tablename}"
        deletedAccess=0
        while read -r line || [[ -n "$line" ]]; do
            
            # echo "The Line Read To check is: $line" 
            # echo "The Total Number of Conditions: ${#pkarr[@]}"
                        
            match=1
            for ((i=0; i<${#pkarr[@]}; i+=3)); do
                pkcolnum=${pkarr[$i]}
                pkvalue=${pkarr[$((i+2))]}
                
                # Get the value from the line
                field_value=$(echo "$line" | cut -d: -f"$pkcolnum")
                field_valuetrimmed=$(echo "$field_value" | awk '{$1=$1; print}')
                
                # echo "in loop number $i (index: $i), max loop counter is ${#pkarr[@]}"
                # echo "pkcolnum: $pkcolnum"
                # echo "pkvalue: $pkvalue"
                # echo "field_value: $field_value"
                # echo "field_valuetrimmed: $field_valuetrimmed"
                # echo "Check if ($field_valuetrimmed) is equal to ($pkvalue)"
                
                if [[ "$field_valuetrimmed" != "$pkvalue" ]]; then
                    # echo "Change the matching value"
                    match=0
                    break
                fi
            done


            # echo "End of change the matching value For the line and match is :$match"

            if [[ $match -eq 0 ]]; then
                echo "$line" >> "$tempfile"
            else
                echo "Matched Line ! will be deleted"
                deletedAccess=$((deletedAccess+1))
                echo "$line"
            fi
        done < ".db/${dbname}/${tablename}"

        # Finally save the data
        # First take a backup for roll back
        # creating .backup folder
        if [ -d ".backup/${dbname}" ]; then
            # echo "Backup Folder Exists"
            # No op
            :
		else
			mkdir -p ".backup/${dbname}"
		fi
        # creating .backup/${dbname}/${tablename}.backup file
        if [ -f ".backup/${dbname}/${tablename}.backup" ]; then
            # echo "Backup file exists"
            # No op
            :
        else
            cp -p ".db/${dbname}/${tablename}" ".backup/${dbname}/${tablename}.backup"
        fi
        # Replace the old data file with the new data file
        cp "$tempfile" ".db/${dbname}/${tablename}"

        # Remove the temporary folder
        rm -r .tmp

        echo "Rows matching the primary key values have been deleted."
        echo "Deleted Rows: $deletedAccess"
       

    break;;

    esac
done