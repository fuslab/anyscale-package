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
%define component_name oozie
%define component_install_dir %{stack_home}/%{component_name}

%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{oozie_version}
Release: %{oozie_release}
Summary: Oozie is a system that runs workflows of Hadoop jobs.
URL: http://www.fusionlab.cn
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{oozie_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: oozie-env.sh
Source5: oozie.init
Source6: catalina.properties
Source7: context.xml
Source8: hive.xml
Source9: tomcat-deployment.sh
Source10: oozie-site.xml
Source11: oozie.1

Requires(pre): anyscale-select >= %{stack_version}
Requires: oozie%{soft_package_version}-client, hadoop%{soft_package_version}-client
AutoReq: no


%description 
 Oozie is a system that runs workflows of Hadoop jobs.
 Oozie workflows are actions arranged in a control dependency DAG (Direct
 Acyclic Graph).

 Oozie coordinator functionality allows to start workflows at regular
 frequencies and when data becomes available in HDFS.

 An Oozie workflow may contain the following types of actions nodes:
 map-reduce, map-reduce streaming, map-reduce pipes, pig, file-system,
 sub-workflows, java, hive, sqoop and ssh (deprecated).

 Flow control operations within the workflow can be done using decision,
 fork and join nodes. Cycles in workflows are not supported.

 Actions and decisions can be parameterized with job properties, actions
 output (i.e. Hadoop counters) and HDFS  file information (file exists,
 file size, etc). Formal parameters are expressed in the workflow definition
 as ${VARIABLE NAME} variables.

 A Workflow application is an HDFS directory that contains the workflow
 definition (an XML file), all the necessary files to run all the actions:
 JAR files for Map/Reduce jobs, shells for streaming Map/Reduce jobs, native
 libraries, Pig scripts, and other resource files.

 Running workflow jobs is done via command line tools, a WebServices API
 or a Java API.

 Monitoring the system and workflow jobs can be done via a web console, the
 command line tools, the WebServices API and the Java API.

 Oozie is a transactional system and it has built in automatic and manual
 retry capabilities.

 In case of workflow job failure, the workflow job can be rerun skipping
 previously completed actions, the workflow application can be patched before
 being rerun.



### common
%package common
Version: %{version}
Release: %{release}
Summary: Oozie common package

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description common
 Oozie common package




### client
%package client
Version: %{version}
Release: %{release}
Summary: Client for Oozie Workflow Engine

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description client
 Oozie client is a command line client utility that allows remote
 administration and monitoring of worflows. Using this client utility
 you can submit worflows, start/suspend/resume/kill workflows and
 find out their status at any instance. Apart from such operations,
 you can also change the status of the entire system, get vesion
 information. This client utility also allows you to validate
 any worflows before they are deployed to the Oozie server.




### sharelib
%package sharelib
Version: %{version}
Release: %{release}
Summary: share libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib
share libraries for oozie




### sharelib-distcp
%package sharelib-distcp
Version: %{version}
Release: %{release}
Summary: share distcp libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-distcp
share distcp libraries for oozie




### sharelib-hcatalog
%package sharelib-hcatalog
Version: %{version}
Release: %{release}
Summary: share hcatalog libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-hcatalog
share hcatalog libraries for oozie




### sharelib-hive2
%package sharelib-hive2
Version: %{version}
Release: %{release}
Summary: share hive2 libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-hive2
share hive2 libraries for oozie




### sharelib-hive
%package sharelib-hive
Version: %{version}
Release: %{release}
Summary: share hive libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-hive
share hive libraries for oozie




### sharelib-mapreduce-streaming
%package sharelib-mapreduce-streaming
Version: %{version}
Release: %{release}
Summary: share mapreduce-streaming libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-mapreduce-streaming
share mapreduce-streaming libraries for oozie




### sharelib-pig
%package sharelib-pig
Version: %{version}
Release: %{release}
Summary: share pig libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-pig
share pig libraries for oozie




### sharelib-spark
%package sharelib-spark
Version: %{version}
Release: %{release}
Summary: share spark libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-spark
share spark libraries for oozie




### sharelib-sqoop
%package sharelib-sqoop
Version: %{version}
Release: %{release}
Summary: share sqoop libraries for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description sharelib-sqoop
share sqoop libraries for oozie




### webapp
%package webapp
Version: %{version}
Release: %{release}
Summary: webapp for oozie

Group: Development/Libraries
URL: http://www.fusionlab.cn
License: ASL 2.0
BuildArch: noarch

%description webapp
webapp for oozie




%prep
%setup -n %{component_name}-%{oozie_base_version}-src


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

cp -r %{stack_home}/etc/%{component_name}/conf.client.dist/* /etc/%{component_name}/conf/

ln -s /etc/oozie/conf/oozie-env.sh %{component_install_dir}/bin/oozie-env.sh

/usr/bin/anyscale-select set %{component_name}-client %{stack_version}
/usr/bin/anyscale-select set %{component_name}-server %{stack_version}



### default ok
%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}/oozie-sharelib.tar.gz
%attr(0755,root,root) %{component_install_dir}/oozie.war



### common
%files common
%defattr(-,root,root,755)

%attr(0755,root,root) %{stack_home}/etc/%{component_name}/conf.server.dist/

%attr(0755,root,root) %{stack_home}/etc/%{component_name}/tomcat-deployment.http/conf/
%attr(0755,root,root) %{stack_home}/etc/%{component_name}/tomcat-deployment.http/WEB-INF/
%{stack_home}/etc/%{component_name}/tomcat-deployment.http/webapps

%attr(0755,root,root) %{stack_home}/etc/%{component_name}/tomcat-deployment.https/conf/
%attr(0755,root,root) %{stack_home}/etc/%{component_name}/tomcat-deployment.https/WEB-INF/
%{stack_home}/etc/%{component_name}/tomcat-deployment.https/webapps

%attr(0755,root,root) %{component_install_dir}/bin/*.sh


%attr(0755,root,root) %{component_install_dir}/etc/rc.d/init.d/oozie-server

%attr(0755,root,root) %{component_install_dir}/libext/
%attr(0755,root,root) %{component_install_dir}/libserver/
%attr(0755,root,root) %{component_install_dir}/libtools/
%attr(0755,root,root) %{component_install_dir}/oozie-server/webapps/
%{component_install_dir}/oozie-server/conf

%attr(0755,root,root) %{component_install_dir}/schema/

%attr(0755,root,root) %{component_install_dir}/share/lib/sharelib.properties


%attr(0755,root,root) %{component_install_dir}/tomcat-deployment/WEB-INF/
%attr(0755,root,root) %{component_install_dir}/tomcat-deployment/conf/
%{component_install_dir}/tomcat-deployment/webapps

%attr(0755,root,root) %{component_install_dir}/webapps/oozie/
%attr(0755,root,root) %{component_install_dir}/webapps/ROOT/
%attr(0755,root,root) %{component_install_dir}/webapps/oozie.war

%attr(0755,root,root) /var/lib/%{component_name}/data/






### client ok
%files client
%defattr(-,root,root,755)

%attr(0755,root,root) %{stack_home}/etc/%{component_name}/conf.client.dist/
%attr(0755,root,root) %{component_install_dir}/bin/oozie
%attr(0755,root,root) %{component_install_dir}/bin/oozie.distro
%attr(0755,root,root) %{component_install_dir}/doc/
%attr(0755,root,root) %{component_install_dir}/man/
%{component_install_dir}/conf





### sharelib ok
%files sharelib
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/oozie/






### sharelib-distcp ok
%files sharelib-distcp
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/distcp/






### sharelib-hcatalog ok
%files sharelib-hcatalog
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/hcatalog/






### sharelib-hive2 ok
%files sharelib-hive2
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/hive2/






### sharelib-hive ok
%files sharelib-hive
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/hive/






### sharelib-mapreduce-streaming ok
%files sharelib-mapreduce-streaming
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/mapreduce-streaming/






### sharelib-pig ok
%files sharelib-pig
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/pig/






### sharelib-spark ok
%files sharelib-spark
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/spark/






### sharelib-sqoop ok
%files sharelib-sqoop
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/share/lib/sqoop/






### webapp ok
%files webapp
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}/oozie.war
