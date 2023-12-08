#!/bin/bash

source ./databasePass

echo "Welcome to the Database manager."

user=$(whoami)

menuOptions=('Create_Database' 'Create_Table' 'Enter_Data' 'Delete_Database' 'Delete_Table' 'Delete_Data')

while [[ 1 ]];do
	i=1
	for option in ${menuOptions[@]}; do
		echo "$i ${option}"
		((i++))
	done
	read -p "Select: " selection
	selection+=-1
	echo "You have selected ${menuOptions[$selection]}"
	
	case ${menuOptions[$selection]} in
		"Create_Database")
			read -p "Enter the name of your database: " name
			echo "Creating Database"
			mysql -u $user --password="$dataPass" -e "create database if not exists $name"
			echo "Database created"
		;;
		"Delete_Database")
			query="show databases"
			databases=$(mysql -u $user --password="$dataPass" -s -N -e "$query" | grep -v 'information_schema' | grep -v 'performance_schema' | grep -v 'sys' | grep -v 'mysql')
			num=1
			for database in $databases; do
				echo "$num $database"
				((num++))
			done
			read -p "Which database would you like to delete: " dataNum
			database=$(echo $databases | awk -v var=$dataNum '{print $var}')
			mysql -u $user --password="$dataPass" -e "drop database $database"
			echo "Database Removed"
		;;
	esac
done
