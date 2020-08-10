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
HTTPS_CONF=$PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.https

install -d -m 0755 $CLIENT_CONF
install -d -m 0755 $SERVER_CONF
install -d -m 0755 $HTTP_CONF
install -d -m 0755 $HTTPS_CONF

cp -a ${BUILD_DIR}/conf/* $CLIENT_CONF
cp -a ${BUILD_DIR}/conf/* $SERVER_CONF

install -d -m 0755 $HTTP_CONF/conf
cp -a ${BUILD_DIR}/oozie-server/conf/* $HTTP_CONF/conf
install -d -m 0755 $HTTP_CONF/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/classes $HTTP_CONF/WEB-INF/
cp -a ${BUILD_DIR}/WEB-INF/web.xml $HTTP_CONF/WEB-INF/

install -d -m 0755 $HTTPS_CONF/conf
cp -a ${BUILD_DIR}/oozie-server/conf/* $HTTPS_CONF/conf
install -d -m 0755 $HTTPS_CONF/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/classes $HTTPS_CONF/WEB-INF/
cp -a ${BUILD_DIR}/WEB-INF/web.xml $HTTPS_CONF/WEB-INF/


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


ln -s $STACK_HOME/$COMPONENT_NAME/webapps $PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.http/webapps
ln -s $STACK_HOME/$COMPONENT_NAME/webapps $PREFIX/$STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.https/webapps

cp -a ${BUILD_DIR}/oozie-sharelib.tar.gz $PREFIX/$STACK_HOME/$COMPONENT_NAME/

### common ok

cp -a ${BUILD_DIR}/bin/oozie*.sh $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/
cp -a $SOURCE_DIR/oozie-env.sh  $PREFIX/$STACK_HOME/$COMPONENT_NAME/bin/


ln -s /etc/oozie/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/conf


install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/
cat $SOURCE_DIR/oozie.init > $PREFIX/$STACK_HOME/$COMPONENT_NAME/etc/rc.d/init.d/oozie-server



cp -a ${BUILD_DIR}/webapps/WEB-INF/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/libserver/


cp -a ${BUILD_DIR}/libtools/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/libtools/
cp -a ${BUILD_DIR}/webapps/WEB-INF/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/libtools/




ln -s $STACK_HOME/etc/$COMPONENT_NAME/tomcat-deployment.http/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/oozie-server/conf
cp -a ${BUILD_DIR}/oozie-server/webapps $PREFIX/$STACK_HOME/$COMPONENT_NAME/oozie-server/




install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib
cp -a ${BUILD_DIR}/share/lib/sharelib.properties $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/




install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/WEB-INF
cp -a ${BUILD_DIR}/WEB-INF/classes $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/WEB-INF/
cp -a ${BUILD_DIR}/WEB-INF/web.xml $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/WEB-INF/
cp -a ${BUILD_DIR}/oozie-server/conf $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/
ln -s $STACK_HOME/$COMPONENT_NAME/webapps $PREFIX/$STACK_HOME/$COMPONENT_NAME/tomcat-deployment/webapps



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
cp -a ${BUILD_DIR}/oozie-client/{LICENSE.txt,NOTICE.txt,README.txt} $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/
cp -a ${BUILD_DIR}/oozie-examples.tar.gz $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/
cp -a ${BUILD_DIR}/docs/{release-log.txt,configuration.xsl} $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/

install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/lib
cp -a ${BUILD_DIR}/oozie-client/lib/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/doc/lib
gzip -c $SOURCE_DIR/oozie.1 > $PREFIX/$STACK_HOME/$COMPONENT_NAME/man/man1/oozie.1.gz






### sharelib
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/oozie
cp -a ${BUILD_DIR}/share/lib/oozie/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/oozie/






### sharelib-distcp
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/distcp
cp -a ${BUILD_DIR}/share/lib/distcp/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/distcp/






### sharelib-hcatalog
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hcatalog
cp -a ${BUILD_DIR}/share/lib/hcatalog/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hcatalog/






### sharelib-hive2
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hive2
cp -a ${BUILD_DIR}/share/lib/hive2/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hive2/






### sharelib-hive
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hive
cp -a ${BUILD_DIR}/share/lib/hive/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/hive/






### sharelib-mapreduce-streaming
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/mapreduce-streaming
cp -a ${BUILD_DIR}/share/lib/mapreduce-streaming/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/mapreduce-streaming/






### sharelib-pig 
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/pig
cp -a ${BUILD_DIR}/share/lib/pig/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/pig/






### sharelib-spark
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/spark
cp -a ${BUILD_DIR}/share/lib/spark/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/spark/






### sharelib-sqoop
install -d -m 0755 $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/sqoop
cp -a ${BUILD_DIR}/share/lib/sqoop/* $PREFIX/$STACK_HOME/$COMPONENT_NAME/share/lib/sqoop/






### webapp
cp -a ${BUILD_DIR}/oozie.war $PREFIX/$STACK_HOME/$COMPONENT_NAME/



install -d -m 0755 $PREFIX/var/lib/$COMPONENT_NAME/data


### **********  create binary package  **********
rm -fr ${BUILD_DIR}/../$COMPONENT_NAME-$OOZIE_VERSION-bin && mkdir ${BUILD_DIR}/../$COMPONENT_NAME-$OOZIE_VERSION-bin
cp -a $PREFIX/$STACK_HOME/* ${BUILD_DIR}/../$COMPONENT_NAME-$OOZIE_VERSION-bin/

current_path=`pwd`

cd ${BUILD_DIR}/../ && tar -zcf $COMPONENT_NAME-$OOZIE_VERSION-bin.tar.gz $COMPONENT_NAME-$OOZIE_VERSION-bin

mv $COMPONENT_NAME-$OOZIE_VERSION-bin.tar.gz $current_path/../../../tar/