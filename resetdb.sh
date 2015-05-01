#!/bin/bash

#Script to reset the database
#Should be called once current MySQL data is sent to collector

#find the PID of the running barnyard instance
BARNYARDPID="$(ps axu | grep './startbarnyard.sh' | awk '{print $2}' | head -n 1)"
#Kill barnyard so we can reset the database for flushing
kill $BARNYARDPID

#stop snort so we can reset database and logs without errors
#This will result in lost packets for brief moment, but
#The overall goal here is the general trend so a few
#lost packets shouldn't make much of a difference
service snort stop

#Drop all snort related tables and recreate databases/tables
if [ -d /var/lib/mysql/snort ]; then

    for mysqlCommand in "DROP DATABASE snort;" "DROP DATABASE archive;"
    do
                echo $mysqlCommand >> mysqlCommands
    done

    mysql -u root -p --password='password'<mysqlCommands
    rm mysqlCommands


    for mysqlCommand in "CREATE DATABASE snort;" "CREATE DATABASE archive;" "GRANT USAGE ON snort.* to snort@localhost;" "GRANT USAGE ON archive.* to snort@localhost;" "set password for snort@localhost=PASSWORD('password');" "GRANT ALL PRIVILEGES ON snort.* to snort@localhost;" "GRANT ALL PRIVILEGES ON archive.* to snort@localhost;" "FLUSH PRIVILEGES;" "USE snort;" "SOURCE /usr/src/create_mysql;"
    do
            echo $mysqlCommand >> mysqlCommands
    done
    mysql -u root -p --password='password'<mysqlCommands
    rm mysqlCommands
    rm /var/log/snort/*
#   rm /var/log/barnyard2/*

fi;

#Drop all syslog related databases and recreate them
if [ ! -d /var/lib/mysql/syslog ]; then

    for mysqlCommand in "DROP DATABASE syslog;"
    do
                echo $mysqlCommand >> mysqlCommands
    done

    mysql -u root -p --password='password'<mysqlCommands
    rm mysqlCommands


    for mysqlCommand in "CREATE DATABASE syslog;" "GRANT USAGE ON syslog.* to syslog@localhost;" "GRANT ALL PRIVILEGES ON syslog.* to syslog@localhost;" "FLUSH PRIVILEGES;" "USE syslog;" "SOURCE /home/ubuntu/ais/create_mysql_syslog;"
    do
            echo $mysqlCommand >> mysqlCommands
    done
    mysql -u root -p --password='password'<mysqlCommands
    rm mysqlCommands
fi;


#Start snort up again
service snort start
#Get barnyard running again
./startbarnyard.sh
