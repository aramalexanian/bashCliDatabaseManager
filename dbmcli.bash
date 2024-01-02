#!/bin/bash

# Welcom Message
echo "Welcome to the Database manager."

# Options
menuOptions=('Show_Databases' 'Show_Tables' 'Display_Data' 'Create_Database' 'Create_Table' 'Enter_Data' 'Delete_Database' 'Delete_Table' 'Delete_Data' 'Exit')

# Mysql Database types
mysqlDataTypes=('char' 'varchar' 'text' 'int' 'float' 'date')

databases=''

# Displays all databases and populates teh databases variable
showDatabases() {
    databases="$@"

    # Lists all databases
    num=1
    for database in $databases; do
        echo "$num $database"
        ((num++))
    done
}

pullDatabases() {
	query="show databases"
    # Adds all databases to the databases variable
    databases=$(mysql --defaults-extra-file=./config.cnf -s -N -e "$query" | grep -v 'information_schema' | grep -v 'performance_schema' | grep -v 'sys' | grep -v 'mysql')
	echo $databases
}

pullAllTables(){
	database=$1
	query="show tables"
    tables=$(mysql --defaults-extra-file=./config.cnf $database -s -N -e "$query")
}


# Loops Eternaly
while [[ 1 ]];do
	selection=-1
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
			mysql --defaults-extra-file=./config.cnf -e "create database if not exists $name"
			echo "Database created"
		;;

###################### TABLE CREATION ######################################

		"Create_Table")
			# Adds all databases to the databases variable
    		databases=`pullDatabases`

			showDatabases "$databases"

			# If no databases then exits
			if [[ $(echo $databases | wc -w) == 0 ]]; then
				echo "No Databases"
				sleep 1
				continue
			fi

			# Takes input for database, table naem and number of columns
			read -p "Select a Database: " database
			database=$(echo $databases | awk -v var=$database '{print $var}')
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
			mysql --defaults-extra-file=./config.cnf $database -e "$tableCreation"
			
			# Confirmation
			if [[ ! $? ]];then
				read -p "Table created. Press enter to continue."
			  else
				read -p "Error. Table not created. Press enter to continue"
			fi
		;;

######################### ENTERING DATA ############################

		"Enter_Data")
			# Adds all databases to the databases variable
            databases=`pullDatabases`

            showDatabases "$databases"

            # If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi

            # Takes input for database, table naem and number of columns
            read -p "Select a Database: " database
            database=$(echo $databases | awk -v var=$database '{print $var}')

			tables=$(mysql --defaults-extra-file=./config.cnf $database -s -N -e "show tables")
            i=0
            for table in $tables;do
                echo "$i $table"
            done

            if [[ $(echo $tables | wc -w) == 0 ]]; then
                echo "No Tables in $database"
                sleep 1
                continue
            fi

            # Enter table
            read -p "Select a table: " tableNum
			
			columns=$(mysql --defaults-extra-file=./config.cnf $database -s -N -e "describe ${tables[$tableNum]}" | awk '{print $1}')

			columnCount=$(echo $columns | wc -w)

			if [[ $columnCount == 0 ]]; then
				echo "No Columns"
				sleep 1
				continue
			fi

			i=1
			query="insert into ${tables[$tableNum]} values("
			echo ${tables[$tableNum]}
			for column in $columns; do
				read -p $column': ' entry
				query+="$entry"
				if [[ $columnCount != $i ]]; then
					query+=', '
				fi
				((i++))
			done
			query+=')'
			echo $query
			
			mysql --defaults-extra-file=./config.cnf $database -e "$query"

			read -p "Data added. Press Enter to continue"
		;;

########################## SHOW DATABASES ###############################

		"Show_Databases")
			databases=`pullDatabases`

			showDatabases $databases
			# If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi
			read -p "Enter to continue"
		;;

######################### SHOW TABLES #################################

		"Show_Tables")
			databases=`pullDatabases`

            showDatabases $databases

            # If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi

            # Takes input for database, table naem and number of columns
            read -p "Select a Database: " database
            database=$(echo $databases | awk -v var=$database '{print $var}')
			tables=$(mysql --defaults-extra-file=./config.cnf $database -s -N -e "show tables")

            if [[ $(echo $tables | wc -w) == 0 ]]; then
                echo "No Tables in $database"
                read -p 'Enter to continue'
                continue
            fi
			
			mysql --defaults-extra-file=./config.cnf $database -e "show tables"

			read -p 'Enter to continue'
			
		;;

########################### SHOW DATA #################################

		"Display_Data")
			databases=`pullDatabases`

            showDatabases $databases

            # If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi

            # Takes input for database, table naem and number of columns
            read -p "Select a Database: " database
            database=$(echo $databases | awk -v var=$database '{print $var}')
            tables=$(mysql --defaults-extra-file=./config.cnf $database -s -N -e "show tables")
			i=0
            for table in $tables;do
                echo "$i $table"
            done

            if [[ $(echo $tables | wc -w) == 0 ]]; then
                echo "No Tables in $database"
                sleep 1
                continue
            fi

            # Enter table
            read -p "Select a table to view: " tableNum

			mysql --defaults-extra-file=./config.cnf $database -e "select * from ${tables[$tableNum]}"
			read -p 'Enter to continue'
		;;

############################ DATABASE DELETION ##############################

		"Delete_Database")
			# Adds all databases to the databases variable
            databases=`pullDatabases`

            showDatabases $databases
			
			# If no databases then exits
            if [[ $(echo $databases | wc -w) == 0 ]]; then
                echo "No Databases"
                sleep 1
                continue
            fi

			# Enter database to delete
			read -p "Which database would you like to delete: " dataNum
			database=$(echo "$databases" | awk -v var=$dataNum '{print $var}')

			# Deletes database
			mysql --defaults-extra-file=./config.cnf -e "drop database $database"
		;;

############################ TABLE DELETE ##########################

		"Delete_Table")
			# Adds all databases to the databases variable
            databases=`pullDatabases`

            showDatabases $databases

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
			tables=`pullAllTables` $database
			
			# Displays tables
			i=0
			for table in $tables;do
				echo "$i $table"
			done

			if [[ $(echo $tables | wc -w) == 0 ]]; then
                echo "No Tables in $database"
                sleep 1
                continue
            fi

			# Enter table
			read -p "Select a table to delete: " tableNum
			
			# Deletes the table
			query="drop table ${table[$tableNum]}"
			mysql --defaults-extra-file=./config.cnf $database -e "$query"
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
