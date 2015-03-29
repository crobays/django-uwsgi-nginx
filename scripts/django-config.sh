#!/bin/bash

function find_replace_add_string_to_file() {
	find="$1"
	replace="$2"
	replace_escaped="${2//\//\\/}"
	file="$3"
	label="$4"
	if grep -q ";$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/;$find/$replace_escaped/" "$file"
	elif grep -q "#$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/#$find/$replace_escaped/" "$file"
	elif grep -q "$replace" "$file"
	then
		action="Already set"
	elif grep -q "$find" "$file"
	then
		action="Overwritten"
		sed -i "s/$find/$replace_escaped/" "$file"
	else
		action="Added"
		echo -e "\n$replace\n" >> "$file"
	fi
	echo " ==> Setting $label ($action) [$replace in $file]"
}

function fix_python_exec_path()
{
	for file in $PROJECT_PATH/$ENV_NAME/bin/*
	do
		if [ ! -f $file ]
		then
			continue
		fi
		find="\#\!$PROJECT_PATH/$ENV_NAME/bin/python$PYTHON_VERSION"
		find2="\#\!$PROJECT_PATH/$ENV_NAME/bin/python"
		find_escaped="${find//\//\\/}"
		find_escaped2="${find2//\//\\/}"
		replace="#!/usr/bin/env python"
		replace_escaped="${replace//\//\\/}"
		sed -i "s/$find_escaped/$replace_escaped/" "$file"
		sed -i "s/$find_escaped2/$replace_escaped/" "$file"
	done
}

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory

if [ ! -d $PROJECT_PATH ]
then
	mkdir -p $PROJECT_PATH
fi

if [ ! -f $PROJECT_PATH/requirements.txt ]
then
	cp /conf/requirements.txt $PROJECT_PATH/requirements.txt
fi

if [ ! -d $PROJECT_PATH/$ENV_NAME ]
then
	virtualenv $PROJECT_PATH/$ENV_NAME --python "python$PYTHON_VERSION"
	fix_python_exec_path
fi

echo -e '#!/bin/bash' > /root/.bashrc
echo -e 'export PATH="$PROJECT_PATH/$ENV_NAME/bin:$PATH"' >> /root/.bashrc
echo -e 'source $PROJECT_PATH/$ENV_NAME/bin/activate' >> /root/.bashrc
chmod +x $PROJECT_PATH/$ENV_NAME/bin/*
chmod +x /root/.bashrc

find_replace_add_string_to_file "VIRTUAL_ENV=.*" "VIRTUAL_ENV=\"$PROJECT_PATH/$ENV_NAME\";if [ -d $ENV_NAME ];then VIRTUAL_ENV=\"\$PWD/$ENV_NAME\";fi" $PROJECT_PATH/$ENV_NAME/bin/activate "Modify activate script" 

source /root/.bashrc
$PROJECT_PATH/$ENV_NAME/bin/pip install -r $PROJECT_PATH/requirements.txt
fix_python_exec_path

if [ ! -d $PROJECT_PATH/$APP_NAME ]
then
	$PROJECT_PATH/$ENV_NAME/bin/django-admin.py startproject $APP_NAME $PROJECT_PATH
	fix_python_exec_path
fi

if [ $TIMEZONE ] && [ -f $PROJECT_PATH/$APP_NAME/settings.py ]
then
	find_replace_add_string_to_file "TIME_ZONE = .*" "TIME_ZONE = '$TIMEZONE'" $PROJECT_PATH/$APP_NAME/settings.py "Set $APP_NAME Timezone"
fi

echo "project path: $PROJECT_PATH"
echo "project app: $APP_NAME"
echo "project env: $ENV_NAME"

if [ ! -d $PUBLIC_PATH/static/admin ]
then
	mkdir -p $PUBLIC_PATH/static
	python_dir=$(ls -r $PROJECT_PATH/$ENV_NAME/lib | head -n 1)
	if [ -d $PROJECT_PATH/$ENV_NAME/lib/$python_dir/site-packages/django/contrib/admin/static/admin ]
	then
		cp -r $PROJECT_PATH/$ENV_NAME/lib/$python_dir/site-packages/django/contrib/admin/static/admin $PUBLIC_PATH/static/admin
	else
		echo "No static files for admin found: $PROJECT_PATH/$ENV_NAME/lib/$python_dir/site-packages/django/contrib/admin/static/admin"
	fi
fi
