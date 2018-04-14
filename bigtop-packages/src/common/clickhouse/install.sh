#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to dist.dir
     --source-dir=DIR            path to package shared files dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install clickhouse home [/usr/[stack_name]/[stack_version]/clickhouse/lib]
     --stack-home=DIR            path to install dirs [/usr/[stack_name]/[stack_version]/clickhouse]
     --component-name=NAME       component-name
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'lib-dir:' \
  -l 'source-dir:' \
  -l 'stack-home:' \
  -l 'component-name:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --source-dir)
        SOURCE_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --stack-home)
        STACK_HOME=$2 ; shift 2
        ;;
        --component-name)
        COMPONENT_NAME=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR SOURCE_DIR; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

if [ -f "$SOURCE_DIR/bigtop.bom" ]; then
  . $SOURCE_DIR/bigtop.bom
fi


# Generate configuration and directory
LIB_DIR=${LIB_DIR:-$STACK_HOME/$COMPONENT_NAME}
install -d -m 0755 $PREFIX/$LIB_DIR

CONF_DIR=${CONF_DIR:-$STACK_HOME/etc/${COMPONENT_NAME}-server/conf.dist}
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/dbms/src/Server/config.xml $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/dbms/src/Server/users.xml $PREFIX/$CONF_DIR

# create folders structure to be distributed
INSTALL_DIR=$PREFIX/$STACK_HOME/$COMPONENT_NAME
#install -d -m 0755 $INSTALL_DIR/bin
#install -d -m 0755 $INSTALL_DIR/share/clickhouse/bin

#install -d -m 0755 $INSTALL_DIR/share/clickhouse/headers

#install -d -m 0755 $INSTALL_DIR/share/clickhouse/headers/contrib/{libpcg-random,libcityhash,cctz}
#install -d -m 0755 $INSTALL_DIR/share/clickhouse/headers/contrib/poco/Foundation
#install -d -m 0755 $INSTALL_DIR/share/clickhouse/headers/dbms
#install -d -m 0755 $INSTALL_DIR/share/clickhouse/headers/libs/libcommon
#install -d -m 0755 $INSTALL_DIR/share/clickhouse/headers/bin

# cmake install clickhouse to buildroot

cd build
#DAEMONS="clickhouse clickhouse-test clickhouse-compressor clickhouse-client clickhouse-server"
#for daemon in $DAEMONS; do \
#        DESTDIR=$PREFIX $CMAKE -DCOMPONENT=$daemon -P cmake_install.cmake; \
#done
cp -a usr/bin $INSTALL_DIR/
cp -a usr/share $INSTALL_DIR/
cd .. 


# copy headers folder
#cp -a ${BUILD_DIR}/contrib/libsparsehash $INSTALL_DIR/share/clickhouse/headers/contrib/
#cp -a ${BUILD_DIR}/contrib/libdivide $INSTALL_DIR/share/clickhouse/headers/contrib/
#cp -a ${BUILD_DIR}/contrib/double-conversion $INSTALL_DIR/share/clickhouse/headers/contrib/
#cp -a ${BUILD_DIR}/contrib/libpcg-random/include $INSTALL_DIR/share/clickhouse/headers/contrib/libpcg-random/
#cp -a ${BUILD_DIR}/contrib/libcityhash/include $INSTALL_DIR/share/clickhouse/headers/contrib/libcityhash/
#cp -a ${BUILD_DIR}/contrib/cctz/include $INSTALL_DIR/share/clickhouse/headers/contrib/cctz/
#cp -a ${BUILD_DIR}/contrib/boost $INSTALL_DIR/share/clickhouse/headers/contrib/
#cp -a ${BUILD_DIR}/contrib/poco/Foundation/include $INSTALL_DIR/share/clickhouse/headers/contrib/poco/Foundation/


#cp -a /usr/include $INSTALL_DIR/share/clickhouse/headers/usr/

#cp -a ${BUILD_DIR}/dbms/src  $INSTALL_DIR/share/clickhouse/headers/dbms/
#cp -a ${BUILD_DIR}/build/dbms/src  $INSTALL_DIR/share/clickhouse/headers/dbms/

#cp -a ${BUILD_DIR}/libs/libcommon/include  $INSTALL_DIR/share/clickhouse/headers/libs/libcommon/
#cp -a ${BUILD_DIR}/build/libs/libcommon/include  $INSTALL_DIR/share/clickhouse/headers/libs/libcommon/

#cp -a /usr/lib64/libstdc++.so.6 $INSTALL_DIR/share/clickhouse/bin/
#cp -a /opt/rh/devtoolset-7/root/usr/bin/ld.bfd $INSTALL_DIR/share/clickhouse/bin/ld

# create symlink 
ln -s /var/log/${COMPONENT_NAME}-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/logs
ln -s /var/run/${COMPONENT_NAME}-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/run
ln -s /etc/${COMPONENT_NAME}-server/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf
