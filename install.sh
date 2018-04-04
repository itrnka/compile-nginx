#!/bin/bash

# conf
DEFAULT_NGINX_SERVER_HEADER_NAME="http-server"
DEFAULT_NGINX_USER="nginx"
DEFAULT_NGINX_GROUP="www-data"

# Stop execution if things fail to move forward.
set -e

# prepare help
display_help() {
    echo "USAGE:"
    echo "sudo ./install.sh -g group-name -u user-name -nv example.com"
    echo "sudo ./install.sh --default"
    echo ""
    echo "ARGS:"
    echo "-h|--help                     Print help info"
    echo "-g|--group                    Group name for nginx"
    echo "-u|--user                     User name for nginx"
    echo "-nv|--nginx-header-value      'Server' header value for nginx server"
    echo "--default                     use default values"
}

# parse input args
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case  $key in
    -h|--help)
        display_help;
        exit 0
        shift # past argument
        shift # past value
        ;;
    -g|--group)
        NGINX_GROUP="$2";
        shift # past argument
        shift # past value
        ;;
    -u|--user)
        NGINX_USER="$2";
        shift # past argument
        shift # past value
        ;;
    -nv|--nginx-header-value)
        NGINX_SERVER_HEADER_NAME="$2";
        shift # past argument
        shift # past value
        ;;
    --default)
        NGINX_USER="${DEFAULT_NGINX_USER}";
        NGINX_GROUP="${DEFAULT_NGINX_GROUP}";
        NGINX_SERVER_HEADER_NAME="${DEFAULT_NGINX_SERVER_HEADER_NAME}";
        shift # past argument
        ;;
    *) # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
esac
done

# check configuration
if [ -z ${NGINX_USER} ]; then
    echo "User name for nginx is not defined or is empty";
    display_help
    exit 1
fi
if [ -z ${NGINX_GROUP} ]; then
    echo "User group name for nginx is not defined or is empty";
    display_help
    exit 1
fi
if [ -z ${NGINX_SERVER_HEADER_NAME} ]; then
    echo "'Server' header value for nginx server is not defined or empty";
    display_help
    exit 1
fi

# print info and wait 10 secs to cancel
echo "Installing nginx -> 'Server: ${NGINX_SERVER_HEADER_NAME}', user: ${NGINX_USER}, group: ${NGINX_GROUP}"
echo " - Waiting 10 seconds to cancel nginx installation with this configuration (press Ctrl+C)..."
sleep 10

# helper for cleaning downloaded data
cleanData() {
    rm -rf *.tar.gz
    rm -rf pcre-8.41
    rm -rf zlib-1.2.11
    rm -rf nginx-1.13.4
    rm -rf openssl-1.1.0h
}

# install deps for compilation
apt-get update
apt-get install build-essential -y #libpcre3-dev zlib1g-dev

# rm previous
cleanData

# prepare group
groupTest="${NGINX_GROUP}:"
if grep -q ${groupTest} /etc/group
    then
         echo "Group ${NGINX_GROUP} already exists"
    else
        echo "Creating group ${NGINX_GROUP}"
        sudo addgroup ${NGINX_GROUP}
fi

# prepare user
if [ `id -u ${NGINX_USER} 2>/dev/null || echo -1` -ge 0 ]; then
    echo "User found for nginx: ${NGINX_USER}"
else
    echo "Creating user for nginx: ${NGINX_USER}"
    sudo adduser --system --no-create-home --ingroup ${NGINX_GROUP} --disabled-login --disabled-password ${NGINX_USER}
fi
sudo usermod -g ${NGINX_GROUP} ${NGINX_USER}

# install deps
bash -e ./install-pcre.sh
bash -e ./install-zlib.sh
bash -e ./install-openssl.sh
bash -e ./install-nginx.sh ${NGINX_SERVER_HEADER_NAME} ${NGINX_USER} ${NGINX_GROUP}

# rm tmp data
cleanData