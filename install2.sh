#!/usr/bin/env bash

ENVDIR=${ENVDIR:-~/pkgenv}
SRCDIR=${SRCDIR:-~/pkgsrc}

mkdir -p $ENVDIR
mkdir -p $ENVDIR/include
mkdir -p $ENVDIR/lib
mkdir -p $ENVDIR/lib/cmake

mkdir -p $SRCDIR

# If CentOS server, set C++ compiler manually
if [ -f /etc/redhat-release ]; then
    export CC=/opt/ohpc/pub/compiler/gcc/8.3.0/bin/gcc
    export CXX=/opt/ohpc/pub/compiler/gcc/8.3.0/bin/g++
fi

install_library() {
    git clone --depth 1 --branch $3 $2 $1
    echo "==== Installing $1 at $ENVDIR ===="
    mkdir $1/build
    pushd $1/build
    if [ -f ../CMakeLists.txt ]; then
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_PREFIX_PATH=$ENVDIR \
              -DCMAKE_INSTALL_PREFIX=$ENVDIR \
              -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
              -DCMAKE_INSTALL_RPATH=$ENVDIR \
              -DFCL_INCLUDE_DIRS=/home/$USER/pkgenv/include/fcl \
              $4 \
              ..
    elif [ -f Makefile ]; then
        cd ..
    fi

    make -j$(nproc) install
    popd
}

install_library dart https://github.com/dartsim/dart v6.9.2 \
    "-DDART_ENABLE_SIMD=ON -DFCL_INCLUDE_DIRS=$ENVDIR/include/fcl -DBULLET_INCLUDE_DIRS=$ENVDIR/include/bullet"

popd
