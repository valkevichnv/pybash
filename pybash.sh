#!/bin/bash

DIRNAME="$(pwd)/testcase-pybash"
DOCKERPATH="$(pwd)"
URL="https://github.com/kontur-exploitation/testcase-pybash.git"
#URL="https://github.com/valkevichnv/testcase-pybash.git"
PORT="80"
PROJECT="pybash"
MAINT="unknown"
VERBOSE=true

[ ! -z "$1" ] && time=$1 || time="60s"


info () {
	[ $VERBOSE ] && echo "$(date +"%d.%m.%Y %T(%Z GMT):")" $1
}

while :
do
REFRESH=""
if [ -d "$DIRNAME" ] 
then	
	info "Checking for updates"
	cd $DIRNAME
	REFRESH=$(git fetch origin 2>&1 | grep "\->" |awk '{print $(NF-2);}')
	git pull --all > /dev/null 2>&1
else
	info "Directory with repo not found. Cloning into $DIRNAME"
        git clone $URL > /dev/null 2>&1 && cd $DIRNAME
	REFRESH=$(git branch -r | grep -v "/HEAD" | cut -d "/" -f2)
fi

if [ -z "$REFRESH" ]
then 
	info "Nothing to update"
	sleep $time
	continue
else
    info "Branches for update: $REFRESH"	
    for branch in $REFRESH; do
	name="$PROJECT-$branch"
	git checkout $branch > /dev/null 2>&1
	info "Building $name"
	docker build $DOCKERPATH -t $name  \
		--build-arg build_maint="$MAINT" \
		--build-arg build_branch="$branch" \
		--build-arg build_commit="$(git log | head -1 | cut -d " " -f 2 | head -c10)" \
		> /dev/null
	if [ ! -z "$(docker ps | grep $name)" ]
	then
	    info "Stopping old $branch"
	    docker stop $name > /dev/null
	    sleep 1
    fi
	info "Starting new $branch"
	docker run --rm -d \
		-p 0:$PORT \
		--name $name \
		$name \
		> /dev/null
	info "Started $branch"
    done
fi

sleep $time
done

cd --





