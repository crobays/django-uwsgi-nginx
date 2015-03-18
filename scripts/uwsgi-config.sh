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

# if [ ! -f $SRC/uwsgi.ini ]
# then
# 	mkdir -p $SRC
# 	cp /conf/uwsgi.ini $SRC/uwsgi.ini
# 	if [ "$APP_NAME" ]
# 	then
# 		find_replace_add_string_to_file "chdir = .*" "chdir = $SRC" $SRC/uwsgi.ini "UWSGI project path"
# 		find_replace_add_string_to_file "module = .*" "module = $APP_NAME.wsgi:application" $SRC/uwsgi.ini "UWSGI app module"
# 	fi
# fi

if [ -f $SRC/uwsgi_params ]
then
	cp -f $SRC/uwsgi_params /conf/uwsgi_params
fi


