#!/bin/bash

#1 deploy agent from collector
#2 agentInstall script is ran over ssh
#3 agents collector ip is updated
#4 ssh keys are generated for collector to access agent
#5 update allAgentIP file on collector

#Collector should now have list of all agents
#and have passwordless authentication to set iptables rules for global ban


#generate keys, get collector user to enter root pass of agent node



#!/bin/bash

ssh-copy-id ubuntu@$1

#Set up file structure and copy agent files over
AISFILEPATH="/usr/local/src/ais/"
AISDEPLOYPATH="/usr/local/src/ais/deploy/ais/"

#make deploy folders
mkdir /usr/local/src/ais/deploy $AISDEPLOYPATH $AISDEPLOYPATH/agents $AISDEPLOYPATH/scripts $AISDEPLOYPATH/tablesmysql

#copy agent files to deploy folder
cp  $AISFILEPATH/agents/{__init__.py,agentlib.py,netagent.py,sysagent.py} $AISDEPLOYPATH/agents/

#copy scripts to deploy folder
cp $AISFILEPATH/scripts/{agentInstall.sh,collectAndFlush.sh,startbarnyard.sh} $AISDEPLOYPATH/scripts

#copy tables structs to deploy folder
cp $AISFILEPATH/tablesmysql/{create_mysql_banlist_agent,create_mysql_syslog} $AISDEPLOYPATH/tablesmysql

#copy over scripts
scp -r $AISDEPLOYPATH ubuntu@$1:~/
ssh -t ubuntu@$1 "sudo mv $HOME/ais /usr/local/src/; sudo . $AISFILEPATH/scripts/agentInstall.sh"
rm -r $AISFILEPATH/deploy
cat "$1" >> $AISFILEPATH/agents/allAgentIPs