#!/bin/bash

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
if [ ! -d $PUBLIC_PATH ]
then
	django-admin.py startproject website $PUBLIC_PATH
fi

if [ ! -d /project/media ]
then
	mkdir /project/media
fi

if [ ! -d /project/static ]
then
	mkdir /project/static
fi