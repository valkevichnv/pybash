#!/bin/bash

DIRNAME="testcase-pybash"
DKRFILEPATH="Dockerfile"
URL="https://github.com/kontur-exploitation/testcase-pybash.git"
LOGPATH="js.log"

if [ -d "$DIRNAME" ] 
then	
	echo "INFO: Checking for updates"
	cd $DIRNAME
	REFRESH=$(git remote -v update 2>/dev/null | grep "\-\>" | grep -v " = " | awk "{print $3}" )
	git pull -r > /dev/null 2>&1
else
	echo "WARN: Directory with repo not found. Cloning..."
        git clone $URL > /dev/null 2>&1 && cd $DIRNAME
	REFRESH=$(git branch | cut -c 3-)
fi

echo "DEBUG: Branches for update: $REFRESH"

if [ -z "$REFRESH" ]
then 
	echo "INFO: Nothing to update"
	exit
else
    for branch in $REFRESH; do
	LOGPATH="./log/$branch.log"
	echo $LOGPATH
	git checkout $branch2 > /dev/null 2>&1
	echo "INFO: Building pybash:$branch"
	sudo docker build ../ -t pybash:$branch --build-arg build_logpath=$LOGPATH
	if [ ! -z $(sudo docker ps | grep -q "pybash:$branch" ) ]
	then
	    echo "INFO: Stopping old container"
	    sudo docker stop pybash:$branch 2>/dev/null
	fi
	echo "INFO: Starting new container"
	sudo docker run --rm -it -p 80:80 pybash:$branch 	
    done

    git checkout master 2>/dev/null
fi








