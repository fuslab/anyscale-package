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
%define component_name storm
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf


Name: %{component_name}%{soft_package_version}
Version: %{storm_version}
Release: %{storm_release}
Summary: Storm is a distributed, fault-tolerant, and high-performance realtime computation system that provides strong guarantees on the processing of data.
URL: http://www.fusionlab.cn/
Group: Applications/Server
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{storm_base_version}-src.tar.gz
Source1: bigtop.bom
Source2: do-component-build
Source3: install.sh
Source4: init.d.tmpl
Requires(pre): jdp-select
Requires(pre): zookeeper%{soft_package_version}


%description
Storm is a distributed, fault-tolerant, and high-performance realtime computation system that provides strong guarantees on the processing of data.


%prep
%setup -n %{component_name}-%{storm_base_version}-src


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
/usr/bin/rdf-select set %{component_name}-client %{stack_version}


%preun


%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/doc/
%attr(0755,root,root) %{component_install_dir}/external/
%attr(0755,root,root) %{component_install_dir}/extlib/
%attr(0755,root,root) %{component_install_dir}/extlib-daemon/
%attr(0755,root,root) %{component_install_dir}/lib/
%attr(0755,root,root) %{component_install_dir}/log4j2/
%attr(0755,root,root) %{component_install_dir}/man/
%attr(0755,root,root) %{component_install_dir}/public/

%attr(0644,root,root) %{component_install_dir}/CHANGELOG.md
%attr(0644,root,root) %{component_install_dir}/README.markdown
%attr(0644,root,root) %{component_install_dir}/RELEASE

%{component_install_dir}/logs
%{component_install_dir}/run
%{component_install_dir}/conf
