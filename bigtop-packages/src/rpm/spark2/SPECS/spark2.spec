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
%define component_name spark2
%define component_install_dir %{stack_home}/%{component_name}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf

%define spark2_services master worker
%global initd_dir /etc/rc.d/init.d/

Name: %{component_name}%{soft_package_version}
Version: %{spark2_version}
Release: %{spark2_release}
Summary: Lightning-Fast Cluster Computing
URL: http://www.fusionlab.cn
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{component_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0
Source0: %{component_name}-%{spark2_base_version}-src.tar.gz
Source1: do-component-build 
Source2: install.sh
Source3: spark2-master.svc
Source4: spark2-worker.svc
Source6: init.d.tmpl
Source7: spark2-history-server.svc
Source8: spark2-thriftserver.svc
Source9: bigtop.bom
Requires: bigtop-utils >= 0.7, hadoop-client, hadoop-yarn
Requires(pre): jdp-select
AutoReq: no


%description 
Spark2 is a MapReduce-like cluster computing framework designed to support
low-latency iterative jobs and interactive use from an interpreter. It is
written in Scala, a high-level language for the JVM, and exposes a clean
language-integrated syntax that makes it easy to write parallel jobs.
Spark2 runs on top of the Apache Mesos cluster manager.

%package master
Summary: Server for Spark2 master
Group: Development/Libraries
Requires: %{component_name} = %{version}-%{release}

%description  master
Server for Spark2 master


%package  worker
Summary: Server for Spark2 worker
Group: Development/Libraries
Requires: %{component_name} = %{version}-%{release}

%description  worker
Server for Spark2 worker


%package  python
Summary: Python client for Spark2
Group: Development/Libraries
Requires: %{component_name} = %{version}-%{release}, python

%description  python
Includes PySpark, an interactive Python shell for Spark2, and related libraries


%package  yarn-shuffle
Summary: Spark2 YARN Shuffle Service
Group: Development/Libraries

%description  yarn-shuffle
Spark2 YARN Shuffle Service


%prep
%setup -n %{component_name}-%{spark2_base_version}-src


%build
bash %{SOURCE1}


%install
%__rm -rf $RPM_BUILD_ROOT
%__install -d -m 0755 $RPM_BUILD_ROOT%{initd_dir}
%__install -d -m 0755 $RPM_BUILD_ROOT%/var/lib/%{component_name}

bash $RPM_SOURCE_DIR/install.sh \
  --build-dir=`pwd`/dist         \
  --source-dir=$RPM_SOURCE_DIR \
  --prefix=$RPM_BUILD_ROOT  \
  --stack-home=%{stack_home}  \
  --stack-version=%{stack_version}  \
  --component-name=%{component_name}


for service in %{spark2_services}
do
    init_file=$RPM_BUILD_ROOT/%{initd_dir}/%{component_name}-${service}
    bash $RPM_SOURCE_DIR/init.d.tmpl $RPM_SOURCE_DIR/%{component_name}-${service}.svc rpm $init_file
done

%pre


%post
install -d -m 0755 $PREFIX/%{config_dir}
cp -r %{stack_home}/etc/%{component_name}/conf.dist/* /etc/%{component_name}/conf/
/usr/bin/jdp-select set %{component_name}-client %{stack_version}
/usr/bin/jdp-select set %{component_name}-historyserver %{stack_version}
/usr/bin/jdp-select set %{component_name}-thriftserver %{stack_version}


%preun


%files
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}/

%attr(0755,root,root) %{stack_home}/%{etc_dir}/conf.dist/

%attr(0755,root,root) %{component_install_dir}/LICENSE
%attr(0755,root,root) %{component_install_dir}/NOTICE
%attr(0755,root,root) %{component_install_dir}/RELEASE
%attr(0755,root,root) %{component_install_dir}/README.md

%attr(0755,root,root) %{component_install_dir}/R/
%attr(0755,root,root) %{component_install_dir}/aux/
%attr(0755,root,root) %{component_install_dir}/bin/
%attr(0755,root,root) %{component_install_dir}/data/
%attr(0755,root,root) %{component_install_dir}/doc/
%attr(0755,root,root) %{component_install_dir}/examples/
%attr(0755,root,root) %{component_install_dir}/jars/
%attr(0755,root,root) %{component_install_dir}/licenses/
%attr(0755,root,root) %{component_install_dir}/sbin/
%attr(0755,root,root) %{component_install_dir}/work/
%attr(0755,root,root) %{component_install_dir}/yarn/

%{component_install_dir}/conf
#/var/lib/%{component_name}


%files  python
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}/bin/pyspark
%attr(0755,root,root) %{component_install_dir}/python/

%files  yarn-shuffle
%defattr(-,root,root,755)

%attr(0755,root,root) %{component_install_dir}/aux/


%define service_macro() \
%files  %1 \
%attr(0755,root,root)/%{component_install_dir}%{initd_dir}/%1 \
%post  %1 \
chkconfig --add %1 \
\
%preun  %1 \
if [ $1 = 0 ] ; then \
        service %1 stop > /dev/null 2>&1 \
        chkconfig --del %1 \
fi \
%postun  %1 \
if [ $1 -ge 1 ]; then \
        service %1 condrestart >/dev/null 2>&1 \
fi
%service_macro %{component_name}-master
%service_macro %{component_name}-worker

%{component_install_dir}/logs
%{component_install_dir}/run
%{component_install_dir}/conf