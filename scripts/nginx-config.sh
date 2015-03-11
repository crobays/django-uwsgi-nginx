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

# php_code="echo '('.(array_key_exists('DOMAIN',\$_SERVER) ? str_replace('.', '\\\\\.', implode('|', array_unique(array_map(function(\$domain){\$d = array_reverse(explode('.', \$domain)); return \$d[1].'.'.\$d[0];}, in_array(substr(\$_SERVER['DOMAIN'], 0, 1), array('[', '{')) ? json_decode(str_replace(\"'\", '\"', \$_SERVER['DOMAIN']), 1) : array(\$_SERVER['DOMAIN']))))) : '').')';"
# domain="$(php -r "$php_code")"

# if [ "$domain" == "()" ]
# then
# 	echo " ==> NOT using Access-Control-Allow-Origin headers"
# 	php_code="file_put_contents('/etc/nginx/sites-enabled/virtual.conf', preg_replace('/# == add header ==(.|\n)*# == add header ==/', '', file_get_contents('/etc/nginx/sites-enabled/virtual.conf')));"
# 	php -r "$php_code"
# elif [ "$domain" ]
# then
# 	find_replace_add_string_to_file "example\\\.com" "$domain" /etc/nginx/sites-enabled/virtual.conf "Access-Control-Allow-Origin headers for $domain"
# fi

