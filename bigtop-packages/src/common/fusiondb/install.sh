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
     --lib-dir=DIR               path to install fusiondb home [/usr/[stack_name]/[stack_version]/fusiondb/lib]
     --stack-home=DIR            path to install dirs [/usr/[stack_name]/[stack_version]/fusiondb]
     --stack-version=NAME        stack version 
     --component-name=NAME       component name
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
  -l 'stack-version:' \
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
        --stack-version)
        STACK_VERSION=$2 ; shift 2
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

# create folders structure to be distributed
INSTALL_DIR=$PREFIX/$STACK_HOME/$COMPONENT_NAME
install -d -m 0755 $INSTALL_DIR
install -d -m 0775 $INSTALL_DIR/conf

# generate fusiondb install package
echo `pwd`
cp -a $BUILD_DIR/build/* $INSTALL_DIR/

# create symlink 
ln -s /var/log/spark2 $INSTALL_DIR/logs
ln -s /var/run/spark2 $INSTALL_DIR/run
ln -s /etc/spark2/conf/spark-defaults.conf $INSTALL_DIR/conf/spark-defaults.conf