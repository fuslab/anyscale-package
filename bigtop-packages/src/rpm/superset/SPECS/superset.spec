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
%global _python_bytecompile_errors_terminate_build 0
%define _binaries_in_noarch_packages_terminate_build 0
%define _unpackaged_files_terminate_build 0


%define stack_name %{soft_stack_name}
%define stack_version %{soft_stack_version}

%define stack_home /usr/%{stack_name}/%{stack_version}
%define component_name superset
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{superset_version}
Release: %{superset_release}
Summary: Superset is a data exploration platform designed to be visual, intuitive and interactive
URL: http://www.jikelab.com
Group: Applications/Engineering
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{superset_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Requires(pre): jdp-select
Requires: openblas-devel, lapack, postgresql-libs, openssl >= 1.0.2k
AutoReq: no


%description
Superset is a data exploration platform designed to be visual, intuitive and interactive


%prep
%setup -n %{component_name}-%{superset_base_version}-src


%build
bash %{SOURCE2}

%install
%__rm -rf $RPM_BUILD_ROOT

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`/build  \
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

%attr(755,superset,superset) %{component_install_dir}/bin/
%attr(755,superset,superset) %{component_install_dir}/lib/
%attr(755,superset,superset) %{component_install_dir}/lib64
%attr(755,superset,superset) %{component_install_dir}/include/

%{component_install_dir}/logs
%{component_install_dir}/run
%{component_install_dir}/conf

