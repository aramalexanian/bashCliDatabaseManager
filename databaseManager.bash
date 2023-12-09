#!/bin/bash

# Importing Password
source ./databasePass

# Welcom Message
echo "Welcome to the Database manager."

# Current Name
user=$(whoami)

# Options
menuOptions=('Create_Database' 'Create_Table' 'Enter_Data' 'Delete_Database' 'Delete_Table' 'Delete_Data' 'Exit')

# Mysql Database types
mysqlDataTypes=('char' 'varchar' 'text' 'int' 'float' 'date')

# Loops Eternaly
while [[ 1 ]];do
	clear
	i=0
	# Loop through options and print them
	for option in ${menuOptions[@]}; do
		echo "$i ${option}"
		((i++))
	done
	# Take input
	read -p "Select: " selection
	clear
	echo "You have selected ${menuOptions[$selection]}"
	
	case ${menuOptions[$selection]} in

##################### DATABASE CREATION ##################################

		"Create_Database")
			read -p "Enter the name of your database: " name
			echo "Creating Database"
			mysql -u $user --password="$dataPass" -e "create database if not exists $name"
			echo "Database created"
		;;

###################### TABLE CREATION ######################################

		"Create_Table")
			query="show databases"
			databases=$(mysql -u $user --password="$dataPass" -s -N -e "$query" | grep -v 'information_schema' | grep -v 'performance_schema' | grep -v 'sys' | grep -v 'mysql')
			i=0
			for database in $databases; do
				echo "$i $database"
				((i++))
			done
			if [[ $i == 0 ]]; then
				echo "No Databases"
				sleep 1
				continue
			fi
			read -p "Select a Database" database
			database=${databases[$database]}
			read -p "Enter the table name: " tableName
			tableCreation="create table $tableName ( "
			read -p "How many columns would you like to create: " tableColumns
			columns=()
			while [[ $tableColumns > 0 ]]; do
				clear
				echo "Columns left: $tableColumns"
				read -p "Enter the column name: " columnName
				read -p "Not Null? (y/n): " answer
				if [[ $answer == ['yY'] ]];then
					notNull='not null'
				fi
				i=0
				for types in ${mysqlDataTypes[@]}; do
					echo "$i ${types}"
					((i++))
				done
				read -p "Select a datatype: " typeNum
				echo "Selected ${mysqlDataTypes[$typeNum]}"
				dataType=${mysqlDataTypes[$typeNum]}
				if [[ $dataType == 'char' ]] || [[ $dataType == 'varchar' ]];then
					read -p "Enter the number of characters for $dataType: " numChars
					dataType=$dataType"($numChars)"
				fi

				tableCreation+="$columnName $dataType $notNull"

				((tableColumns--))

				if [[ $tableColumns != 0 ]];then
					tableCreation+=', '
				  else
					tableCreation+=');'
				fi
			done
			mysql -u $user -p $database --password="$dataPass" -e "$tableCreation"
			read -p ""
		;;

############################ DATABASE DELETION ##############################

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

############################ TABLE DELETE ##########################

		"Delete_Table")
			query="show databases"
            databases=$(mysql -u $user --password="$dataPass" -s -N -e "$query" | grep -v 'information_schema' | grep -v 'performance_schema' | grep -v 'sys' | grep -v 'mysql')
			num=1
            for database in $databases; do
                echo "$num $database"
                ((num++))
            done
            read -p "Select a database: " dataNum
            database=$(echo $databases | awk -v var=$dataNum '{print $var}')

			query="show tables"
			tables=$(mysql -u $user -p $database --password="$dataPass" -s -N -e "$query")
			
			i=0
			for table in $tables;do
				echo "$i $table"
			done
			read -p "Select a table to delete: " tableNum
			
			query="drop table ${table[$tableNum]}"
			mysql -u $user -p $database --password="$dataPass" -e "$query"
		;;

############################ EXIT #############################

		"Exit")
			echo "Exiting..."
			break
		;;

############## Bad Select ###############

		*)
			echo "Invalid Select. Please select a proper option."
		;;
	esac
done
