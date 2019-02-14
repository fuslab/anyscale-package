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
     --build-dir=DIR             path to hbase dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/hbase]
     --lib-dir=DIR               path to install hbase home [/usr/lib/hbase]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     --examples-dir=DIR          path to install examples [doc-dir/examples]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'lib-dir:' \
  -l 'installed-lib-dir:' \
  -l 'bin-dir:' \
  -l 'examples-dir:' \
  -l 'conf-dir:' \
  -l 'stack-home:' \
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
        --stack-home)
        STACK_HOME=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --installed-lib-dir)
        INSTALLED_LIB_DIR=$2 ; shift 2
        ;;
        --bin-dir)
        BIN_DIR=$2 ; shift 2
        ;;
        --examples-dir)
        EXAMPLES_DIR=$2 ; shift 2
        ;;
        --conf-dir)
        CONF_DIR=$2 ; shift 2
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

MAN_DIR=${MAN_DIR:-${STACK_HOME}/hbase/man/man1}
DOC_DIR=${DOC_DIR:-${STACK_HOME}/doc/hbase}
LIB_DIR=${LIB_DIR:-${STACK_HOME}/hbase}

BIN_DIR=${BIN_DIR:-${STACK_HOME}/hbase/bin}
ETC_DIR=${ETC_DIR:-${STACK_HOME}/etc/hbase}
CONF_DIR=${CONF_DIR:-${ETC_DIR}/conf.dist}
THRIFT_DIR=${THRIFT_DIR:-${LIB_DIR}/include/thrift}

install -d -m 0755 $PREFIX/$LIB_DIR
install -d -m 0755 $PREFIX/$LIB_DIR/lib
install -d -m 0755 $PREFIX/$DOC_DIR
install -d -m 0755 $PREFIX/$BIN_DIR
install -d -m 0755 $PREFIX/$ETC_DIR
install -d -m 0755 $PREFIX/$CONF_DIR
install -d -m 0755 $PREFIX/$MAN_DIR
install -d -m 0755 $PREFIX/$THRIFT_DIR

cp -ra $BUILD_DIR/lib/* ${PREFIX}/${LIB_DIR}/lib/
cp $BUILD_DIR/lib/hbase*.jar $PREFIX/$LIB_DIR
#cp -a $BUILD_DIR/docs/* $PREFIX/$DOC_DIR
cp $BUILD_DIR/*.txt $PREFIX/$DOC_DIR/
cp -a $BUILD_DIR/hbase-webapps $PREFIX/$LIB_DIR

cp -a $BUILD_DIR/conf/* $PREFIX/$CONF_DIR
cp -a $BUILD_DIR/bin/* $PREFIX/$BIN_DIR
cp -a $BUILD_DIR/bin/hbase $PREFIX/$BIN_DIR/hbase.distro
# Purge scripts that don't work with packages
for file in rolling-restart.sh graceful_stop.sh local-regionservers.sh \
            master-backup.sh regionservers.sh zookeepers.sh hbase-daemons.sh \
            start-hbase.sh stop-hbase.sh local-master-backup.sh ; do
  rm -f $PREFIX/$BIN_DIR/$file
done

cp $BUILD_DIR/../hbase-thrift/src/main/resources/org/apache/hadoop/hbase/thrift/Hbase.thrift $PREFIX/$THRIFT_DIR/hbase1.thrift
cp $BUILD_DIR/../hbase-thrift/src/main/resources/org/apache/hadoop/hbase/thrift2/hbase.thrift $PREFIX/$THRIFT_DIR/hbase2.thrift

ln -s $ETC_DIR/conf $PREFIX/$LIB_DIR/conf

# Make a symlink of hbase.jar to hbase-version.jar
pushd `pwd`
cd $PREFIX/$LIB_DIR/lib
for i in `ls hbase*jar | grep -v tests.jar`
do
    ln -s $i `echo $i | sed -n 's/\(.*\)\(-[0-9].*\)\(.jar\)/\1\3/p'`
done
popd

wrapper=$PREFIX/${BIN_DIR}/hbase
mkdir -p `dirname $wrapper`
cat > $wrapper <<EOF
#!/bin/bash

BIGTOP_DEFAULTS_DIR=\${BIGTOP_DEFAULTS_DIR-/etc/default}
[ -n "\${BIGTOP_DEFAULTS_DIR}" -a -r \${BIGTOP_DEFAULTS_DIR}/hbase ] && . \${BIGTOP_DEFAULTS_DIR}/hbase

export HBASE_HOME=${HBASE_HOME:-${STACK_HOME}/hbase}
export HADOOP_HOME=${HADOOP_HOME:-${STACK_HOME}/hadoop}
export HADOOP_CONF=\${HADOOP_CONF:-${HADOOP_HOME}/conf}
export ZOOKEEPER_HOME=\${ZOOKEEPER_HOME:-${STACK_HOME}/zookeeper}
export HBASE_CLASSPATH=\$HADOOP_CONF:\$HADOOP_HOME/*:\$HADOOP_HOME/lib/*:\$ZOOKEEPER_HOME/*:\$HBASE_CLASSPATH
export JDP_VERSION=\${JDP_VERSION:-3.1.0.0-108}
export HBASE_OPTS="-Djdp.version=\${JDP_VERSION} \${HBASE_OPTS}"

exec ${STACK_HOME}/hbase/bin/hbase.distro "\$@"
EOF
chmod 755 $wrapper

rm -f $PREFIX/${STACK_HOME}/hbase/*.jar
