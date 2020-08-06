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
     --lib-dir=DIR               path to install Oozie home [/opt/[stack_name]/[stack_version]/oozie/lib]
     --stack-home=DIR            path to install dirs [/opt/[stack_name]/[stack_version]/oozie]
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


### Config

CLIENT_CONF=$PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/conf.client.dist
SERVER_CONF=$PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/conf.server.dist
HTTP_CONF=$PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.http
HPPTS_CONF=$PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.https

install -d -m 0755 $CLIENT_CONF
install -d -m 0755 $SERVER_CONF
install -d -m 0755 $HTTP_CONF
install -d -m 0755 $HPPTS_CONF

cp -a ${BUILD_DIR}/conf/* $PREFIX/$CLIENT_CONF
cp -a ${BUILD_DIR}/conf/* $PREFIX/$SERVER_CONF

cp -a ${BUILD_DIR}/oozie-server/conf/* $PREFIX/$HTTP_CONF
ln -s $PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.http/webapps $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps
install -d -m 0755 $HTTP_CONF/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/classes $HTTP_CONF/WEB-INF/
cp -a ${BUILD_DIR}/WEB-INF/web.xml $HTTP_CONF/WEB-INF/

cp -a ${BUILD_DIR}/oozie-server/conf/* $PREFIX/$HPPTS_CONF
ln -s $PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.https/webapps $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps
install -d -m 0755 $HTTPS_CONF/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/classes $HTTPS_CONF/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/web.xml $HTTPS_CONF/WEB-INF


### Directory
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/lib
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/libext
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/libserver
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/libtools
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/man/man1
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/oozie-server
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/schema
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps



### common 没做

cp -a ${BUILD_DIR}/bin/oozie*.sh $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/
cp -a $SOURCE_DIR/oozie-env.sh  $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/


ln -s /etc/oozie/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf


install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/
cat $SOURCE_DIR/oozie.init > $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/oozie-server



cp -a ${BUILD_DIR}/WEB-INF/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/libserver/


cp -a ${BUILD_DIR}/libtools/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/libtools/
cp -a ${BUILD_DIR}/WEB-INF/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/libtools/




cp -a ${BUILD_DIR}/oozie-server/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/oozie-server/
cp -a ${BUILD_DIR}/oozie-server/webapps $PREFIX/$STACK_HOME/$COMPONENT_NAME/oozie-server/





cp -a ${BUILD_DIR}/share/lib/sharelib.properties $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/




install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/classes $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/WEB-INF/
cp -a ${BUILD_DIR}/WEB-INF/web.xml $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/WEB-INF/
cp -a ${BUILD_DIR}/oozie-server/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/
ln -s $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/webapps $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps



install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/oozie
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/ROOT
cp -a ${BUILD_DIR}/oozie-server/webapps/ROOT/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/ROOT/
cp -a ${BUILD_DIR}/webapps/admin $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/oozie/
cp -a ${BUILD_DIR}/webapps/console $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/oozie/
cp -a ${BUILD_DIR}/webapps/docs $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/oozie/
cp -a ${BUILD_DIR}/webapps/META-INF $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/oozie/
cp -a ${BUILD_DIR}/webapps/{index.html,oozie_50x.png,oozie-console.css,oozie-console.js} $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/oozie/
cp -a ${BUILD_DIR}/oozie.war $PREFIX/$STACK_HOME/$COMPONENT_NAME/webapps/









### Client OK

cp -a ${BUILD_DIR}/oozie-client/bin/oozie $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/
ln -s /etc/oozie/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf
cp -a ${BUILD_DIR}/oozie-client/{LICENSE.txt,NOTICE.txt,README.txt} $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/
cp -a ${BUILD_DIR}/oozie-examples.tar.gz $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/
cp -a ${BUILD_DIR}/docs/{release-log.txt,configuration.xsl} $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/

cp -a ${BUILD_DIR}/oozie-client/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/lib
gzip -c $SOURCE_DIR/oozie.1 > $PREFIX/$STACK_HOME/$COMPONENT_NAME/man/man1/oozie.1.gz






### sharelib
cp -a ${BUILD_DIR}/share/lib/oozie/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/oozie/






### sharelib-distcp
cp -a ${BUILD_DIR}/share/lib/distcp/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/distcp/






### sharelib-hcatalog
cp -a ${BUILD_DIR}/share/lib/hcatalog/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hcatalog/






### sharelib-hive2
cp -a ${BUILD_DIR}/share/lib/hive2/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hive2/






### sharelib-hive
cp -a ${BUILD_DIR}/share/lib/hive/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hive/






### sharelib-mapreduce-streaming
cp -a ${BUILD_DIR}/share/lib/mapreduce-streaming/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/mapreduce-streaming/






### sharelib-pig 
cp -a ${BUILD_DIR}/share/lib/pig/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/pig/






### sharelib-spark
cp -a ${BUILD_DIR}/share/lib/spark/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/spark/






### sharelib-sqoop
cp -a ${BUILD_DIR}/share/lib/sqoop/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/sqoop/






### webapp
cp -a ${BUILD_DIR}/oozie.war $PREFIX/$STACK_HOME/$COMPONENT_NAME/






### **********  create binary package  **********
mkdir ${BUILD_DIR}/../$COMPONENT_NAME-$OOZIE_VERSION-bin
cp -a $PREFIX/$STACK_HOME/* ${BUILD_DIR}/../$COMPONENT_NAME-$OOZIE_VERSION-bin/

current_path=`pwd`

cd ${BUILD_DIR}/../ && tar -zcf hi$COMPONENT_NAMEve-$OOZIE_VERSION-bin.tar.gz $COMPONENT_NAME-$OOZIE_VERSION-bin

mv $COMPONENT_NAME-$OOZIE_VERSION-bin.tar.gz $current_path/../../../tar/






































#!/bin/bash
set -ex

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
#

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --extra-dir=DIR    path to Bigtop distribution files
     --build-dir=DIR    path to Bigtop distribution files
     --server-dir=DIR   path to server package root
     --client-dir=DIR   path to the client package root
     --initd-dir=DIR    path to the server init.d directory

  Optional options:
     --docs-dir=DIR     path to the documentation root
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'extra-dir:' \
  -l 'build-dir:' \
  -l 'server-dir:' \
  -l 'client-dir:' \
  -l 'docs-dir:' \
  -l 'initd-dir:' \
  -l 'conf-dir:' \
  -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --extra-dir)
        EXTRA_DIR=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --server-dir)
        SERVER_PREFIX=$2 ; shift 2
        ;;
        --client-dir)
        CLIENT_PREFIX=$2 ; shift 2
        ;;
        --docs-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --initd-dir)
        INITD_DIR=$2 ; shift 2
        ;;
        --conf-dir)
        CONF_DIR=$2 ; shift 2
        ;;
        --)
        shift; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
done

for var in BUILD_DIR SERVER_PREFIX CLIENT_PREFIX; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

if [ ! -d "${BUILD_DIR}" ]; then
  echo "Build directory does not exist: ${BUILD_DIR}"
  exit 1
fi

## Install client image first
CLIENT_LIB_DIR=${CLIENT_PREFIX}/usr/lib/oozie
MAN_DIR=${CLIENT_PREFIX}/usr/share/man/man1
DOC_DIR=${DOC_DIR:-$CLIENT_PREFIX/usr/share/doc/oozie}
BIN_DIR=${CLIENT_PREFIX}/usr/bin

install -d -m 0755 ${CLIENT_LIB_DIR}
tar --strip-components=1 -zxf ${BUILD_DIR}/oozie-client-*.tar.gz -C ${CLIENT_LIB_DIR}/
install -d -m 0755 ${DOC_DIR}
mv ${CLIENT_LIB_DIR}/*.txt ${DOC_DIR}/
cp -R ${BUILD_DIR}/oozie-examples.tar.gz ${DOC_DIR}
cp -R ${BUILD_DIR}/docs/* ${DOC_DIR}
rm -rf ${DOC_DIR}/target
install -d -m 0755 ${MAN_DIR}
gzip -c ${EXTRA_DIR}/oozie.1 > ${MAN_DIR}/oozie.1.gz

# Create the /usr/bin/oozie wrapper
install -d -m 0755 $BIN_DIR
cat > ${BIN_DIR}/oozie <<EOF
#!/bin/bash
#
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

# Autodetect JAVA_HOME if not defined
. /usr/lib/bigtop-utils/bigtop-detect-javahome

exec /usr/lib/oozie/bin/oozie "\$@"
EOF
chmod 755 ${BIN_DIR}/oozie

[ -d ${SERVER_PREFIX}/usr/bin ] || install -d -m 0755 ${SERVER_PREFIX}/usr/bin
cat > ${SERVER_PREFIX}/usr/bin/oozie-setup <<'EOF'
#!/bin/bash
#
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

# Autodetect JAVA_HOME if not defined
. /usr/lib/bigtop-utils/bigtop-detect-javahome

if [ "$1" == "prepare-war" ]; then
    echo "The prepare-war command is not supported in Apache Bigtop packages."
    exit 1
fi

COMMAND="/usr/lib/oozie/bin/oozie-setup.sh $@"
su -s /bin/bash -c "$COMMAND" oozie
EOF
chmod 755 ${SERVER_PREFIX}/usr/bin/oozie-setup

## Install server image
SERVER_LIB_DIR=${SERVER_PREFIX}/usr/lib/oozie
CONF_DIR=${CONF_DIR:-"${SERVER_PREFIX}/etc/oozie/conf.dist"}
ETC_DIR=${SERVER_PREFIX}/etc/oozie
DATA_DIR=${SERVER_PREFIX}/var/lib/oozie

install -d -m 0755 ${SERVER_LIB_DIR}
install -d -m 0755 ${SERVER_LIB_DIR}/bin
install -d -m 0755 ${SERVER_LIB_DIR}/lib
install -d -m 0755 ${DATA_DIR}
for file in ooziedb.sh oozied.sh oozie-sys.sh oozie-setup.sh ; do
  cp ${BUILD_DIR}/bin/$file ${SERVER_LIB_DIR}/bin
done

install -d -m 0755 ${CONF_DIR}
cp -r ${BUILD_DIR}/conf/* ${CONF_DIR}
# Remove Windows files
rm -f ${CONF_DIR}/*.cmd

cp ${EXTRA_DIR}/oozie-site.xml ${CONF_DIR}
cp ${EXTRA_DIR}/oozie-env.sh ${CONF_DIR}
install -d -m 0755 ${CONF_DIR}/action-conf
cp ${EXTRA_DIR}/hive.xml ${CONF_DIR}/action-conf
if [ "${INITD_DIR}" != "" ]; then
  install -d -m 0755 ${INITD_DIR}
  cp -R ${EXTRA_DIR}/oozie.init ${INITD_DIR}/oozie
  chmod 755 ${INITD_DIR}/oozie
fi
cp -R ${BUILD_DIR}/oozie-sharelib*.tar.gz ${SERVER_LIB_DIR}/oozie-sharelib.tar.gz
ln -s -f /etc/oozie/conf/oozie-env.sh ${SERVER_LIB_DIR}/bin

cp -R ${BUILD_DIR}/oozie-server/webapps ${SERVER_LIB_DIR}/webapps

# Unpack oozie.war some place reasonable
WEBAPP_DIR=${SERVER_LIB_DIR}/webapps/oozie
mkdir ${WEBAPP_DIR}
(cd ${WEBAPP_DIR} ; jar xf ${BUILD_DIR}/oozie.war)
# OOZIE_HOME/lib
mv -f ${WEBAPP_DIR}/WEB-INF/lib/* ${SERVER_LIB_DIR}/lib/
touch ${SERVER_LIB_DIR}/webapps/oozie.war

install -m 0755 ${EXTRA_DIR}/tomcat-deployment.sh ${SERVER_LIB_DIR}/tomcat-deployment.sh

HTTP_DIRECTORY=${ETC_DIR}/tomcat-conf.http
install -d -m 0755 ${HTTP_DIRECTORY}
cp -R ${BUILD_DIR}/oozie-server/conf ${HTTP_DIRECTORY}/conf
cp ${EXTRA_DIR}/context.xml ${HTTP_DIRECTORY}/conf/
cp ${EXTRA_DIR}/catalina.properties ${HTTP_DIRECTORY}/conf/
install -d -m 0755 ${HTTP_DIRECTORY}/WEB-INF
mv ${SERVER_LIB_DIR}/webapps/oozie/WEB-INF/*.xml ${HTTP_DIRECTORY}/WEB-INF

HTTPS_DIRECTORY=${ETC_DIR}/tomcat-conf.https
cp -r ${HTTP_DIRECTORY} ${HTTPS_DIRECTORY}
mv ${HTTPS_DIRECTORY}/conf/ssl/ssl-server.xml ${HTTPS_DIRECTORY}/conf/server.xml
mv ${HTTPS_DIRECTORY}/conf/ssl/ssl-web.xml ${HTTPS_DIRECTORY}/WEB-INF/web.xml
rm -r ${HTTP_DIRECTORY}/conf/ssl

cp -R ${BUILD_DIR}/libtools ${SERVER_LIB_DIR}/

# Provide a convenience symlink to be more consistent with tarball deployment
ln -s ${DATA_DIR#${SERVER_PREFIX}} ${SERVER_LIB_DIR}/libext

