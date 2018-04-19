#!/bin/bash

# SWIG is a tool to compile c++ code into Python.

echo "Installing SWIG"

if [ ! -e swig-3.0.10.tar.gz ]; then
  cp exteral_tools/swig-3.0.10.tar.gz ./ || \
  wget -T 10 -t 3 \
    http://prdownloads.sourceforge.net/swig/swig-3.0.10.tar.gz || exit 1;
fi

tar -xovzf swig-3.0.10.tar.gz || exit 1
ln -s swig-3.0.10 swig

cd swig

# We first have to install PCRE.
if [ ! -e pcre-8.37.tar.gz ]; then
  cp ../exteral_tools/pcre-8.37.tar.gz ./ || \
  wget -T 10 -t 3 \
    https://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz || exit 1;
fi
Tools/pcre-build.sh

./configure --prefix=`pwd` --with-pic
make
make install

cd ..
