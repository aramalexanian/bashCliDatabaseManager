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

databases=''

# Displays all databases and populates teh databases variable
showDatabases() {
	query="show databases"
	# Adds all databases to the databases variable
    databases=$(mysql -u $user --password="$dataPass" -s -N -e "$query" | grep -v 'information_schema' | grep -v 'performance_schema' | grep -v 'sys' | grep -v 'mysql')

    # Lists all databases
    num=1
    for database in $databases; do
        echo "$num $database"
        ((num++))
    done
}


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
			showDatabases
			# If no databases then exits
			if [[ $(echo $databases | wc -w) == 0 ]]; then
				echo "No Databases"
				sleep 1
				continue
			fi

			# Takes input for database, table naem and number of columns
			read -p "Select a Database" database
			database=${databases[$database]}
			read -p "Enter the table name: " tableName

			# Starting table creation query
			tableCreation="create table $tableName ( "
			read -p "How many columns would you like to create: " tableColumns

			# Makes an entry for each column
			while [[ $tableColumns > 0 ]]; do
				clear
				# Message to update
				echo "Query = '$tableCreation'"
				echo "Columns left: $tableColumns"

				# Enter data for column name and whether the column is not null
				read -p "Enter the column name: " columnName
				read -p "Not Null? (y/n): " answer
				if [[ $answer == ['yY'] ]];then
					notNull='not null'
				fi

				# Prints all data types available
				i=0
				for types in ${mysqlDataTypes[@]}; do
					echo "$i ${types}"
					((i++))
				done

				# Enter data type
				read -p "Select a datatype: " typeNum
				echo "Selected ${mysqlDataTypes[$typeNum]}"
				dataType=${mysqlDataTypes[$typeNum]}

				# Char and Varchar both require a size
				if [[ $dataType == 'char' ]] || [[ $dataType == 'varchar' ]];then
					read -p "Enter the number of characters for $dataType: " numChars
					dataType=$dataType"($numChars)"
				fi

				# Adds the column to the query
				tableCreation+="$columnName $dataType $notNull"

				((tableColumns--))

				# Either continues for another column or closes off the query
				if [[ $tableColumns != 0 ]];then
					tableCreation+=', '
				  else
					tableCreation+=');'
				fi
			done

			# Creates the table
			mysql -u $user -p $database --password="$dataPass" -e "$tableCreation"
			
			# Confirmation
			if [[ ! $? ]];then
				read -p "Table created. Press enter to continue."
			  else
				read -p "Error. Table not created. Press enter to continue"
			fi
		;;

############################ DATABASE DELETION ##############################

		"Delete_Database")
			showDatabases
			
			# If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi

			# Enter database to delete
			read -p "Which database would you like to delete: " dataNum
			database=$(echo $databases | awk -v var=$dataNum '{print $var}')

			# Deletes database
			mysql -u $user --password="$dataPass" -e "drop database $database"
		;;

############################ TABLE DELETE ##########################

		"Delete_Table")
			showDatabases

			# If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi

			# Enter Database
            read -p "Select a database: " dataNum
            database=$(echo $databases | awk -v var=$dataNum '{print $var}')

			# Pulls all the tables
			query="show tables"
			tables=$(mysql -u $user -p $database --password="$dataPass" -s -N -e "$query")
			
			# Displays tables
			i=0
			for table in $tables;do
				echo "$i $table"
			done

			# Enter table
			read -p "Select a table to delete: " tableNum
			
			# Deletes the table
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
