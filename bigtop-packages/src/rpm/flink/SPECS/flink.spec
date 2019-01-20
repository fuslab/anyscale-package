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
%define component_name flink
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{flink_version}
Release: %{flink_release}
Summary: Apache Flink is an open source platform for distributed stream and batch data processing.
URL: http://www.fusionlab.cn
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{flink_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Source5: flink-jobmanager.svc
Source6: flink-taskmanager.svc
Requires: bigtop-utils >= 0.7
Requires(pre): jdp-select
AutoReq: no


%description
Apache Flink is an open source platform for distributed stream and batch data processing.
Flink’s core is a streaming dataflow engine that provides data distribution, communication,
and fault tolerance for distributed computations over data streams.

Flink includes several APIs for creating applications that use the Flink engine:
    * DataStream API for unbounded streams embedded in Java and Scala, and
    * DataSet API for static data embedded in Java, Scala, and Python,
    * Table API with a SQL-like expression language embedded in Java and Scala.

Flink also bundles libraries for domain-specific use cases:
    * Machine Learning library, and
    * Gelly, a graph processing API and library.

Some of the key features of Apache Flink includes.
    * Complete Event Processing (CEP)
    * Fault-tolerance via Lightweight Distributed Snapshots
    * Hadoop-native YARN & HDFS implementation


%prep
%setup -n %{component_name}-%{flink_base_version}-src


%build
bash %{SOURCE2}


%install
%__rm -rf $RPM_BUILD_ROOT

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`/build         \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT  \
  --stack-home=%{stack_home}  \
  --component-name=%{component_name}


%pre


%post
install -d -m 0755 $PREFIX/%{config_dir}
cp -r %{stack_home}/etc/%{component_name}/conf.dist/* /etc/%{component_name}/conf/
/usr/bin/jdp-select set %{component_name} %{stack_version}


%preun


%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/examples/
%attr(0755,root,root) %{component_install_dir}/lib/
%attr(0755,root,root) %{component_install_dir}/licenses/
%attr(0755,root,root) %{component_install_dir}/opt/

%attr(0644,root,root) %{component_install_dir}/LICENSE
%attr(0644,root,root) %{component_install_dir}/NOTICE
%attr(0644,root,root) %{component_install_dir}/README.txt

%{component_install_dir}/log
%{component_install_dir}/run
%{component_install_dir}/conf