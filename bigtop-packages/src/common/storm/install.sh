#!/bin/sh

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

set -xe

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to dist.dir
     --source-dir=DIR            path to package shared files dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install Storm home [/usr/[stack_name]/[stack_version]/storm/lib]
     --stack-home=DIR            path to install dirs [/usr/[stack_name]/[stack_version]/storm]
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

LIB_DIR=${LIB_DIR:-$STACK_HOME/$COMPONENT_NAME}
install -d -m 0755 $PREFIX/$LIB_DIR

CONF_DIR=${CONF_DIR:-$STACK_HOME/etc/$COMPONENT_NAME/conf.dist}
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/conf/* $PREFIX/$CONF_DIR


install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/external
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/extlib
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/extlib-daemon
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/log4j2
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/man
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/man/man1
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/public

cp -a ${BUILD_DIR}/bin/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/
mv $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/storm $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/storm.distro
cp -a ${BUILD_DIR}/external/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/external/
#cp -a ${BUILD_DIR}/extlib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/extlib/
#cp -a ${BUILD_DIR}/extlib-daemon/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/extlib-daemon/
cp -a ${BUILD_DIR}/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib/
ln -s $STACK_HOME/zookeeper/zookeeper.jar $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib/zookeeper.jar

cp -a ${BUILD_DIR}/log4j2/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/log4j2/
cp -a ${BUILD_DIR}/public/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/public/

cp -a ${BUILD_DIR}/{CHANGELOG.md,README.markdown,RELEASE} ${PREFIX}/${LIB_DIR}/


ln -s /var/log/$COMPONENT_NAME $PREFIX/$STACK_HOME/$COMPONENT_NAME/logs
ln -s /var/run/$COMPONENT_NAME $PREFIX/$STACK_HOME/$COMPONENT_NAME/run
ln -s /etc/$COMPONENT_NAME/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf

cat > $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/storm <<EOF
#!/bin/bash
. $STACK_HOME/etc/default/hadoop
BIGTOP_DEFAULTS_DIR=\${BIGTOP_DEFAULTS_DIR-/etc/default}
[ -n "\${BIGTOP_DEFAULTS_DIR}" -a -r \${BIGTOP_DEFAULTS_DIR}/$STACK_HOME ] && . \${BIGTOP_DEFAULTS_DIR}/$STACK_HOME
exec $STACK_HOME/$COMPONENT_NAME/bin/$COMPONENT_NAME.distro "\$@"
EOF

chmod 755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/storm