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
     --build-dir=DIR             path to path to dist.dir
     --source-dir=DIR            path to package shared files dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install Nifi home [/opt/[stack_name]/[stack_version]/hive/lib]
     --stack-home=DIR            path to install dirs [/opt/[stack_name]/[stack_version]/hive]
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
  -l 'hive-version:' \
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
        --hive-version)
        HIVE_VERSION=$2 ; shift 2
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

for var in PREFIX BUILD_DIR ; do
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


### default
CONF_DIR=${CONF_DIR:-$STACK_HOME/etc/$COMPONENT_NAME/conf.dist}
CONF_LLAP_DIR=${CONF_LLAP_DIR:-$STACK_HOME/etc/$COMPONENT_NAME/conf_llap.dist}
install -d -m 0755 $PREFIX/$CONF_DIR
install -d -m 0755 $PREFIX/$CONF_LLAP_DIR
cp -a ${BUILD_DIR}/conf/* $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/conf/* $PREFIX/$CONF_LLAP_DIR
cp -a $SOURCE_DIR/hive-site.xml $PREFIX/$CONF_DIR
cp -a $SOURCE_DIR/hive-site.xml $PREFIX/$CONF_LLAP_DIR


install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/binary-package-licenses
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/man
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/metastore
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/scripts 
cp -a ${BUILD_DIR}/bin/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/
cp -a ${BUILD_DIR}/binary-package-licenses/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/binary-package-licenses/
cp -a ${BUILD_DIR}/examples $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/
cp -a ${BUILD_DIR}/{LICENSE,NOTICE,RELEASE_NOTES.txt} $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/
cp -a ${BUILD_DIR}/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib/
gzip -c $SOURCE_DIR/hive.1 > $PREFIX/$STACK_HOME/$COMPONENT_NAME/man/hive.1.gz
cp -a ${BUILD_DIR}/scripts/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/scripts/
ln -s /etc/hive/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf
ln -s /etc/hive_llap/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf_llap

cp -a ${BUILD_DIR}/hive.tar.gz $PREFIX/$STACK_HOME/$COMPONENT_NAME/


### hcatalog
HCATALOG_CONF_DIR=${HCATALOG_CONF_DIR:-$STACK_HOME/etc/hive-hcatalog/conf.dist}
install -d -m 0755 $PREFIX/$HCATALOG_CONF_DIR
cp -a ${BUILD_DIR}/hcatalog/etc/hcatalog/* $PREFIX/$HCATALOG_CONF_DIR

install -d -m 0755 $PREFIX/$STACK_HOME/hive-hcatalog
install -d -m 0755 $PREFIX/$STACK_HOME/hive-hcatalog/bin
install -d -m 0755 $PREFIX/$STACK_HOME/hive-hcatalog/etc
install -d -m 0755 $PREFIX/$STACK_HOME/hive-hcatalog/libexec
install -d -m 0755 $PREFIX/$STACK_HOME/hive-hcatalog/sbin
install -d -m 0755 $PREFIX/$STACK_HOME/hive-hcatalog/share
install -d -m 0755 $PREFIX/$STACK_HOME/hive/log/hive-hcatalog

cp -a ${BUILD_DIR}/hcatalog/bin/* $PREFIX/$STACK_HOME/hive-hcatalog/bin/
ln -s /etc/$COMPONENT_NAME-hcatalog/conf $PREFIX/$STACK_HOME/hive-hcatalog/etc/hcatalog
cp -a ${BUILD_DIR}/hcatalog/libexec/* $PREFIX/$STACK_HOME/hive-hcatalog/libexec/
cp -a ${BUILD_DIR}/hcatalog/sbin/{hcatcfg.py,hcat_server.py,hcat_server.sh,update-hcatalog-env.sh} $PREFIX/$STACK_HOME/hive-hcatalog/sbin/
cp -a ${BUILD_DIR}/hcatalog/share/hcatalog $PREFIX/$STACK_HOME/hive-hcatalog/share/

for DIR in $PREFIX/$STACK_HOME/hive-hcatalog/share/ ; do
    (cd $DIR &&
     for j in hive-hcatalog-*.jar; do
       if [[ $j =~ hive-hcatalog-(.*)-${HIVE_VERSION}.jar ]]; then
         name=${BASH_REMATCH[1]}
         ln -s $j hive-hcatalog-$name.jar
       fi
    done)
done


gzip -c $SOURCE_DIR/hive-hcatalog.1 > $PREFIX/$STACK_HOME/$COMPONENT_NAME/man/hive-hcatalog.1.gz

wrapper=$PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/hcat
install -d -m 0755 `dirname $wrapper`
cat > $wrapper <<EOF
#!/bin/sh
. $STACK_HOME/etc/default/hadoop

if [ -d "$STACK_HOME/atlas/hook/hive" ]; then
  if [ -z "${HADOOP_CLASSPATH}" ]; then
    export HADOOP_CLASSPATH=$STACK_HOME/atlas/hook/hive/*
  else
    export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:$STACK_HOME/atlas/hook/hive/*
  fi
fi


# FIXME: HCATALOG-636 (and also HIVE-2757)
export HADOOP_HOME=$STACK_HOME/hadoop
export HIVE_HOME=$STACK_HOME/hive
export HIVE_CONF_DIR=$STACK_HOME/hive/conf
export ATLAS_HOME=$STACK_HOME/atlas
export HCAT_HOME=$STACK_HOME/hive-hcatalog

export HCATALOG_HOME="$HCAT_HOME"
exec "$HCAT_HOME"/bin/hcat.distro "$@"
EOF
chmod 755 $wrapper






### hcatalog-server
DEFAULT_CONF_DIR=${DEFAULT_CONF_DIR:-$STACK_HOME/etc/default}
install -d -m 0755 $PREFIX/$DEFAULT_CONF_DIR
cp -a $SOURCE_DIR/hive-hcatalog-server.default $PREFIX/$DEFAULT_CONF_DIR/
mv $PREFIX/$DEFAULT_CONF_DIR/hive-hcatalog-server.default $PREFIX/$DEFAULT_CONF_DIR/hive-hcatalog-server

install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d
cp -a $SOURCE_DIR/hive-hcatalog-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/






### jdbc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/jdbc
cp -a ${BUILD_DIR}/jdbc/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/jdbc/






### metastore
cp -a $SOURCE_DIR/hive-metastore.default $PREFIX/$DEFAULT_CONF_DIR/
mv $PREFIX/$DEFAULT_CONF_DIR/hive-metastore.default $PREFIX/$DEFAULT_CONF_DIR/hive-metastore

cp -a $SOURCE_DIR/hive-metastore $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/






### server2
cp -a $SOURCE_DIR/hive-server2.default $PREFIX/$DEFAULT_CONF_DIR/
mv $PREFIX/$DEFAULT_CONF_DIR/hive-server2.default $PREFIX/$DEFAULT_CONF_DIR/hive-server2

cp -a $SOURCE_DIR/hive-server2 $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/






### server
cp -a $SOURCE_DIR/hive-server.default $PREFIX/$DEFAULT_CONF_DIR/
mv $PREFIX/$DEFAULT_CONF_DIR/hive-server.default $PREFIX/$DEFAULT_CONF_DIR/hive-server

cp -a $SOURCE_DIR/hive-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/






### webhcat 
WEBHCAT_CONF_DIR=${WEBHCAT_CONF_DIR:-$STACK_HOME/etc/hive-webhcat/conf.dist}
install -d -m 0755 $PREFIX/$WEBHCAT_CONF_DIR
cp -a ${BUILD_DIR}/hcatalog/etc/webhcat/* $PREFIX/$WEBHCAT_CONF_DIR

ln -s /etc/$COMPONENT_NAME-webhcat/conf $PREFIX/$STACK_HOME/hive-hcatalog/etc/webhcat
cp -a ${BUILD_DIR}/hcatalog/sbin/{webhcat_config.sh,webhcat_server.sh} $PREFIX/$STACK_HOME/hive-hcatalog/sbin/
cp -a ${BUILD_DIR}/hcatalog/share/webhcat $PREFIX/$STACK_HOME/hive-hcatalog/share/






### webhcat-server
cp -a $SOURCE_DIR/hive-webhcat-server.default $PREFIX/$DEFAULT_CONF_DIR/
mv $PREFIX/$DEFAULT_CONF_DIR/hive-webhcat-server.default $PREFIX/$DEFAULT_CONF_DIR/hive-webhcat-server

cp -a $SOURCE_DIR/hive-webhcat-server $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/


### **********  create binary package  **********
mkdir ${BUILD_DIR}/../hive-$HIVE_VERSION-bin
cp -a $PREFIX/$STACK_HOME/* ${BUILD_DIR}/../hive-$HIVE_VERSION-bin/

current_path=`pwd`

cd ${BUILD_DIR}/../ && tar -zcf hive-$HIVE_VERSION-bin.tar.gz hive-$HIVE_VERSION-bin

mv hive-$HIVE_VERSION-bin.tar.gz $current_path/../../../tar/