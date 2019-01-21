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
%define component_name livy2
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{livy2_version}
Release: %{livy2_release}
Summary: Lightning-Fast Cluster Computing livy2
URL: http://www.fusionlab.cn
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{livy2_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build 
Source3: install.sh
Requires(pre):  jdp-select
AutoReq: no


%description 
Apache Livy is an open source REST interface for interacting with Apache Spark from anywhere.
It supports executing snippets of code or programs in a Spark context that runs locally or in Apache Hadoop YARN

%prep
%setup -n %{component_name}-%{livy2_base_version}-src


%build
bash %{SOURCE2}


%install
%__rm -rf $RPM_BUILD_ROOT

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`/dist         \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT  \
  --stack-home=%{stack_home}  \
  --component-name=%{component_name}


%pre


%post
install -d -m 0755 $PREFIX/%{config_dir}
cp -r %{stack_home}/etc/%{component_name}/conf.dist/* /etc/%{component_name}/conf/
/usr/bin/jdp-select set %{component_name}-server %{stack_version}


%preun


%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/LICENSE
%attr(0755,root,root) %{component_install_dir}/NOTICE
%attr(0755,root,root) %{component_install_dir}/DISCLAIMER
%attr(0755,root,root) %{component_install_dir}/README.md

%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/jars/
%attr(0755,root,root) %{component_install_dir}/repl_2.11-jars/
%attr(0755,root,root) %{component_install_dir}/rsc-jars/

%{component_install_dir}/logs
%{component_install_dir}/run
%{component_install_dir}/conf