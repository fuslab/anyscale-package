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

set -e

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to dist.dir
     --source-dir=DIR            path to package shared files dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install spark2 home [/opt/[stack_name]/[stack_version]/spark2/lib]
     --stack-home=DIR            path to install dirs [/opt/[stack_name]/[stack_version]/spark2]
     --stack-version=DIR         stack_version
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

LIB_DIR=${LIB_DIR:-$STACK_HOME/$COMPONENT_NAME}
install -d -m 0755 $PREFIX/$LIB_DIR

CONF_DIR=${CONF_DIR:-$STACK_HOME/etc/$COMPONENT_NAME/conf.dist}
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/conf/* $PREFIX/$CONF_DIR

install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/R
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/aux
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/data
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/examples
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/jars
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/licenses
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/sbin
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/yarn
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/python
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/shuffle
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/standalone-metastore

cp -a ${BUILD_DIR}/R/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/R/
cp -a ${BUILD_DIR}/yarn/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/aux/

cp -a ${BUILD_DIR}/bin/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/
rm -fr $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/*.cmd

cp -a ${BUILD_DIR}/data/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/data/
rm -fr $PREFIX/$STACK_HOME/$COMPONENT_NAME/data/mllib/images/partitioned

cp -a ${BUILD_DIR}/examples/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/examples/
cp -a ${BUILD_DIR}/jars/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/jars/
cp -a ${BUILD_DIR}/sbin/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/sbin/
cp -a ${BUILD_DIR}/licenses/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/licenses/

cp -a ${BUILD_DIR}/python/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/python/
rm -fr $PREFIX/$STACK_HOME/$COMPONENT_NAME/python/dist
rm -fr $PREFIX/$STACK_HOME/$COMPONENT_NAME/python/pip-*
rm -fr $PREFIX/$STACK_HOME/$COMPONENT_NAME/python/wheel-*
rm -fr $PREFIX/$STACK_HOME/$COMPONENT_NAME/python/test_coverage

cp -a ${BUILD_DIR}/yarn/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/shuffle/
cp -a ${BUILD_DIR}/standalone-metastore/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/standalone-metastore/

cp -a ${BUILD_DIR}/{LICENSE,NOTICE,RELEASE,README.md} ${PREFIX}/${LIB_DIR}/


install -d -m 0755 $PREFIX/var/lib/$COMPONENT_NAME
install -d -m 0755 $PREFIX/var/log/$COMPONENT_NAME
install -d -m 0755 $PREFIX/var/run/$COMPONENT_NAME
ln -s /var/log/$COMPONENT_NAME $PREFIX/$STACK_HOME/$COMPONENT_NAME/logs
ln -s /var/run/$COMPONENT_NAME/work $PREFIX/$STACK_HOME/$COMPONENT_NAME/work
ln -s /etc/$COMPONENT_NAME/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf



cat ${BUILD_DIR}/conf/spark-env.sh.template >> $PREFIX/$CONF_DIR/spark-env.sh
echo "
export HADOOP_HOME=$STACK_HOME/hadoop
export HADOOP_CONF_DIR=$STACK_HOME/hadoop/conf
" >> $PREFIX/$CONF_DIR/spark-env.sh

cat ${BUILD_DIR}/conf/spark-defaults.conf.template >> $PREFIX/$CONF_DIR/spark-defaults.conf
echo "
spark.driver.extraJavaOptions -Danyscale.version=$STACK_VERSION
spark.yarn.am.extraJavaOptions -Danyscale.version=$STACK_VERSION
" >> $PREFIX/$CONF_DIR/spark-defaults.conf