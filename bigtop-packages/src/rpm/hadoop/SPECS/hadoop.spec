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
#
# Hadoop RPM spec file
#

# FIXME: we need to disable a more strict checks on native files for now,
# since Hadoop build system makes it difficult to pass the kind of flags
# that would make newer RPM debuginfo generation scripts happy.
%undefine _missing_build_ids_terminate_build

# Set the following parameters
%define stack_name %{soft_stack_name}
%define stack_version %{soft_stack_version}

%define stack_home /usr/%{stack_name}/%{stack_version}
%define component_name hadoop
%define component_install_dir %{stack_home}


%define etc_dir /etc/%{component_name}
%define config_dir %{etc_dir}/conf

%define hadoop_name %{component_name}
%define etc_hadoop %{component_install_dir}/etc/%{component_name}
%define etc_yarn %{component_install_dir}/etc/yarn
%define etc_httpfs %{component_install_dir}/etc/%{component_name}-httpfs
%define config_hadoop %{etc_hadoop}/conf
%define config_yarn %{etc_yarn}/conf
%define config_httpfs %{etc_httpfs}/conf
%define tomcat_deployment_httpfs %{etc_httpfs}/tomcat-conf
%define lib_hadoop_dirname %{component_install_dir}
%define lib_hadoop %{lib_hadoop_dirname}/%{component_name}
%define lib_httpfs %{lib_hadoop_dirname}/%{component_name}-httpfs
%define lib_hdfs %{lib_hadoop_dirname}/%{component_name}-hdfs
%define lib_yarn %{lib_hadoop_dirname}/%{component_name}-yarn
%define lib_mapreduce %{lib_hadoop_dirname}/%{component_name}-mapreduce
%define log_hadoop_dirname /var/log
%define log_hadoop %{log_hadoop_dirname}/%{component_name}
%define log_yarn %{log_hadoop_dirname}/%{component_name}-yarn
%define log_hdfs %{log_hadoop_dirname}/%{component_name}-hdfs
%define log_httpfs %{log_hadoop_dirname}/%{component_name}-httpfs
%define log_mapreduce %{log_hadoop_dirname}/%{component_name}-mapreduce
%define run_hadoop_dirname /var/run
%define run_hadoop %{run_hadoop_dirname}/hadoop
%define run_yarn %{run_hadoop_dirname}/%{component_name}-yarn
%define run_hdfs %{run_hadoop_dirname}/%{component_name}-hdfs
%define run_httpfs %{run_hadoop_dirname}/%{component_name}-httpfs
%define run_mapreduce %{run_hadoop_dirname}/%{component_name}-mapreduce
%define state_hadoop_dirname %{component_install_dir}
%define state_hadoop %{state_hadoop_dirname}/hadoop
%define state_yarn %{state_hadoop_dirname}/%{component_name}-yarn
%define state_hdfs %{state_hadoop_dirname}/%{component_name}-hdfs
%define state_mapreduce %{state_hadoop_dirname}/%{component_name}-mapreduce
%define state_httpfs %{state_hadoop_dirname}/%{component_name}-httpfs
%define bin_hadoop %{component_install_dir}/%{component_name}/bin
%define man_hadoop %{component_install_dir}/%{component_name}/man
%define doc_hadoop %{component_install_dir}/%{component_name}/%{_docdir}/%{component_name}-%{hadoop_version}
%define httpfs_services httpfs
%define mapreduce_services mapreduce-historyserver
%define hdfs_services hdfs-namenode hdfs-secondarynamenode hdfs-datanode hdfs-zkfc hdfs-journalnode
%define yarn_services yarn-resourcemanager yarn-nodemanager yarn-proxyserver yarn-timelineserver yarn-timelinereader yarn-registrydns
%define hadoop_services %{hdfs_services} %{mapreduce_services} %{yarn_services} %{httpfs_services}
# Hadoop outputs built binaries into %{hadoop_build}
%define hadoop_build_path build
%define static_images_dir src/webapps/static/images
%define libexecdir /usr/lib

%ifarch i386
%global hadoop_arch Linux-i386-32
%endif
%ifarch amd64 x86_64
%global hadoop_arch Linux-amd64-64
%endif

# CentOS 5 does not have any dist macro
# So I will suppose anything that is not Mageia or a SUSE will be a RHEL/CentOS/Fedora
%if %{!?suse_version:1}0 && %{!?mgaversion:1}0

# FIXME: brp-repack-jars uses unzip to expand jar files
# Unfortunately aspectjtools-1.6.5.jar pulled by ivy contains some files and directories without any read permission
# and make whole process to fail.
# So for now brp-repack-jars is being deactivated until this is fixed.
# See BIGTOP-294
%define __os_install_post \
    %{_rpmconfigdir}/brp-compress ; \
    %{_rpmconfigdir}/brp-strip-static-archive %{__strip} ; \
    %{_rpmconfigdir}/brp-strip-comment-note %{__strip} %{__objdump} ; \
    /usr/lib/rpm/brp-python-bytecompile ; \
    %{nil}

%define netcat_package nc
%define doc_hadoop %{component_install_dir}/%{component_name}/%{_docdir}/%{component_name}-%{hadoop_version}
%define alternatives_cmd alternatives
%global initd_dir %{_sysconfdir}/rc.d/init.d
%endif


%if  %{?suse_version:1}0

# Only tested on openSUSE 11.4. le'ts update it for previous release when confirmed
%if 0%{suse_version} > 1130
%define suse_check \# Define an empty suse_check for compatibility with older sles
%endif

# Deactivating symlinks checks
%define __os_install_post \
    %{suse_check} ; \
    /usr/lib/rpm/brp-compress ; \
    %{nil}

%define netcat_package netcat-openbsd
%define doc_hadoop %{component_install_dir}/%{component_name}/%{_docdir}/%{component_name}
%define alternatives_cmd update-alternatives
%global initd_dir %{_sysconfdir}/rc.d
%endif

%if  0%{?mgaversion}
%define netcat_package netcat-openbsd
%define doc_hadoop %{component_install_dir}/%{component_name}/%{_docdir}/%{component_name}-%{hadoop_version}
%define alternatives_cmd update-alternatives
%global initd_dir %{_sysconfdir}/rc.d/init.d
%endif


# Even though we split the RPM into arch and noarch, it still will build and install
# the entirety of hadoop. Defining this tells RPM not to fail the build
# when it notices that we didn't package most of the installed files.
%define _unpackaged_files_terminate_build 0

# RPM searches perl files for dependancies and this breaks for non packaged perl lib
# like thrift so disable this
%define _use_internal_dependency_generator 0

Name:  %{component_name}%{soft_package_version}
Version: %{hadoop_version}
Release: %{hadoop_release}
Summary: Hadoop is a software platform for processing vast amounts of data
License: ASL 2.0
URL: http://hadoop.apache.org/core/
Group: Development/Libraries
Source0: %{component_name}-%{hadoop_base_version}.tar.gz
Source1: do-component-build
Source2: install_%{component_name}.sh
Source3: hadoop.default
Source4: hadoop-fuse.default
Source5: httpfs.default
Source6: hadoop.1
Source7: hadoop-fuse-dfs.1
Source8: hdfs.conf
Source9: yarn.conf
Source10: mapreduce.conf
Source11: init.d.tmpl
Source12: hadoop-hdfs-namenode.svc
Source13: hadoop-hdfs-datanode.svc
Source14: hadoop-hdfs-secondarynamenode.svc
Source15: hadoop-mapreduce-historyserver.svc
Source16: hadoop-yarn-resourcemanager.svc
Source17: hadoop-yarn-nodemanager.svc
Source18: hadoop-httpfs.svc
Source19: mapreduce.default
Source20: hdfs.default
Source21: yarn.default
Source22: hadoop-layout.sh
Source23: hadoop-hdfs-zkfc.svc
Source24: hadoop-hdfs-journalnode.svc
Source25: httpfs-tomcat-deployment.sh
Source26: yarn.1
Source27: hdfs.1
Source28: mapred.1
Source29: hadoop-yarn-timelineserver.svc
#BIGTOP_PATCH_FILES
Buildroot: %{_tmppath}/%{component_name}-%{version}-%{release}-root-%(%{__id} -u -n)
BuildRequires: fuse-devel, fuse, cmake
Requires: coreutils, /usr/sbin/useradd, /usr/sbin/usermod, /sbin/chkconfig, /sbin/service, zookeeper%{soft_package_version} >= 3.4.0, jdp-select >= %{stack_version}, spark2%{soft_package_version}-yarn-shuffle
Requires: psmisc, %{netcat_package}
# Sadly, Sun/Oracle JDK in RPM form doesn't provide libjvm.so, which means we have
# to set AutoReq to no in order to minimize confusion. Not ideal, but seems to work.
# I wish there was a way to disable just one auto dependency (libjvm.so)
AutoReq: no

%if  %{?suse_version:1}0
BuildRequires: pkg-config, libfuse2, libopenssl-devel, gcc-c++
# Required for init scripts
Requires: sh-utils, insserv
%endif

# CentOS 5 does not have any dist macro
# So I will suppose anything that is not Mageia or a SUSE will be a RHEL/CentOS/Fedora
%if %{!?suse_version:1}0 && %{!?mgaversion:1}0
BuildRequires: pkgconfig, fuse-libs, redhat-rpm-config, lzo-devel, openssl-devel
# Required for init scripts
Requires: sh-utils, redhat-lsb
%endif

%if  0%{?mgaversion}
BuildRequires: pkgconfig, libfuse-devel, libfuse2 , libopenssl-devel, gcc-c++, liblzo-devel, zlib-devel
Requires: chkconfig, xinetd-simple-services, zlib, initscripts
%endif


%description
Hadoop is a software platform that lets one easily write and
run applications that process vast amounts of data.

Here's what makes Hadoop especially useful:
* Scalable: Hadoop can reliably store and process petabytes.
* Economical: It distributes the data and processing across clusters
              of commonly available computers. These clusters can number
              into the thousands of nodes.
* Efficient: By distributing the data, Hadoop can process it in parallel
             on the nodes where the data is located. This makes it
             extremely rapid.
* Reliable: Hadoop automatically maintains multiple copies of data and
            automatically redeploys computing tasks based on failures.

Hadoop implements MapReduce, using the Hadoop Distributed File System (HDFS).
MapReduce divides applications into many small blocks of work. HDFS creates
multiple replicas of data blocks for reliability, placing them on compute
nodes around the cluster. MapReduce can then process the data where it is
located.

%package hdfs
Summary: The Hadoop Distributed File System
Group: System/Daemons
Requires: %{component_name}%{soft_package_version} = %{version}-%{release}, bigtop-jsvc, libtirpc-devel

%description hdfs
Hadoop Distributed File System (HDFS) is the primary storage system used by
Hadoop applications. HDFS creates multiple replicas of data blocks and distributes
them on compute nodes throughout a cluster to enable reliable, extremely rapid
computations.

%package yarn
Summary: The Hadoop NextGen MapReduce (YARN)
Group: System/Daemons
Requires: %{component_name}%{soft_package_version} = %{version}-%{release}

%description yarn
YARN (Hadoop NextGen MapReduce) is a general purpose data-computation framework.
The fundamental idea of YARN is to split up the two major functionalities of the
JobTracker, resource management and job scheduling/monitoring, into separate daemons:
ResourceManager and NodeManager.

The ResourceManager is the ultimate authority that arbitrates resources among all
the applications in the system. The NodeManager is a per-node slave managing allocation
of computational resources on a single node. Both work in support of per-application
ApplicationMaster (AM).

An ApplicationMaster is, in effect, a framework specific library and is tasked with
negotiating resources from the ResourceManager and working with the NodeManager(s) to
execute and monitor the tasks.


%package mapreduce
Summary: The Hadoop MapReduce (MRv2)
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description mapreduce
Hadoop MapReduce is a programming model and software framework for writing applications
that rapidly process vast amounts of data in parallel on large clusters of compute nodes.


%package hdfs-namenode
Summary: The Hadoop namenode manages the block locations of HDFS files
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}

%description hdfs-namenode
The Hadoop Distributed Filesystem (HDFS) requires one unique server, the
namenode, which manages the block locations of files on the filesystem.


%package hdfs-secondarynamenode
Summary: Hadoop Secondary namenode
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}

%description hdfs-secondarynamenode
The Secondary Name Node periodically compacts the Name Node EditLog
into a checkpoint.  This compaction ensures that Name Node restarts
do not incur unnecessary downtime.

%package hdfs-zkfc
Summary: Hadoop HDFS failover controller
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}

%description hdfs-zkfc
The Hadoop HDFS failover controller is a ZooKeeper client which also
monitors and manages the state of the NameNode. Each of the machines
which runs a NameNode also runs a ZKFC, and that ZKFC is responsible
for: Health monitoring, ZooKeeper session management, ZooKeeper-based
election.

%package hdfs-journalnode
Summary: Hadoop HDFS JournalNode
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}

%description hdfs-journalnode
The HDFS JournalNode is responsible for persisting NameNode edit logs.
In a typical deployment the JournalNode daemon runs on at least three
separate machines in the cluster.

%package hdfs-datanode
Summary: Hadoop Data Node
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}

%description hdfs-datanode
The Data Nodes in the Hadoop Cluster are responsible for serving up
blocks of data over the network to Hadoop Distributed Filesystem
(HDFS) clients.

%package httpfs-server
Summary: HTTPFS-SERVER for Hadoop
Group: System/Daemons

%description httpfs-server
The server providing HTTP-SERVER REST API support for the complete FileSystem/FileContext
interface in HDFS.

%package httpfs
Summary: HTTPFS for Hadoop
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}, bigtop-tomcat
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-httpfs-server = %{version}-%{release}

%description httpfs
The server providing HTTP REST API support for the complete FileSystem/FileContext
interface in HDFS.

%package yarn-resourcemanager
Summary: YARN Resource Manager
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description yarn-resourcemanager
The resource manager manages the global assignment of compute resources to applications

%package yarn-nodemanager
Summary: YARN Node Manager
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description yarn-nodemanager
The NodeManager is the per-machine framework agent who is responsible for
containers, monitoring their resource usage (cpu, memory, disk, network) and
reporting the same to the ResourceManager/Scheduler.

%package yarn-proxyserver
Summary: YARN Web Proxy
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description yarn-proxyserver
The web proxy server sits in front of the YARN application master web UI.

%package yarn-timelineserver
Summary: YARN Timeline Server
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description yarn-timelineserver
Storage and retrieval of applications' current as well as historic information in a generic fashion is solved in YARN through the Timeline Server.

%package yarn-timelinereader
Summary: YARN Timeline Reader
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description yarn-timelinereader
YARN Timeline Service V2, The timeline readers are separate daemons separate from the timeline collectors, and they are dedicated to serving queries via REST API.

%package yarn-registrydns
Summary: YARN Registry DNS
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-yarn = %{version}-%{release}

%description yarn-registrydns
The Registry DNS Server provides a standard DNS interface to the information posted into the YARN Registry by deployed applications.

%package mapreduce-historyserver
Summary: MapReduce History Server
Group: System/Daemons
Requires: %{component_name}%{soft_package_version}-mapreduce = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version} = %{version}-%{release}
Requires(pre): %{component_name}%{soft_package_version}-mapreduce = %{version}-%{release}

%description mapreduce-historyserver
The History server keeps records of the different activities being performed on a Apache Hadoop cluster

%package client
Summary: Hadoop client side dependencies
Group: System/Daemons
Requires: %{component_name}%{soft_package_version} = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-yarn = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-mapreduce = %{version}-%{release}

%description client
Installation of this package will provide you with all the dependencies for Hadoop clients.

%package conf-pseudo
Summary: Pseudo-distributed Hadoop configuration
Group: System/Daemons
Requires: %{component_name}%{soft_package_version} = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-hdfs-namenode = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-hdfs-datanode = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-hdfs-secondarynamenode = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-yarn-resourcemanager = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-yarn-nodemanager = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-mapreduce-historyserver = %{version}-%{release}

%description conf-pseudo
Contains configuration files for a "pseudo-distributed" Hadoop deployment.
In this mode, each of the hadoop components runs as a separate Java process,
but all on the same machine.

%package doc
Summary: Hadoop Documentation
Group: Documentation
%description doc
Documentation for Hadoop

%package libhdfs
Summary: Hadoop Filesystem Library
Group: Development/Libraries
Requires: %{component_name}%{soft_package_version}-hdfs = %{version}-%{release}
# TODO: reconcile libjvm
AutoReq: no

%description libhdfs
Hadoop Filesystem Library

%package hdfs-fuse
Summary: Mountable HDFS
Group: Development/Libraries
Requires: %{component_name}%{soft_package_version} = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-libhdfs = %{version}-%{release}
Requires: %{component_name}%{soft_package_version}-client = %{version}-%{release}
Requires: fuse
AutoReq: no

%if %{?suse_version:1}0
Requires: libfuse2
%else
Requires: fuse-libs
%endif


%description hdfs-fuse
These projects (enumerated below) allow HDFS to be mounted (on most flavors of Unix) as a standard file system using


%prep
%setup -n %{component_name}-%{hadoop_base_version}-src

#BIGTOP_PATCH_COMMANDS
%build
# This assumes that you installed Java JDK 6 and set JAVA_HOME
# This assumes that you installed Forrest and set FORREST_HOME

env HADOOP_VERSION=%{hadoop_base_version} HADOOP_ARCH=%{hadoop_arch} bash %{SOURCE1}

%clean
%__rm -rf $RPM_BUILD_ROOT

#########################
#### INSTALL SECTION ####
#########################
%install
%__rm -rf $RPM_BUILD_ROOT

%__install -d -m 0755 $RPM_BUILD_ROOT/%{lib_hadoop}

env HADOOP_VERSION=%{hadoop_base_version} bash %{SOURCE2} \
  --stack-home=%{component_install_dir} \
  --distro-dir=$RPM_SOURCE_DIR \
  --build-dir=$PWD/build \
  --httpfs-dir=$RPM_BUILD_ROOT%{lib_httpfs} \
  --system-include-dir=$RPM_BUILD_ROOT/%{component_install_dir}/%{_includedir} \
  --system-lib-dir=$RPM_BUILD_ROOT/%{component_install_dir}/%{_libdir} \
  --system-libexec-dir=$RPM_BUILD_ROOT/%{lib_hadoop}/libexec \
  --hadoop-etc-dir=$RPM_BUILD_ROOT%{etc_hadoop} \
  --httpfs-etc-dir=$RPM_BUILD_ROOT%{etc_httpfs} \
  --prefix=$RPM_BUILD_ROOT \
  --doc-dir=$RPM_BUILD_ROOT%{doc_hadoop} \
  --example-dir=$RPM_BUILD_ROOT%{doc_hadoop}/examples \
  --native-build-string=%{hadoop_arch} \
  --installed-lib-dir=%{lib_hadoop} \
  --man-dir=$RPM_BUILD_ROOT%{man_hadoop} \

# Forcing Zookeeper dependency to be on the packaged jar
# %__ln_s -f /usr/lib/zookeeper/zookeeper.jar $RPM_BUILD_ROOT/%{lib_hadoop}/lib/zookeeper*.jar
# Workaround for BIGTOP-583
#%__rm -f $RPM_BUILD_ROOT/%{lib_hadoop}-*/lib/slf4j-log4j12-*.jar

# Init.d scripts
%__install -d -m 0755 $RPM_BUILD_ROOT/%{component_install_dir}/%{initd_dir}/

# Install top level /etc/default files
%__install -d -m 0755 $RPM_BUILD_ROOT/%{component_install_dir}/etc/default
%__cp $RPM_SOURCE_DIR/hadoop.default $RPM_BUILD_ROOT/%{component_install_dir}/etc/default/hadoop
# FIXME: BIGTOP-463
echo 'export JSVC_HOME=%{libexecdir}/bigtop-utils' >> $RPM_BUILD_ROOT/%{component_install_dir}/etc/default/hadoop
%__cp $RPM_SOURCE_DIR/%{component_name}-fuse.default $RPM_BUILD_ROOT/%{component_install_dir}/etc/default/%{component_name}-fuse

# Generate the init.d scripts
for service in %{hadoop_services}
do
      if [[ $service == "yarn"* ]]; then
        bash %{SOURCE11} $RPM_SOURCE_DIR/%{component_name}-${service}.svc rpm $RPM_BUILD_ROOT/%{component_install_dir}/%{component_name}-yarn/%{initd_dir}/%{component_name}-${service}
      elif [[ $service == "hdfs"* ]]; then
        bash %{SOURCE11} $RPM_SOURCE_DIR/%{component_name}-${service}.svc rpm $RPM_BUILD_ROOT/%{component_install_dir}/%{component_name}-hdfs/%{initd_dir}/%{component_name}-${service}
      elif [[ $service == "mapreduce"* ]]; then
        bash %{SOURCE11} $RPM_SOURCE_DIR/%{component_name}-${service}.svc rpm $RPM_BUILD_ROOT/%{component_install_dir}/%{component_name}-mapreduce/%{initd_dir}/%{component_name}-${service}
      else
        bash %{SOURCE11} $RPM_SOURCE_DIR/%{component_name}-${service}.svc rpm $RPM_BUILD_ROOT/%{component_install_dir}/%{component_name}-${service}/%{initd_dir}/%{component_name}-${service}
      fi
      cp $RPM_SOURCE_DIR/${service/-*/}.default $RPM_BUILD_ROOT/%{component_install_dir}/etc/default/%{component_name}-${service}
      chmod 644 $RPM_BUILD_ROOT/%{component_install_dir}/etc/default/%{component_name}-${service}
done

# Init.d scripts to httpfs-server
# %__cp $RPM_BUILD_ROOT/%{component_install_dir}/%{initd_dir}/%{component_name}-httpfs $RPM_BUILD_ROOT/%{component_install_dir}/%{component_name}-httpfs/%{initd_dir}/%{component_name}-httpfs

# Install security limits
%__install -d -m 0755 $RPM_BUILD_ROOT/%{component_install_dir}/etc/security/limits.d
%__install -m 0644 %{SOURCE8} $RPM_BUILD_ROOT/%{component_install_dir}/etc/security/limits.d/hdfs.conf
%__install -m 0644 %{SOURCE9} $RPM_BUILD_ROOT/%{component_install_dir}/etc/security/limits.d/yarn.conf
%__install -m 0644 %{SOURCE10} $RPM_BUILD_ROOT/%{component_install_dir}/etc/security/limits.d/mapreduce.conf

# Install fuse default file
%__install -d -m 0755 $RPM_BUILD_ROOT/%{component_install_dir}/etc/default
%__cp %{SOURCE4} $RPM_BUILD_ROOT/%{component_install_dir}/etc/default/hadoop-fuse

# /var/lib/*/cache
#%__install -d -m 1777 $RPM_BUILD_ROOT/%{state_yarn}/cache
#%__install -d -m 1777 $RPM_BUILD_ROOT/%{state_hdfs}/cache
#%__install -d -m 1777 $RPM_BUILD_ROOT/%{state_mapreduce}/cache
# /var/log/*
%__install -d -m 0755 $RPM_BUILD_ROOT/%{log_yarn}
%__install -d -m 0755 $RPM_BUILD_ROOT/%{log_hdfs}
%__install -d -m 0755 $RPM_BUILD_ROOT/%{log_mapreduce}
%__install -d -m 0755 $RPM_BUILD_ROOT/%{log_httpfs}
# /var/run/*
%__install -d -m 0755 $RPM_BUILD_ROOT/%{run_yarn}
%__install -d -m 0755 $RPM_BUILD_ROOT/%{run_hdfs}
%__install -d -m 0755 $RPM_BUILD_ROOT/%{run_mapreduce}
%__install -d -m 0755 $RPM_BUILD_ROOT/%{run_httpfs}

%pre
getent group hadoop >/dev/null || groupadd -r hadoop

%pre hdfs
getent group hdfs >/dev/null   || groupadd -r hdfs
getent passwd hdfs >/dev/null || /usr/sbin/useradd --comment "Hadoop HDFS" --shell /bin/bash -M -r -g hdfs -G hadoop --home %{state_hdfs} hdfs

%pre httpfs
getent group httpfs >/dev/null   || groupadd -r httpfs
getent passwd httpfs >/dev/null || /usr/sbin/useradd --comment "Hadoop HTTPFS" --shell /bin/bash -M -r -g httpfs -G httpfs --home %{run_httpfs} httpfs

%pre yarn
getent group yarn >/dev/null   || groupadd -r yarn
getent passwd yarn >/dev/null || /usr/sbin/useradd --comment "Hadoop Yarn" --shell /bin/bash -M -r -g yarn -G hadoop --home %{state_yarn} yarn

%pre mapreduce
getent group mapred >/dev/null   || groupadd -r mapred
getent passwd mapred >/dev/null || /usr/sbin/useradd --comment "Hadoop MapReduce" --shell /bin/bash -M -r -g mapred -G hadoop --home %{state_mapreduce} mapred

%post
#%{alternatives_cmd} --install %{config_hadoop} %{component_name}-conf %{etc_hadoop}/conf.empty 10
cp -r %{stack_home}/etc/%{component_name}/conf.empty /etc/%{component_name}/conf
/usr/bin/jdp-select set %{component_name}-client %{stack_version}

%post httpfs
%{alternatives_cmd} --install %{config_httpfs} %{component_name}-httpfs-conf %{etc_httpfs}/conf.empty 10
%{alternatives_cmd} --install %{tomcat_deployment_httpfs} %{component_name}-httpfs-tomcat-conf %{etc_httpfs}/tomcat-conf.dist 10
%{alternatives_cmd} --install %{tomcat_deployment_httpfs} %{component_name}-httpfs-tomcat-conf %{etc_httpfs}/tomcat-conf.https 5

chkconfig --add %{component_name}-httpfs

%preun
if [ "$1" = 0 ]; then
  %{alternatives_cmd} --remove %{component_name}-conf %{etc_hadoop}/conf.empty || :
fi

%preun httpfs
if [ $1 = 0 ]; then
  service %{component_name}-httpfs stop > /dev/null 2>&1
  chkconfig --del %{component_name}-httpfs
  %{alternatives_cmd} --remove %{component_name}-httpfs-conf %{etc_httpfs}/conf.empty || :
  %{alternatives_cmd} --remove %{component_name}-httpfs-tomcat-conf %{etc_httpfs}/tomcat-conf.dist || :
  %{alternatives_cmd} --remove %{component_name}-httpfs-tomcat-conf %{etc_httpfs}/tomcat-conf.https || :
fi

%postun httpfs
if [ $1 -ge 1 ]; then
  service %{component_name}-httpfs condrestart >/dev/null 2>&1
fi


%files yarn
%defattr(-,root,root)
%config(noreplace) %{etc_hadoop}/conf.empty/yarn-env.sh
%config(noreplace) %{etc_hadoop}/conf.empty/yarn-site.xml
%config(noreplace) %{etc_hadoop}/conf.empty/capacity-scheduler.xml
%config(noreplace) %{etc_hadoop}/conf.empty/container-executor.cfg
%config(noreplace) %{component_install_dir}/etc/security/limits.d/yarn.conf
%{lib_hadoop}/libexec/yarn-config.sh
%{lib_yarn}
%{lib_yarn}/lib/service-dep.tar.gz
%{lib_yarn}/timelineservice
%{lib_yarn}/yarn-service-examples
%attr(4754,root,yarn) %{lib_yarn}/bin/container-executor
%{bin_hadoop}/yarn
#%attr(0775,yarn,hadoop) %{run_yarn}
#%attr(0775,yarn,hadoop) %{log_yarn}
%attr(0755,yarn,hadoop) %{state_yarn}
#%attr(1777,yarn,hadoop) %{state_yarn}/cache
%exclude %{component_install_dir}/%{component_name}-yarn/%{initd_dir}/%{component_name}-yarn-*

%files hdfs
%defattr(-,root,root)
%config(noreplace) %{etc_hadoop}/conf.empty/hdfs-site.xml
%config(noreplace) %{component_install_dir}/etc/security/limits.d/hdfs.conf
%{lib_hdfs}
%{lib_hadoop}/libexec/hdfs-config.sh
%{bin_hadoop}/hdfs
#%attr(0775,hdfs,hadoop) %{run_hdfs}
#%attr(0775,hdfs,hadoop) %{log_hdfs}
%attr(0755,hdfs,hadoop) %{state_hdfs}
#%attr(1777,hdfs,hadoop) %{state_hdfs}/cache
%{lib_hadoop}/libexec/init-hdfs.sh
#%{lib_hadoop}/libexec/init-hcfs.json
#%{lib_hadoop}/libexec/init-hcfs.groovy
%exclude %{component_install_dir}/%{component_name}-hdfs/%{initd_dir}/%{component_name}-hdfs-*

%files mapreduce
%defattr(-,root,root)
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-site.xml
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-env.sh
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-queues.xml.template
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-site.xml
%config(noreplace) %{etc_hadoop}/conf.empty/user_ec_policies.xml.template
%config(noreplace) %{component_install_dir}/etc/security/limits.d/mapreduce.conf
%{lib_mapreduce}
%{lib_mapreduce}/lib
%{lib_hadoop}/libexec/mapred-config.sh
%{bin_hadoop}/mapred
# Shouldn't the following be moved to hadoop-mapreduce-historyserver?
%exclude %{component_install_dir}/%{component_name}-mapreduce/%{initd_dir}/%{component_name}-mapreduce-historyserver

#%attr(0775,mapred,hadoop) %{run_mapreduce}
#%attr(0775,mapred,hadoop) %{log_mapreduce}
#%attr(0775,mapred,hadoop) %{state_mapreduce}
#%attr(1777,mapred,hadoop) %{state_mapreduce}/cache

%files
%defattr(-,root,root)
%config(noreplace) %{etc_hadoop}/conf.empty/capacity-scheduler.xml
%config(noreplace) %{etc_hadoop}/conf.empty/configuration.xsl
%config(noreplace) %{etc_hadoop}/conf.empty/container-executor.cfg
%config(noreplace) %{etc_hadoop}/conf.empty/core-site.xml
%config(noreplace) %{etc_hadoop}/conf.empty/hadoop-env.cmd
%config(noreplace) %{etc_hadoop}/conf.empty/hadoop-env.sh
%config(noreplace) %{etc_hadoop}/conf.empty/hadoop-metrics2.properties
%config(noreplace) %{etc_hadoop}/conf.empty/hadoop-policy.xml
%config(noreplace) %{etc_hadoop}/conf.empty/kms-acls.xml
%config(noreplace) %{etc_hadoop}/conf.empty/kms-env.sh
%config(noreplace) %{etc_hadoop}/conf.empty/kms-log4j.properties
%config(noreplace) %{etc_hadoop}/conf.empty/kms-site.xml
%config(noreplace) %{etc_hadoop}/conf.empty/log4j.properties
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-env.cmd
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-env.sh
%config(noreplace) %{etc_hadoop}/conf.empty/mapred-queues.xml.template
%config(noreplace) %{etc_hadoop}/conf.empty/ssl-client.xml.example
%config(noreplace) %{etc_hadoop}/conf.empty/ssl-server.xml.example
%config(noreplace) %{etc_hadoop}/conf.empty/user_ec_policies.xml.template
%config(noreplace) %{etc_hadoop}/conf.empty/workers
%config(noreplace) %{etc_hadoop}/conf.empty/yarn-env.cmd
%config(noreplace) %{etc_hadoop}/conf.empty/yarnservice-log4j.properties
%config(noreplace) %{component_install_dir}/etc/default/hadoop
%{component_install_dir}/etc/bash_completion.d/hadoop
%{lib_hadoop}/*.jar
%{lib_hadoop}/lib
%{lib_hadoop}/sbin
%{lib_hadoop}/bin
%{lib_hadoop}/etc
%{lib_hadoop}/libexec/yarn-config.cmd
%{lib_hadoop}/libexec/mapred-config.cmd
%{lib_hadoop}/libexec/hdfs-config.cmd
%{lib_hadoop}/libexec/hadoop-config.cmd
%{lib_hadoop}/libexec/hadoop-config.sh
%{lib_hadoop}/libexec/hadoop-functions.sh
%{lib_hadoop}/libexec/hadoop-layout.sh
%{lib_hadoop}/libexec/shellprofile.d
%{lib_hadoop}/mapreduce.tar.gz
%{bin_hadoop}/hadoop
%{component_install_dir}/%{component_name}/conf
%{man_hadoop}/man1/hadoop.1.*
#%{man_hadoop}/man1/yarn.1.*
#%{man_hadoop}/man1/hdfs.1.*
#%{man_hadoop}/man1/mapred.1.*

# Shouldn't the following be moved to hadoop-hdfs?
%exclude %{lib_hadoop}/bin/fuse_dfs

%files doc
%defattr(-,root,root)
%doc %{doc_hadoop}

%files httpfs
%defattr(-,root,root)
%config(noreplace) %{etc_httpfs}/conf.empty
%config(noreplace) %{component_install_dir}/etc/%{component_name}-httpfs/tomcat-deployment.dist
%config(noreplace) %{component_install_dir}/etc/default/%{component_name}-httpfs
#%{lib_hadoop}/libexec/httpfs-config.sh
%{lib_httpfs}
#%attr(0775,httpfs,httpfs) %{run_httpfs}
#%attr(0775,httpfs,httpfs) %{log_httpfs}
%attr(0775,httpfs,httpfs) %{state_httpfs}
%exclude %{lib_httpfs}/%{initd_dir}/%{component_name}-httpfs

%files httpfs-server
%defattr(-,root,root)
%{component_install_dir}/%{component_name}-httpfs/%{initd_dir}/%{component_name}-httpfs

# Service file management RPMs
%define service_hdfs() \
%files %1 \
%defattr(-,root,root) \
%{component_install_dir}/%{component_name}-hdfs/%{initd_dir}/%{component_name}-%1 \
%config(noreplace) %{component_install_dir}/etc/default/%{component_name}-%1 \
%post %1 \
chkconfig --add %{component_name}-%1 \
\
%preun %1 \
if [ $1 = 0 ]; then \
  service %{component_name}-%1 stop > /dev/null 2>&1 \
  chkconfig --del %{component_name}-%1 \
fi \
%postun %1 \
if [ $1 -ge 1 ]; then \
  service %{component_name}-%1 condrestart >/dev/null 2>&1 \
fi

# Service file management RPMs
%define service_yarn() \
%files %1 \
%defattr(-,root,root) \
%{component_install_dir}/%{component_name}-yarn/%{initd_dir}/%{component_name}-%1 \
%config(noreplace) %{component_install_dir}/etc/default/%{component_name}-%1 \
%post %1 \
chkconfig --add %{component_name}-%1 \
\
%preun %1 \
if [ $1 = 0 ]; then \
  service %{component_name}-%1 stop > /dev/null 2>&1 \
  chkconfig --del %{component_name}-%1 \
fi \
%postun %1 \
if [ $1 -ge 1 ]; then \
  service %{component_name}-%1 condrestart >/dev/null 2>&1 \
fi

# Service file management RPMs
%define service_mapreduce() \
%files %1 \
%defattr(-,root,root) \
%{component_install_dir}/%{component_name}-mapreduce/%{initd_dir}/%{component_name}-%1 \
%config(noreplace) %{component_install_dir}/etc/default/%{component_name}-%1 \
%post %1 \
chkconfig --add %{component_name}-%1 \
\
%preun %1 \
if [ $1 = 0 ]; then \
  service %{component_name}-%1 stop > /dev/null 2>&1 \
  chkconfig --del %{component_name}-%1 \
fi \
%postun %1 \
if [ $1 -ge 1 ]; then \
  service %{component_name}-%1 condrestart >/dev/null 2>&1 \
fi

%service_hdfs hdfs-namenode
%service_hdfs hdfs-secondarynamenode
%service_hdfs hdfs-zkfc
%service_hdfs hdfs-journalnode
%service_hdfs hdfs-datanode
%service_yarn yarn-resourcemanager
%service_yarn yarn-nodemanager
%service_yarn yarn-proxyserver
%service_yarn yarn-timelineserver
%service_yarn yarn-timelinereader
%service_yarn yarn-registrydns
%service_mapreduce mapreduce-historyserver

# Pseudo-distributed Hadoop installation
%post conf-pseudo
%{alternatives_cmd} --install %{config_hadoop} %{component_name}-conf %{etc_hadoop}/conf.pseudo 30

%preun conf-pseudo
if [ "$1" = 0 ]; then
        %{alternatives_cmd} --remove %{component_name}-conf %{etc_hadoop}/conf.pseudo
fi

%files conf-pseudo
%defattr(-,root,root)
%config(noreplace) %attr(755,root,root) %{etc_hadoop}/conf.pseudo

%files client
%defattr(-,root,root)
%{lib_hadoop}/client

%files libhdfs
%defattr(-,root,root)
%{component_install_dir}/%{_libdir}/libhdfs*
%{component_install_dir}/%{_includedir}/hdfs.h
%{component_install_dir}/%{_includedir}/*.hh

%files hdfs-fuse
%defattr(-,root,root)
%attr(0644,root,root) %config(noreplace) %{component_install_dir}/etc/default/hadoop-fuse
%attr(0755,root,root) %{lib_hadoop}/bin/fuse_dfs
%attr(0755,root,root) %{bin_hadoop}/hadoop-fuse-dfs


