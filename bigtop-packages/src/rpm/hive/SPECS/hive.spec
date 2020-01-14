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

%define stack_home /usr/%{stack_name}/%{stack_version}
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
Requires(pre): jdp-select
AutoReq: no


%description 
Hive is a data warehouse infrastructure built on top of Hadoop that provides tools to enable easy data summarization, adhoc querying and analysis of large datasets data stored in Hadoop files. It provides a mechanism to put structure on this data and it also provides a simple query language called Hive QL which is based on SQL and which enables users familiar with SQL to query this data. At the same time, this language also allows traditional map/reduce programmers to be able to plug in their custom mappers and reducers to do more sophisticated analysis which may not be supported by the built-in capabilities of the language.





%package server2
Summary: Provides a Hive Thrift service with improved concurrency support.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}
Requires(pre): %{name} = %{version}-%{release}
Requires: /lib/lsb/init-functions

%description server2
This optional package hosts a Thrift server for Hive clients across a network to use with improved concurrency support.



%package metastore
Summary: Shared metadata repository for Hive.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}
Requires(pre): %{name} = %{version}-%{release}
Requires: /lib/lsb/init-functions

%description metastore
This optional package hosts a metadata server for Hive clients across a network to use.



%package hbase
Summary: Provides integration between Apache HBase and Apache Hive
Group: Development/Libraries
Requires: hive = %{version}-%{release}, hbase

%description hbase
This optional package provides integration between Apache HBase and Apache Hive



%package jdbc
Summary: Provides libraries necessary to connect to Apache Hive via JDBC
Group: Development/Libraries
Requires: hadoop-client

%description jdbc
This package provides libraries necessary to connect to Apache Hive via JDBC



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



%package webhcat
Summary: WebHcat provides a REST-like web API for HCatalog and related Hadoop components.
Group: Development/Libraries
Requires: %{name}-hcatalog = %{version}-%{release}

%description webhcat
WebHcat provides a REST-like web API for HCatalog and related Hadoop components.



%package hcatalog-server
Summary: Init scripts for HCatalog server
Group: System/Daemons
Requires: %{name}-hcatalog = %{version}-%{release}
Requires: initscripts

%description hcatalog-server
Init scripts for HCatalog server



%package webhcat-server
Summary: Init scripts for WebHcat server
Group: System/Daemons
Requires: %{name}-webhcat = %{version}-%{release}
Requires: initscripts

%description webhcat-server
Init scripts for WebHcat server.



%prep
%setup -n %{component_name}-%{hive_base_version}-src


%build
bash %{SOURCE2}


%install
%__rm -rf $RPM_BUILD_ROOT


cp $RPM_SOURCE_DIR/hive.1 .
cp $RPM_SOURCE_DIR/hive-hcatalog.1 .
cp $RPM_SOURCE_DIR/hive-site.xml .

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`/build  \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT \
  --stack-home=%{stack_home}  \
  --component-name=%{component_name}


%pre


%post
install -d -m 0755 $PREFIX/%{config_dir}
cp -r %{stack_home}/etc/%{component_name}/conf.dist/* /etc/%{component_name}/conf/
/usr/bin/jdp-select set %{component_name}-client %{stack_version}
/usr/bin/jdp-select set %{component_name}-server %{stack_version}




%files
%defattr(-,root,root,0755)

%attr(0755,root,root) %{component_install_dir}/

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/lib/


%attr(1777,hive,hive) %dir %{var_lib_hive}/metastore
%attr(0755,hive,hive) %dir %{var_lib_hive}
%attr(0755,hive,hive) %dir %{_localstatedir}/log/%{name}
%attr(0755,hive,hive) %dir %{_localstatedir}/run/%{name}
%doc %{doc_hive}
%{man_dir}/man1/hive.1.*
%exclude %dir %{usr_lib_hive}
%exclude %dir %{usr_lib_hive}/lib
%exclude %{usr_lib_hive}/lib/hive-jdbc-*.jar
%exclude %{usr_lib_hive}/lib/hive-metastore-*.jar
%exclude %{usr_lib_hive}/lib/hive-serde-*.jar
%exclude %{usr_lib_hive}/lib/hive-exec-*.jar
%exclude %{usr_lib_hive}/lib/libthrift-*.jar
%exclude %{usr_lib_hive}/lib/hive-service-*.jar
%exclude %{usr_lib_hive}/lib/libfb303-*.jar
%exclude %{usr_lib_hive}/lib/log4j-*.jar
%exclude %{usr_lib_hive}/lib/commons-logging-*.jar
%exclude %{usr_lib_hive}/lib/hbase-*.jar
%exclude %{usr_lib_hive}/lib/hive-hbase-handler*.jar



%files hbase
%defattr(-,root,root,755)
%{component_install_dir}/lib/hbase-*.jar
%{component_install_dir}/lib/hive-hbase-handler*.jar



%files jdbc
%defattr(-,root,root,755)
%dir %{component_install_dir}
%dir %{component_install_dir}/lib
%{component_install_dir}/lib/hive-jdbc-*.jar
%{component_install_dir}/lib/hive-metastore-*.jar
%{component_install_dir}/lib/hive-serde-*.jar
%{component_install_dir}/lib/hive-exec-*.jar
%{component_install_dir}/lib/libthrift-*.jar
%{component_install_dir}/lib/hive-service-*.jar
%{component_install_dir}/lib/libfb303-*.jar
%{component_install_dir}/lib/log4j-*.jar
%{component_install_dir}/lib/commons-logging-*.jar



%files hcatalog
%defattr(-,root,root,755)
%config(noreplace) %attr(755,root,root) %{conf_hcatalog}.dist
%attr(0775,hive,hive) %{var_lib_hcatalog}
%attr(0775,hive,hive) %{var_log_hcatalog}
%dir %{component_install_dir}
%{component_install_dir}/bin
%{component_install_dir}/etc/hcatalog
%{component_install_dir}/libexec
%{component_install_dir}/share/hcatalog
%{component_install_dir}/sbin/update-hcatalog-env.sh
%{component_install_dir}/sbin/hcat*
%{usr_bin}/hcat
%{man_dir}/man1/hive-hcatalog.1.*



%files webhcat
%defattr(-,root,root,755)
%config(noreplace) %attr(755,root,root) %{conf_webhcat}.dist
%{component_install_dir}/share/webhcat
%{component_install_dir}/etc/webhcat
%{component_install_dir}/sbin/webhcat*