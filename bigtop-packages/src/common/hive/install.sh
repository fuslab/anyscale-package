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

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to path to dist.dir
     --source-dir=DIR            path to package shared files dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install Nifi home [/usr/[stack_name]/[stack_version]/hive/lib]
     --stack-home=DIR            path to install dirs [/usr/[stack_name]/[stack_version]/hive]
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

CONF_DIR=${CONF_DIR:-$STACK_HOME/etc/$COMPONENT_NAME/conf.dist}
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/conf/* $PREFIX/$CONF_DIR

install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/jdbc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/log
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/man
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/scripts







# Provide the runtime dirs
install -d -m 0755 $PREFIX/var/lib/hive
install -d -m 0755 $PREFIX/var/log/hive

install -d -m 0755 $PREFIX/var/lib/hive-hcatalog
install -d -m 0755 $PREFIX/var/log/hive-hcatalog
for DIR in ${HCATALOG_SHARE_DIR} ; do
    (cd $DIR &&
     for j in hive-hcatalog-*.jar; do
       if [[ $j =~ hive-hcatalog-(.*)-${HIVE_VERSION}.jar ]]; then
         name=${BASH_REMATCH[1]}
         ln -s $j hive-hcatalog-$name.jar
       fi
    done)
done


# Remove Windows files
find $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin -name '*.cmd' | xargs rm -f
find $PREFIX/$STACK_HOME/$COMPONENT_NAME/hive-hcatalog/bin -name '*.cmd' | xargs rm -f













MAN_DIR=$PREFIX/usr/share/man/man1
DOC_DIR=${DOC_DIR:-$PREFIX/usr/share/doc/hive}
HIVE_DIR=${HIVE_DIR:-$PREFIX/usr/lib/hive}
INSTALLED_HIVE_DIR=${INSTALLED_HIVE_DIR:-/usr/lib/hive}
EXAMPLES_DIR=${EXAMPLES_DIR:-$DOC_DIR/examples}
BIN_DIR=${BIN_DIR:-$PREFIX/usr/bin}
PYTHON_DIR=${PYTHON_DIR:-$HIVE_DIR/lib/py}
HCATALOG_DIR=${HCATALOG_DIR:-$PREFIX/usr/lib/hive-hcatalog}
HCATALOG_SHARE_DIR=${HCATALOG_DIR}/share/hcatalog
INSTALLED_HCATALOG_DIR=${INSTALLED_HCATALOG_DIR:-/usr/lib/hive-hcatalog}
CONF_DIR=/etc/hive
CONF_DIST_DIR=/etc/hive/conf.dist

# First we'll move everything into lib
install -d -m 0755 ${HIVE_DIR}
(cd ${BUILD_DIR} && tar -cf - .)|(cd ${HIVE_DIR} && tar -xf -)
rm -f ${HIVE_DIR}/lib/hive-shims-0.2*.jar
for jar in `ls ${HIVE_DIR}/lib/hive-*.jar | grep -v 'standalone.jar'`; do
    base=`basename $jar`
    (cd ${HIVE_DIR}/lib && ln -s $base ${base/-[0-9].*/.jar})
done

for thing in conf README.txt examples lib/py;
do
  rm -rf ${HIVE_DIR}/$thing
done

install -d -m 0755 ${BIN_DIR}
for file in hive beeline hiveserver2
do
  wrapper=$BIN_DIR/$file
  cat >>$wrapper <<EOF
#!/bin/bash

# Autodetect JAVA_HOME if not defined
if [ -e /usr/lib/bigtop-utils/bigtop-detect-javahome ]; then
  . /usr/lib/bigtop-utils/bigtop-detect-javahome
fi

BIGTOP_DEFAULTS_DIR=\${BIGTOP_DEFAULTS_DIR-/etc/default}
[ -n "\${BIGTOP_DEFAULTS_DIR}" -a -r \${BIGTOP_DEFAULTS_DIR}/hbase ] && . \${BIGTOP_DEFAULTS_DIR}/hbase

export HIVE_HOME=$INSTALLED_HIVE_DIR
exec $INSTALLED_HIVE_DIR/bin/$file "\$@"
EOF
  chmod 755 $wrapper
done

# Config
install -d -m 0755 ${PREFIX}${CONF_DIST_DIR}
(cd ${BUILD_DIR}/conf && tar -cf - .)|(cd ${PREFIX}${CONF_DIST_DIR} && tar -xf -)
for template in hive-exec-log4j.properties hive-log4j.properties
do
  mv ${PREFIX}${CONF_DIST_DIR}/${template}.template ${PREFIX}${CONF_DIST_DIR}/${template}
done
cp hive-site.xml ${PREFIX}${CONF_DIST_DIR}
sed -i -e "s|@VERSION@|${HIVE_VERSION}|" ${PREFIX}${CONF_DIST_DIR}/hive-site.xml

ln -s ${CONF_DIR}/conf $HIVE_DIR/conf

install -d -m 0755 $MAN_DIR
gzip -c hive.1 > $MAN_DIR/hive.1.gz

# Docs
install -d -m 0755 ${DOC_DIR}
cp ${BUILD_DIR}/README.txt ${DOC_DIR}
mv ${HIVE_DIR}/NOTICE ${DOC_DIR}
mv ${HIVE_DIR}/LICENSE ${DOC_DIR}
mv ${HIVE_DIR}/RELEASE_NOTES.txt ${DOC_DIR}


# Examples
install -d -m 0755 ${EXAMPLES_DIR}
cp -a ${BUILD_DIR}/examples/* ${EXAMPLES_DIR}

# Python libs
install -d -m 0755 ${PYTHON_DIR}
(cd $BUILD_DIR/lib/py && tar cf - .) | (cd ${PYTHON_DIR} && tar xf -)
chmod 755 ${PYTHON_DIR}/hive_metastore/*-remote

# Dir for Metastore DB
install -d -m 1777 $PREFIX/var/lib/hive/metastore/

# We need to remove the .war files. No longer supported.
rm -f ${HIVE_DIR}/lib/hive-hwi*.war

# Remove some source which gets installed
rm -rf ${HIVE_DIR}/lib/php/ext

install -d -m 0755 ${HCATALOG_DIR}
mv ${HIVE_DIR}/hcatalog/* ${HCATALOG_DIR}
rm -rf ${HIVE_DIR}/hcatalog

# Workaround for HIVE-5534
find ${HCATALOG_DIR} -name *.sh | xargs chmod 755
chmod 755 ${HCATALOG_DIR}/bin/hcat

install -d -m 0755 ${PREFIX}/etc/default
for conf in `cd ${HCATALOG_DIR}/etc ; ls -d *` ; do
  install -d -m 0755 ${PREFIX}/etc/hive-$conf
  mv ${HCATALOG_DIR}/etc/$conf ${PREFIX}/etc/hive-$conf/conf.dist
  ln -s /etc/hive-$conf/conf ${HCATALOG_DIR}/etc/$conf
  touch ${PREFIX}/etc/default/hive-$conf-server
done

wrapper=$BIN_DIR/hcat
cat >>$wrapper <<EOF
#!/bin/sh

BIGTOP_DEFAULTS_DIR=${BIGTOP_DEFAULTS_DIR-/etc/default}
[ -n "${BIGTOP_DEFAULTS_DIR}" -a -r ${BIGTOP_DEFAULTS_DIR}/hadoop ] && . ${BIGTOP_DEFAULTS_DIR}/hadoop

# Autodetect JAVA_HOME if not defined
if [ -e /usr/lib/bigtop-utils/bigtop-detect-javahome ]; then
  . /usr/lib/bigtop-utils/bigtop-detect-javahome
fi

# FIXME: HCATALOG-636 (and also HIVE-2757)
export HIVE_HOME=/usr/lib/hive
export HIVE_CONF_DIR=/etc/hive/conf
export HCAT_HOME=$INSTALLED_HCATALOG_DIR

export HCATALOG_HOME=$INSTALLED_HCATALOG_DIR
exec $INSTALLED_HCATALOG_DIR/bin/hcat "\$@"
EOF
chmod 755 $wrapper

# Install the docs
install -d -m 0755 ${DOC_DIR}
mv $HCATALOG_DIR/share/doc/hcatalog/* ${DOC_DIR}
# Might as delete the directory since it's empty now
rm -rf $HCATALOG_DIR/share/doc
install -d -m 0755 $MAN_DIR
gzip -c hive-hcatalog.1 > $MAN_DIR/hive-hcatalog.1.gz

# Provide the runtime dirs
install -d -m 0755 $PREFIX/var/lib/hive
install -d -m 0755 $PREFIX/var/log/hive

install -d -m 0755 $PREFIX/var/lib/hive-hcatalog
install -d -m 0755 $PREFIX/var/log/hive-hcatalog
for DIR in ${HCATALOG_SHARE_DIR} ; do
    (cd $DIR &&
     for j in hive-hcatalog-*.jar; do
       if [[ $j =~ hive-hcatalog-(.*)-${HIVE_VERSION}.jar ]]; then
         name=${BASH_REMATCH[1]}
         ln -s $j hive-hcatalog-$name.jar
       fi
    done)
done

# Remove Windows files
find ${HIVE_DIR}/bin -name '*.cmd' | xargs rm -f
find ${HCATALOG_DIR}/bin -name '*.cmd' | xargs rm -f
