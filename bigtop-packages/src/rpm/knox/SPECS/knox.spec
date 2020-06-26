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

# Set brp-java-repack-jars disable
%define __jar_repack %{nil}

# Set the following parameters
%define stack_name %{soft_stack_name}
%define stack_version %{soft_stack_version}

%define stack_home /usr/%{stack_name}/%{stack_version}
%define component_name knox
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{knox_version}
Release: %{knox_release}
Summary: REST API and Application Gateway for the Apache Hadoop Ecosystem.
URL: http://knox.apache.org/
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{knox_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Requires(pre): anyscale-select
Requires(pre): ranger%{soft_package_version}-knox-plugin
AutoReq: no


%description 
Apache Knox gateway is a specialized reverse proxy gateway for various Hadoop REST APIs. However, the gateway is built entirely upon a fairly generic framework. This framework is used to “plug-in” all of the behavior that makes it specific to Hadoop in general and any particular Hadoop REST API. It would be equally as possible to create a customized reverse proxy for other non-Hadoop HTTP endpoints. This approach is taken to ensure that the Apache Knox gateway can scale with the rapidly evolving Hadoop ecosystem.

%prep
%setup -n %{component_name}-%{knox_base_version}-src


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
/usr/bin/anyscale-select set %{component_name} %{stack_version}


%preun


%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/data/
%attr(0755,root,root) %{component_install_dir}/dep/
%attr(0755,root,root) %{component_install_dir}/ext/
%attr(0755,root,root) %{component_install_dir}/lib/
%attr(0755,root,root) %{component_install_dir}/samples/
%attr(0755,root,root) %{component_install_dir}/templates/

%attr(0644,root,root) %{component_install_dir}/LICENSE
%attr(0644,root,root) %{component_install_dir}/ISSUES
%attr(0644,root,root) %{component_install_dir}/CHANGES
%attr(0644,root,root) %{component_install_dir}/NOTICE
%attr(0644,root,root) %{component_install_dir}/README

%{component_install_dir}/logs
%{component_install_dir}/run
%{component_install_dir}/conf