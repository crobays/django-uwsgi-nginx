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

FROM crobays/django-uwsgi

ENV DOCKER_NAME django-uwsgi-nginx

RUN add-apt-repository -y ppa:nginx/stable && \
	apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get install -y software-properties-common && \
	apt-get update

RUN apt-get install -y \
	nginx

# Exposed ENV
ENV TIMEZONE Etc/UTC
ENV ENVIRONMENT production
ENV PYTHON_VERSION 2
ENV CODE_DIR src
ENV PROJECT_NAME main
ENV CUSTOM_BOILERPLATE false
ENV NGINX_CONF nginx-virtual.conf

VOLUME /project
WORKDIR /project

# HTTP ports
EXPOSE 80 443

ADD /scripts/nginx-config.sh /etc/my_init.d/06-nginx-config.sh

RUN rm -rf /etc/service/runsv
RUN mkdir /etc/service/nginx && echo "#!/bin/bash\nnginx" > /etc/service/nginx/run

RUN chmod +x /etc/my_init.d/* && chmod +x /etc/service/*/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /conf /conf

