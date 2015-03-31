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

find_replace_add_string_to_file "daemon .*" "daemon off;" /etc/nginx/nginx.conf "NGINX daemon off"

rm -rf /var/log/nginx
mkdir /var/log/nginx

if [ -f "/project/nginx.conf" ]
then
	ln -sf "/project/nginx.conf" /etc/nginx/nginx.conf
fi

file="/conf/nginx-virtual.conf"
if [ -f "/project/$NGINX_CONF" ]
then
	file="/project/$NGINX_CONF"
fi
rm -rf /etc/nginx/sites-enabled/*
cp -f "$file" /etc/nginx/sites-enabled/virtual.conf

if [ ! -d /project/media ]
then
	mkdir -p /project/media
fi

if [ ! -d /project/static ]
then
	mkdir -p /project/static
fi


