#!/bin/bash

# Stop execution if things fail to move forward.
set -e

# download and extract source
wget http://nginx.org/download/nginx-1.13.4.tar.gz
tar zxf nginx-1.13.4.tar.gz

# remove old directories
sudo rm -rf /var/log/nginx
sudo rm -rf /var/lib/nginx
sudo rm -rf /etc/nginx
sudo rm -rf /usr/share/nginx

# prepare required dirs (not created automatically)
sudo mkdir /var/lib/nginx
sudo mkdir /var/lib/nginx/body
sudo mkdir /var/lib/nginx/proxy
sudo mkdir /var/lib/nginx/scgi
sudo mkdir /var/lib/nginx/uwsgi

# replace nginx name
NGINX_SERVER_NAME_HEADER="$1"
if [ -z ${NGINX_SERVER_NAME_HEADER} ]; then
    echo "NGINX_SERVER_NAME_HEADER is not defined or is empty";
    exit 1
fi
CONF_FILE="nginx-1.13.4/src/http/ngx_http_header_filter_module.c"
sed "s/static u_char ngx_http_server_string\[\] = \"Server: nginx\" CRLF;/static u_char ngx_http_server_string\[\] = \"Server: ${NGINX_SERVER_NAME_HEADER}\" CRLF;/g" $CONF_FILE > "${CONF_FILE}_tmp1"
sed "s/static u_char ngx_http_server_full_string\[\] = \"Server: \" NGINX_VER CRLF;/static u_char ngx_http_server_full_string\[\] = \"Server: ${NGINX_SERVER_NAME_HEADER}\" CRLF;/g" "${CONF_FILE}_tmp1" > $CONF_FILE

# prepare user name
NGINX_USER="$2"
if [ -z ${NGINX_USER} ]; then
    echo "NGINX_USER is not defined or is empty";
    exit 1
fi

# prepare group name
NGINX_GROUP="$3"
if [ -z ${NGINX_GROUP} ]; then
    echo "NGINX_GROUP is not defined or is empty";
    exit 1
fi

# compile and install
cd nginx-1.13.4
./configure \
    --prefix=/usr/share/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/subsys/nginx \
    --sbin-path=/usr/sbin/nginx \
    --pid-path=/run/nginx.pid \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy  \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --with-debug \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_auth_request_module \
    --with-http_addition_module \
    --with-http_dav_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_v2_module \
    --with-http_sub_module \
    --with-stream_ssl_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre=../pcre-8.41 \
    --with-zlib=../zlib-1.2.11 \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_slice_module \
    --with-stream \
    --with-stream_realip_module \
    --with-openssl=../openssl-1.1.0h \
    --with-openssl-opt=enable-ec_nistp_64_gcc_128 \
    --with-openssl-opt=no-nextprotoneg \
    --with-openssl-opt=no-weak-ssl-ciphers \
    --with-openssl-opt=no-ssl3 \
    --with-stream_ssl_preread_module \
    --with-http_secure_link_module \
    --user=${NGINX_USER} \
    --group=${NGINX_GROUP} \

    #--with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' \
    #--with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now'
    #--build="1.0" \
    #--with-http_xslt_module \
    #--with-http_image_filter_module \
    #--with-http_geoip_module \

make
sudo make install
cd ..

# create init file
sudo cp nginx-init-script.sh /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo update-rc.d nginx defaults