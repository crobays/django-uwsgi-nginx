#!/bin/bash

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
if [ ! -d $SRC ]
then
	mkdir -p $SRC
fi

if [ ! -f $SRC/requirements.txt ]
then
	cp /conf/requirements.txt $SRC/requirements.txt
fi

# echo -e '#!/bin/bash\nexport PATH="$SRC/$ENV_NAME/bin:$PATH"' > /etc/bashrc
# chmod +x /etc/bashrc
# source /etc/bashrc

if [ ! -d $SRC/$ENV_NAME ]
then
	virtualenv $SRC/$ENV_NAME
fi
source $SRC/$ENV_NAME/bin/activate
cd $SRC/$ENV_NAME
pip install -r $SRC/requirements.txt

if [ ! -d $SRC/$APP_NAME ]
then
	$SRC/$ENV_NAME/bin/django-admin.py startproject $APP_NAME $SRC
fi

echo "project path: $SRC"
echo "project app: $APP_NAME"
echo "project env: $ENV_NAME"

if [ ! -d /project/media ]
then
	mkdir /project/media
fi

if [ ! -d /project/static ]
then
	mkdir /project/static
fi
