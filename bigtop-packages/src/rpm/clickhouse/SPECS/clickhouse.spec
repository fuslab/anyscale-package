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

%define _binaries_in_noarch_packages_terminate_build   0
%define debug_package %{nil} 

# Set the following parameters
%define stack_name %{soft_stack_name}
%define stack_version %{soft_stack_version}

%define stack_home /opt/%{stack_name}/%{stack_version}
%define component_name clickhouse
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}-server
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{clickhouse_version}
Release: %{clickhouse_release}
Summary: ClickHouse is an open source column-oriented database management system.
URL: http://www.fusionlab.cn
Group: Applications/Engineering
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{clickhouse_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Requires(pre): anyscale-select  
Requires(pre): unixODBC
Requires(pre): libicu
AutoReq: no


%description 
ClickHouse is an open source column-oriented database management system capable of real time generation of analytical data reports using SQL queries.

%prep
%setup -n %{component_name}-%{clickhouse_base_version}-src


%build
bash %{SOURCE2}

%install
%__rm -rf $RPM_BUILD_ROOT

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`  \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT  \
  --stack-home=%{stack_home}  \
  --component-name=%{component_name}


%pre


%post
install -d -m 0755 $PREFIX/%{config_dir}
cp -r %{stack_home}/etc/%{component_name}-server/conf.dist/* /etc/%{component_name}-server/conf/
/usr/bin/anyscale-select set %{component_name}-client %{stack_version}
/usr/bin/anyscale-select set %{component_name}-server %{stack_version}


%preun


%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/share/


%{component_install_dir}/logs
%{component_install_dir}/run
%{component_install_dir}/conf