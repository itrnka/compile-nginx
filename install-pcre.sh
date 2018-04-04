#!/bin/bash

# Stop execution if things fail to move forward.
set -e

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz
tar -zxf pcre-8.41.tar.gz
cd pcre-8.41
./configure
make
sudo make install
cd ..