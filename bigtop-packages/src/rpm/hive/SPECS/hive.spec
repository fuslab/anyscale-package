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

# Set the following parameters

%define stack_name %{soft_stack_name}
%define stack_version %{soft_stack_version}

%define stack_home /opt/%{stack_name}/%{stack_version}
%define component_name hive
%define component_install_dir %{stack_home}/%{component_name}

%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{hive_version}
Release: %{hive_release}
Summary: Hive is a data warehouse infrastructure built on top of Hadoop
URL: http://www.fusionlab.cn
Group: Applications/Engineering
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{hive_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Source5: hive.1
Source6: hive-site.xml
Source7: hive-hcatalog.1
Source8: hive-hcatalog-server.default
Source9: hive-metastore.default
Source10: hive-server.default
Source11: hive-server2.default
Source12: hive-webhcat-server.default

Source13: hive-hcatalog-server
Source14: hive-metastore
Source15: hive-server2
Source16: hive-server
Source17: hive-webhcat-server

Patch0:451.patch

Requires(pre): jdp-select
AutoReq: no


%description 
Hive is a data warehouse infrastructure built on top of Hadoop that provides tools to enable easy data summarization, adhoc querying and analysis of large datasets data stored in Hadoop files. It provides a mechanism to put structure on this data and it also provides a simple query language called Hive QL which is based on SQL and which enables users familiar with SQL to query this data. At the same time, this language also allows traditional map/reduce programmers to be able to plug in their custom mappers and reducers to do more sophisticated analysis which may not be supported by the built-in capabilities of the language.




### hcatalog
%package hcatalog
Summary: Apache Hcatalog is a data warehouse infrastructure built on top of Hadoop
Group: Development/Libraries
Requires: hadoop, hive, bigtop-utils >= 0.7

%description hcatalog
Apache HCatalog is a table and storage management service for data created using Apache Hadoop.
This includes:
    * Providing a shared schema and data type mechanism.
    * Providing a table abstraction so that users need not be concerned with where or how their data is stored.
    * Providing interoperability across data processing tools such as Pig, Map Reduce, Streaming, and Hive.




### hcatalog-server
%package hcatalog-server
Summary: Init scripts for HCatalog server
Group: System/Daemons
Requires: %{name}-hcatalog = %{version}-%{release}
Requires: initscripts

%description hcatalog-server
Init scripts for HCatalog server




### jdbc
%package jdbc
Summary: Provides libraries necessary to connect to Apache Hive via JDBC
Group: Development/Libraries
Requires: hadoop-client

%description jdbc
This package provides libraries necessary to connect to Apache Hive via JDBC




### metastore
%package metastore
Summary: Shared metadata repository for Hive.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}
Requires(pre): %{name} = %{version}-%{release}
Requires: /lib/lsb/init-functions

%description metastore
This optional package hosts a metadata server for Hive clients across a network to use.




### server2
%package server2
Summary: Provides a Hive Thrift service with improved concurrency support.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}
Requires(pre): %{name} = %{version}-%{release}
Requires: /lib/lsb/init-functions

%description server2
This optional package hosts a Thrift server for Hive clients across a network to use with improved concurrency support.




### server
%package server
Summary: Provides a Hive Thrift service with improved concurrency support.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}
Requires(pre): %{name} = %{version}-%{release}
Requires: /lib/lsb/init-functions

%description server
This optional package hosts a Thrift server for Hive clients across a network to use with improved concurrency support.




### webhcat
%package webhcat
Summary: WebHcat provides a REST-like web API for HCatalog and related Hadoop components.
Group: Development/Libraries
Requires: %{name}-hcatalog = %{version}-%{release}

%description webhcat
WebHcat provides a REST-like web API for HCatalog and related Hadoop components.




### webhcat-server
%package webhcat-server
Summary: Init scripts for WebHcat server
Group: System/Daemons
Requires: %{name}-webhcat = %{version}-%{release}
Requires: initscripts

%description webhcat-server
Init scripts for WebHcat server.



%prep
%setup -n %{component_name}-%{hive_base_version}-src

%patch0 -p1


%build
bash %{SOURCE2}


%install
%__rm -rf $RPM_BUILD_ROOT


bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`/build  \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT \
  --stack-home=%{stack_home}  \
  --component-name=%{component_name}


%pre


%post
install -d -m 0755 $PREFIX/%{config_dir}
install -d -m 0755 $PREFIX/etc/hive_llap/conf
install -d -m 0755 $PREFIX/etc/hive-hcatalog/conf
install -d -m 0755 $PREFIX/etc/hive-webhcat/conf

cp -r %{stack_home}/etc/%{component_name}/conf.dist/* /etc/%{component_name}/conf/
cp -r %{stack_home}/etc/%{component_name}/conf_llap.dist/* /etc/hive_llap/conf
cp -r %{stack_home}/etc/%{component_name}/default/* /etc/hive-hcatalog/conf/

/usr/bin/jdp-select set %{component_name}-client %{stack_version}
/usr/bin/jdp-select set %{component_name}-metastore %{stack_version}
/usr/bin/jdp-select set %{component_name}-server2 %{stack_version}
/usr/bin/jdp-select set %{component_name}-server2-hive2 %{stack_version}
/usr/bin/jdp-select set %{component_name}-webhcat %{stack_version}


### default
%files
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/hive/conf.dist/
%attr(0755,root,root) %{stack_home}/etc/hive/conf_llap.dist/

%attr(0755,root,root) %{component_install_dir}/bin/
%exclude %{component_install_dir}/bin/hcat

%attr(0755,root,root) %{component_install_dir}/binary-package-licenses/
%attr(0755,root,root) %{component_install_dir}/doc/
%attr(0755,root,root) %{component_install_dir}/man/hive.1.*
%attr(0755,root,root) %{component_install_dir}/metastore/
%attr(0755,root,root) %{component_install_dir}/scripts/

%{component_install_dir}/conf
%{component_install_dir}/conf_llap

%attr(0755,root,root) %{component_install_dir}/lib/
%exclude %{component_install_dir}/lib/hive-jdbc-*.jar
%exclude %{component_install_dir}/lib/hive-metastore-*.jar
%exclude %{component_install_dir}/lib/hive-serde-*.jar
%exclude %{component_install_dir}/lib/hive-exec-*.jar
%exclude %{component_install_dir}/lib/libthrift-*.jar
%exclude %{component_install_dir}/lib/hive-service-*.jar
%exclude %{component_install_dir}/lib/libfb303-*.jar
%exclude %{component_install_dir}/lib/log4j-*.jar
%exclude %{component_install_dir}/lib/commons-logging-*.jar






### hcatalog
%files hcatalog
%defattr(-,root,root,755)
%dir %{stack_home}/etc/hive-hcatalog
%attr(0755,root,root) %{stack_home}/etc/hive-hcatalog/conf.dist/

%attr(0755,root,root) %{component_install_dir}/bin/hcat
%attr(0755,root,root) %{component_install_dir}/log/hive-hcatalog
%attr(0755,root,root) %{component_install_dir}/man/hive-hcatalog.1.*

%attr(0755,root,root) %{stack_home}/hive-hcatalog/bin/
%{stack_home}/hive-hcatalog/etc/hcatalog
%attr(0755,root,root) %{stack_home}/hive-hcatalog/libexec/
%attr(0755,root,root) %{stack_home}/hive-hcatalog/share/hcatalog/
%attr(0755,root,root) %{stack_home}/hive-hcatalog/sbin/update-hcatalog-env.sh
%attr(0755,root,root) %{stack_home}/hive-hcatalog/sbin/hcat_server.*
%attr(0755,root,root) %{stack_home}/hive-hcatalog/sbin/hcatcfg.*






### hcatalog-server
%files hcatalog-server
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/default/hive-hcatalog-server
%attr(0755,root,root) %{component_install_dir}/etc/rc.d/init.d/hive-hcatalog-server






### jdbc ok
%files jdbc
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/jdbc/
%attr(0755,root,root) %{component_install_dir}/lib/hive-jdbc-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/hive-metastore-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/hive-serde-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/hive-exec-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/libthrift-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/hive-service-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/libfb303-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/log4j-*.jar
%attr(0755,root,root) %{component_install_dir}/lib/commons-logging-*.jar






### metastore ok
%files metastore
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/default/hive-metastore
%attr(0755,root,root) %{component_install_dir}/etc/rc.d/init.d/hive-metastore






### server2 ok
%files server2
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/default/hive-server2
%attr(0755,root,root) %{component_install_dir}/etc/rc.d/init.d/hive-server2






### server ok
%files server
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/default/hive-server
%attr(0755,root,root) %{component_install_dir}/etc/rc.d/init.d/hive-server






### webhcat ok
%files webhcat
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/hive-webhcat/conf.dist/
%{stack_home}/hive-hcatalog/etc/webhcat
%attr(0755,root,root) %{stack_home}/hive-hcatalog/sbin/webhcat_config.sh
%attr(0755,root,root) %{stack_home}/hive-hcatalog/sbin/webhcat_server.sh
%attr(0755,root,root) %{stack_home}/hive-hcatalog/share/




### webhcat-server ok
%files webhcat-server
%defattr(-,root,root,755)
%attr(0755,root,root) %{stack_home}/etc/default/hive-webhcat-server
%attr(0755,root,root) %{component_install_dir}/etc/rc.d/init.d/hive-webhcat-server