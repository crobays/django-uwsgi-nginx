# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM phusion/baseimage:0.9.15
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

MAINTAINER Crobays <crobays@userex.nl>
ENV DOCKER_NAME django-uwsgi-nginx
ENV DEBIAN_FRONTEND noninteractive

RUN add-apt-repository -y ppa:nginx/stable && \
	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get install -y software-properties-common

RUN apt-get install -y \
	nginx \
	python-software-properties \
	python \
	python-dev \
	python-setuptools \
	sqlite3 \
	supervisor

# install uwsgi now because it takes a little while
RUN easy_install pip
RUN pip install uwsgi
RUN pip install virtualenv

# Exposed ENV
ENV TIMEZONE Etc/UTC
ENV ENVIRONMENT prod
ENV SRC /project/src
ENV APP_NAME app
ENV ENV_NAME env
ENV NGINX_CONF nginx-virtual.conf

VOLUME  ["/project"]
WORKDIR /project

# HTTP ports
EXPOSE 80 443

RUN echo '/sbin/my_init' > /root/.bash_history

RUN echo "#!/bin/bash\necho \"\$TIMEZONE\" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata" > /etc/my_init.d/01-timezone.sh
ADD /scripts/nginx-config.sh /etc/my_init.d/02-nginx-config.sh
ADD /scripts/uwsgi-config.sh /etc/my_init.d/03-uwsgi-config.sh
ADD /scripts/django-config.sh /etc/my_init.d/04-django-config.sh

RUN mkdir /etc/service/nginx && echo "#!/bin/bash\nnginx" > /etc/service/nginx/run
RUN mkdir /etc/service/uwsgi && echo "#!/bin/bash\nsource \$SRC/\$ENV_NAME/bin/activate && cd \$SRC && uwsgi --socket=/var/run/uwsgi.sock --chmod-socket=666 --home=\$SRC/\$ENV_NAME --module=\$APP_NAME.wsgi" > /etc/service/uwsgi/run

RUN chmod +x /etc/my_init.d/* && chmod +x /etc/service/*/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /conf /conf

