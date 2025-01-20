#! /bin/bash

# This File Control Tables in Database Engines

echo "---------------- Table Controler ----------------------"

echo "Entered Tables Controller"
echo "database name -> $dbname , database path -> $dbpath"
echo "Please Choose What you want to do"

PS3="$dbname Controller -> Your Choice -> "

while true; do
	select choice in "Create Table" "List Tables" "Drop Table" "Insert Row" "Show Data" "Delete Row" "Update Cell"  Exit
	do
		case $choice in 
			"Create Table") echo 'Create Table!'
				while true; do
					read -p "Enter The Table Name: " name
					if [[ "$name" =~ ^[a-zA-Z0-9]+$ ]]; then
						break
					else
						echo "Enter a Valid Name"
					fi
				done
				# To Do the table name saved in $name
				break;;
			"List Tables") echo 'List Tables!'
				# To Do List tables
				break;;
			"Drop Table") echo 'Drop Table!'
				while true; do
					read -p "Enter The Database Name: " name
					if [[ "$name" =~ ^[a-zA-Z0-9]+$ ]]; then
						break
					else
						echo "Enter a Valid Name"
					fi
				done
				# To Do the Drop Table , table name saved in $name
				break;;
			"Insert Row") echo 'Insert Row !'
				# To Do Insert Row
				break;;
			"Show Data") echo 'Show Data!'
				# To Do Show Data
				break;;
			"Delete Row") echo 'Delete Row !'
				./delete.sh
				break;;
			"Update Cell") echo 'Updated Row !'
				./update.sh
				break;;
			Exit) echo "Exiting $dbname Controller! , Goodbye"
				exit 0;;
			*) echo "Not A Valid Option"
				break;;
		esac
	done
done
