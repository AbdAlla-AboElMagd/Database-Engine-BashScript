#! /bin/bash

# This File Control Database Engines

echo "Welcome to the database Engine"

echo "Please Choose What you want to do"

PS3="Database Engine -> Your Choice -> "

while true; do
	select choice in "Create Database" "List Databases" "Connect to Database" "Delete Database" Exit
	do
		case $choice in 
			"Create Database") echo 'Create Database!'
				while true; do
					read -p "Enter The Database Name: " name
					if [[ "$name" =~ ^[a-zA-Z0-9]+$ ]]; then
						break
					else
						echo "Enter a Valid Name"
					fi
				done
				if [ -d ".db/$name" ]; then
					echo "Database Already Exists!"
				else
					mkdir -p .db/"$name"
					echo "Created $name Database!"
				fi	
				break;;
			"List Databases") echo 'List Databases!'
				ls .db/
				break;;
			"Connect to Database") echo 'Connect to Database!'
				while true; do
					read -p "Enter The Database Name: " dbname
					if [[ "$dbname" =~ ^[a-zA-Z0-9]+$ ]]; then
						break
					else
						echo "Enter a Valid Name"
					fi
				done
				if [ -d ".db/$dbname" ]; then
					echo "Connected to $dbname database"
					export dbname
					./table.sh
				else
					echo "There's no Database with that name!"
				fi
				break;;
			"Delete Database") echo 'Delete Database !'
				break;;
			Exit) echo 'Exit! , Goodbye'
				break 2;;
			*) echo "Not A Valid Option"
				break;;
		esac
	done
done
