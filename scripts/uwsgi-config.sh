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

if [ ! -f /project/requirements.txt ]
then
	cp /conf/requirements.txt /project/requirements.txt
fi
pip install -r /project/requirements.txt

if [ -f /project/uwsgi.ini ]
then
	cp -f /project/uwsgi.ini /conf/uwsgi.ini
fi
if [ "$PUBLIC_PATH" ]
then
	mkdir -p "$PUBLIC_PATH"
	# if [ ! -f "$PUBLIC_PATH/index.html" ]
	# then

	# fi
	find_replace_add_string_to_file "chdir = .*" "chdir = $PUBLIC_PATH/" /conf/uwsgi.ini "UWSGI public path"
fi

if [ -f /project/uwsgi_params ]
then
	cp -f /project/uwsgi_params /conf/uwsgi_params
fi


