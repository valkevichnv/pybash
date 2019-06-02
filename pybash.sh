#!/bin/bash

DIRNAME="testcase-pybash"
URL="https://github.com/kontur-exploitation/testcase-pybash.git"
#URL="https://github.com/valkevichnv/testcase-pybash.git"
PORT="80"
PROJECT="pybash"
MAINT="unknown"
[ ! -z "$1" ] && time=$1 || time="60s"


info () {
	echo "INFO:" $1
}

while :
do

if [ -d "$DIRNAME" ] 
then	
	info "Checking for updates"
	cd $DIRNAME
	REFRESH=$(git fetch origin 2>&1 | grep "\->" |awk '{print $(NF-2);}')
	echo $REFRESH
	git pull --all > /dev/null 2>&1
else
	info "Directory with repo not found. Cloning..."
        git clone $URL > /dev/null 2>&1 && cd $DIRNAME
	REFRESH=$(git branch -r | grep -v "/HEAD" | cut -d "/" -f2)
fi

#echo "DEBUG: Branches for update: $REFRESH"

if [ -z "$REFRESH" ]
then 
	info "Nothing to update"
	sleep $time
	continue
else
    for branch in $REFRESH; do
	name="$PROJECT-$branch"
	git checkout $branch > /dev/null 2>&1
	info "Building $name"
	docker build ../ -t $name  \
		--build-arg build_maint="$MAINT" \
		--build-arg build_branch="$branch" \
		--build-arg build_commit="$(git log | head -1 | cut -d " " -f 2 | head -c10)" \
		> /dev/null
	if [ ! -z "$(docker ps | grep $name)" ]
	then
	    echo "INFO: Stopping old $branch"
	    docker stop $name > /dev/null
	    sleep 1
    fi
	echo "INFO: Starting new $branch"
	docker run --rm -d \
		-p 0:$PORT \
		--name $name \
		$name \
		> /dev/null
    done
fi

sleep $time
done

cd --





