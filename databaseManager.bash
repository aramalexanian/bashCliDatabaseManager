#!/bin/bash

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
			mysql -u $user -e "create database if not exists $name"
			echo "Database created"
		;;
	esac
done
