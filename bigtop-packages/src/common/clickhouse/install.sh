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
     --lib-dir=DIR               path to install clickhouse home [/opt/[stack_name]/[stack_version]/clickhouse/lib]
     --stack-home=DIR            path to install dirs [/opt/[stack_name]/[stack_version]/clickhouse]
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
cp -a ${BUILD_DIR}/programs/server/config.xml $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/programs/server/users.xml $PREFIX/$CONF_DIR

# create folders structure to be distributed
INSTALL_DIR=$PREFIX/$STACK_HOME/$COMPONENT_NAME

# cmake install clickhouse to buildroot
export CMAKE=cmake3

cd build
DAEMONS="clickhouse clickhouse-test clickhouse-compressor clickhouse-client clickhouse-server"
for daemon in $DAEMONS; do \
        DESTDIR=$PREFIX $CMAKE -DCOMPONENT=$daemon -P cmake_install.cmake; \
done
cd ..

echo `pwd`
#cp -a $PREFIX/$STACK_HOME/$COMPONENT_NAME/* $INSTALL_DIR/

# create symlink 
ln -s /var/log/${COMPONENT_NAME}-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/logs
ln -s /var/run/${COMPONENT_NAME}-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/run
ln -s /etc/${COMPONENT_NAME}-server/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf
