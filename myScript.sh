#!/bin/bash
# This shell script lists the IP addresses your computer is connected to and then does a traceroute to find more about them
# To run this program call sh myScript.sh


#Problem Statement: This could be useful for securty and identification purposes. 
#I often enjoy keeping my digital security and privacy secure, and often you want to know what IP addresses you may be connected to, or where they may be. These could help one identify potential threats or known spam IP addresses, or just to feed the curiosity of where you're computer is connecting to.
#It is also good to know exactly where and to what IP addresses may your local machine be connected to. It could even find connections you did not intend to find.

#I will be using emacs as my embedded text editor environment as I am more familiar with it and enjoy its hot keys compared to VIM.
#This program will utilize a variety of popular commands such as grep, sort, lsof (list open files), awk (a in bash programming/scripting language, sed (the stream editor) and a some other flags and System specific VARIABLES and designations to pull data. 
#I will also be using built in conditional statements in bash to give the user more interaction.
#I will also be connecting the script to an externel online service using curl to geo-locate IP Addresses

#This program will create a series of text files to utilize for output/storage and utilization options.
#These txt files will be overwritten each time

#Midterm: Shell and Bash Scripting
#BEGIN TUTORIAL

#STEP 1: SET UP
#---------------------------------------------------------------------------#

#The first thing we need to do is set up our data and environment in order to search and sort text to find exactly what we need.
# The first variable is that we specify our connection type, the second to specify the field we are looking for within the data.
#Afterward we want to filter out records that do not match with

#Variables to be accessed and used to isolate an IP address
    connection_type=TCP #This specifies the connection type
    field=2 # Which field of the output we're looking for
    no_match=LISTEN #filter out records containing this
    # -i lists Internet-associated files.
    # -n preserves numerical IP addresses.
    lsof_args=-ni

#This router variable is to isolate the router info and numbers so we can delete it with sed (stream editor) by using the regular expression to find anything between the brackets that is a digit. 
    router="[0-9][0-9][0-9][0-9][0-9]->"

#STEP 2: UTILIZING VARIABLES AND CONDITIONALS TO PERFORM DATA SEARCH AND EDITING
#This next section we start our bash script program by asking whether or not the user wants to continue with finding the IP addresses your computer is connected to.
#We then read the buffer input to determine whether a person writes y or yes to continue or n or no to stop the script.

echo "Would you like to see what IP addresses you are connected to(y/n)?"
read yes

#We then write a conditional if then, elif then, and else, statement to determine what the buffer reader output it and print to the console the echo for a list of IP Addresses and a line of demarkation. 

if [[ $yes == "yes" ]] || [[ $yes == "y" ]]; then
    echo "List of IP Addresses found connected to local machine: "
    echo "--------------------------------------------------------"

# This continued bash statement takes all of the information taken from the -ni flags for lsof (list open files). From listing all of the arguments that lsof -ni brings up we want to find the IP Address by finding the TCP with grep and piping all the data from there onto the next statement.
#From there we invert the grep search for the no_match variable to have everything other than LISTEN (which is at the end of the TCP data.
#We then use awk, a bash programming language, we then take the 9th field which is the IP Address.
    lsof "$lsof_args" | #all internet associated files and a numerical addresses
    grep $connection_type | #takes only the lines which contain the connection type of TCP
    grep -v "$no_match" | #finds all data in the line that does not match LISTEN
    awk '{print $9}' | #isolates and finds the 9th field
    cut -d : -f $field | #cuts out the field after the delimiter (-d) ":" and the seperates the 2nd to be cut
    sort | #puts all the IP addresses into newlines
    uniq | #report or filter out repeated lines in a file so that IP Address duplicates are removed
    sed s/"^$router"// > ip_list.txt #using the sed s command and the "^" to invert the digit find to replace the all non digits with nothing and output and overwrite into ip_list.txt
    cat ip_list.txt #read the output from the file

elif [[ $yes == "no" ]] || [[ $yes == "n" ]]; then #exits the program and sends a message
    echo "Alright! Bye!"
    exit 1
else
    echo "Wrong input, please run program again" #also exits the program but with a different method
    exit 1
fi

#STEP 3: FIND GEO-LOCATION DATA FROM THE LIST OF IP ADDRESSES
#Geo location info will take from the new ip_list.txt by running a loop through each line of the file and then using cURL command to transfer data to a server to a site service that will do a relative geolocation on IP Addresses sent.
#The URL is https://freegeoip.app/xml/(insert IP address here)


#This counter will be used to count the number of lines read through in the ip_list.txt doc to delineate the IP address number
counter=1

#Next option to continue and read the buffer to make it a variable
echo "Would you like to continue and geo-locate these ip addresses (y/n)?" 
read continue

#this if conditional determines whether or not we go forward with the Geo-location
if [[ $continue == "y" ]] || [[ $continue == "yes" ]]; then

    #Here we feed and pipe the contents of the ip_list.txt into the while loop to be read line by line
    cat ip_list.txt | #We pipe the ip_list created earlier into this while loop to be read line by line
    while read line; 
    do
	echo "" >> trace.txt #Append a blank space
	echo "IP Address No. $counter : $line" >> trace.txt #append The IP line number with the counter and append to txt
	echo "-------------------------------------------------" >> trace.txt 
	if [[ $line == *"."*"."*"."* ]]; then #this executes if the IP address has three periods with any chracter to either side of each with a wildcard
	    # This statement cURL transfers this data to server to be processed and the output appended to a text document
	    curl https://freegeoip.app/xml/$line >> trace.txt #we then find the geolocation and append the result
	fi 
	counter=$((counter+1)); #increment the counter by 1 for each line read
    done
    cat trace.txt #read the entirety of the trace file after the loop is done
    echo "" > trace.txt #overwrites the trace.txt so the next script run will append to a blank doc on a newline

elif [[ $yes == "no" ]] || [[ $yes == "n" ]]; then
    echo "Alright! Bye!"
    exit 1
else
    echo "Wrong input, please run program again"
    exit 1
fi
#after the if then statement runs and the elif and else dont, we send a message
echo "Thank you for using my script! Hope you found what you were looking for...goodbye!"
#Now analyze the IP Address Geolocation data to your hearts content!

#thank you!