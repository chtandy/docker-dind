FROM ubuntu:20.04
MAINTAINER cht.andy@gmail.com

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Taipei

## 變更預設的dash 為bash
RUN set -eux \
  && echo "######### dash > bash ##########" \
  && mv /bin/sh /bin/sh.old && ln -s /bin/bash /bin/sh

## 安裝locales 與預設語系
RUN set -eux \
  && echo "######### apt install locales and timezone ##########" \
  && apt-get update && apt-get install --assume-yes locales tzdata bash-completion \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 \
  && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

## 安裝supervisor
RUN set -eux \
  && echo "######### apt install supervisor ##########" \
  && apt-get update && apt-get install --assume-yes supervisor bash-completion \ 
  && rm -rf /var/lib/apt/lists/* && apt-get clean \ 
  && { \
     echo "[supervisord]"; \
     echo "nodaemon=true"; \
     echo "logfile=/dev/null"; \
     echo "logfile_maxbytes=0"; \
     echo "pidfile=/tmp/supervisord.pid"; \
     } > /etc/supervisor/conf.d/supervisord.conf

# 安裝 vim 並設置 /etc/vim/vimrc
RUN set -eux \
  && echo "######### apt install vim ##########" \
  && apt-get update && apt-get install vim -y \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && { \
     echo "set paste"; \
     echo "syntax on"; \ 
     echo "colorscheme torte"; \
     echo "set t_Co=256"; \
     echo "set nohlsearch"; \
     echo "set fileencodings=ucs-bom,utf-8,big5,gb18030,euc-jp,euc-kr,latin1"; \
     echo "set fileencoding=utf-8"; \
     echo "set encoding=utf-8"; \
     } >> /etc/vim/vimrc 

## 安裝工作會用到的套件
RUN set -eux \
  && echo "######### install tools ##########" \
  && apt-get update \
  && apt-get install --assume-yes git iputils-ping dnsutils netcat jq wget curl wget \
  && rm -rf /var/lib/apt/lists/* && apt-get clean

## 安裝docker CLI
ARG DockerVersion
RUN set -eux \
  && echo "######### docker client #########" \
  && curl -L -o docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-${DockerVersion}.tgz \
  && tar xf docker.tgz  \
  && mv docker/docker /usr/local/bin/docker \
  && chmod a+x /usr/local/bin/docker \
  && rm -rf docker && rm -f docker.tgz

## 安裝docker-compose
ARG DockerComposeVer
RUN set -eux \
  && echo "######### install docker-compose ##########" \
  && curl -L "https://github.com/docker/compose/releases/download/${DockerComposeVer}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose \
  && chmod +x /usr/bin/docker-compose

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
