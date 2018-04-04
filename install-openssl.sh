#!/bin/bash

# Stop execution if things fail to move forward.
set -e

wget http://www.openssl.org/source/openssl-1.1.0h.tar.gz
tar -zxf openssl-1.1.0h.tar.gz
cd openssl-1.1.0h
#./Configure darwin64-x86_64-cc --prefix=/usr
./Configure linux-x86_64 --prefix=/usr
make
sudo make install
cd ..