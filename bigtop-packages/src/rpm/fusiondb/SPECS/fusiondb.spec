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
%define component_name fusiondb
%define component_install_dir %{stack_home}/%{component_name}

Name: %{component_name}%{soft_package_version}
Version: %{fusiondb_version}
Release: %{fusiondb_release}
Summary: Fusiondb is a simple and powerful federated database engine.
URL: http://www.fusiondb.cn
Group: Applications/Engineering
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{fusiondb_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Requires(pre): anyscale-select  
AutoReq: no


%description 
Fusiondb is a simple and powerful federated database engine.

%prep
%setup -n %{component_name}-%{fusiondb_base_version}-src

%build
bash %{SOURCE2}

%install
%__rm -rf $RPM_BUILD_ROOT

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`  \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT  \
  --stack-home=%{stack_home}  \
  --stack-version=%{stack_version} \
  --component-name=%{component_name}

%pre


%post
/usr/bin/anyscale-select set %{component_name} %{stack_version}


%preun


%files
%defattr(-,root,root,755)
%attr(0755,root,root) %{component_install_dir}
%attr(0755,spark,root) %{component_install_dir}/sbin/
%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/conf/
%attr(0755,root,root) %{component_install_dir}/assembly

%{component_install_dir}/logs
%{component_install_dir}/run