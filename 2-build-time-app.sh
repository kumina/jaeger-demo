#!/bin/bash
#
# This builds the time-app image with docker. If you have the tarball available, you
# can add the option `load` to simply load the image.tar file in this directory.
if [ ! -z $1 ];
then
	echo "= Loading time-app image ="
	cat image.tar | docker load
else
	echo "= Building time-app image ="
	cd time-app
	docker build --tag time-app .
	docker tag time-app router
	docker tag time-app year
	docker tag time-app month
	docker tag time-app day
	docker tag time-app hour
	docker tag time-app minute
	docker tag time-app second
	cd ..
fi
