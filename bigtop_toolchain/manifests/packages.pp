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

class bigtop_toolchain::packages {
  case $operatingsystem{
    /(?i:(centos|fedora))/: {
      # Fedora 20 and CentOS 7 or above are using mariadb, while CentOS 6 is still mysql
      if ($operatingsystem == "CentOS") and ($operatingsystemmajrelease <=6) {
        $mysql_devel="mysql-devel"
      } else {
        $mysql_devel="mariadb-devel"
      }
      $pkgs = [
        "epel-release",
        "centos-release-scl",
        "unzip",
        "curl",
        "wget",
        "git",
        "make",
        "cmake",
        "autoconf",
        "automake",
        "libtool",
        "gcc",
        "gcc-c++",
        "fuse",
        "createrepo",
        "lzo-devel",
        "fuse-devel",
        "cppunit-devel",
        "openssl-devel",
        "python-devel",
        "python-setuptools",
        "libxml2-devel",
        "libxslt-devel",
        "cyrus-sasl-devel",
        "sqlite-devel",
        "openldap-devel",
        $mysql_devel,
        "rpm-build",
        "redhat-rpm-config",
        "fuse-libs",
        "asciidoc",
        "xmlto",
        "libyaml-devel",
        "gmp-devel",
        "snappy-devel",
        "boost-devel",
        "xfsprogs-devel",
        "libuuid-devel",
        "bzip2-devel",
        "readline-devel",
        "ncurses-devel",
        "libidn-devel",
        "libcurl-devel",
        "libevent-devel",
        "apr-devel",
        "bison",
        "perl-Env",
        "libffi-devel",
        "R",
        "zip",
        "sed",
        "cmake3",
        "ninja-build",
        "devtoolset-9",
        "libicu-devel",
        "libtool-ltdl-devel",
        "unixODBC-devel"
      ]
    }
    /(?i:(SLES|opensuse))/: { $pkgs = [
        "unzip",
        "curl",
        "wget",
        "git",
        "make",
        "cmake",
        "autoconf",
        "automake",
        "libtool",
        "gcc",
        "gcc-c++",
        "fuse",
        "createrepo",
        "lzo-devel",
        "fuse-devel",
        "cppunit-devel",
        "rpm-devel",
        "rpm-build",
        "pkg-config",
        "gmp-devel",
        "python-devel",
        "python-setuptools",
        "libxml2-devel",
        "libxslt-devel",
        "cyrus-sasl-devel",
        "sqlite3-devel",
        "openldap2-devel",
        "libyaml-devel",
        "krb5-devel",
        "asciidoc",
        "xmlto",
        "libmysqlclient-devel",
        "snappy-devel",
        "boost-devel",
        "xfsprogs-devel",
        "libuuid-devel",
        "libbz2-devel",
        "libcurl-devel",
        "libevent-devel",
        "bison",
        "flex",
        "libffi48-devel",
        "libapr1-devel"
      ]
      # fix package dependencies: BIGTOP-2120 and BIGTOP-2152 and BIGTOP-2471
      exec { '/usr/bin/zypper -n install libopenssl-devel':
      } -> Package <| |>
    }
    /Amazon/: { $pkgs = [
      "unzip",
      "curl",
      "wget",
      "git",
      "make",
      "cmake",
      "autoconf",
      "automake",
      "libtool",
      "gcc",
      "gcc-c++",
      "fuse",
      "createrepo",
      "lzo-devel",
      "fuse-devel",
      "openssl-devel",
      "rpm-build",
      "system-rpm-config",
      "fuse-libs",
      "gmp-devel",
      "snappy-devel",
      "bzip2-devel",
      "libffi-devel"
    ] }
    /(Ubuntu|Debian)/: {
      # Debian-9 is using mariadb instead of mysql
      if ($operatingsystem == "Debian") and ($operatingsystemmajrelease > "8") {
        $mysql_dev="libmariadb-dev"
      } else {
        $mysql_dev="libmysqlclient-dev"
      }
      $pkgs = [
        "unzip",
        "curl",
        "wget",
        "git-core",
        "make",
        "cmake",
        "autoconf",
        "automake",
        "libtool",
        "gcc",
        "g++",
        "fuse",
        "reprepro",
        "liblzo2-dev",
        "libfuse-dev",
        "libcppunit-dev",
        "libssl-dev",
        "libzip-dev",
        "sharutils",
        "pkg-config",
        "debhelper",
        "devscripts",
        "build-essential",
        "dh-make",
        "libfuse2",
        "libssh-dev",
        "libjansi-java",
        "python2.7-dev",
        "libxml2-dev",
        "libxslt1-dev",
        "zlib1g-dev",
        "libsqlite3-dev",
        "libldap2-dev",
        "libsasl2-dev",
        $mysql_dev,
        "python-setuptools",
        "libkrb5-dev",
        "asciidoc",
        "libyaml-dev",
        "libgmp3-dev",
        "libsnappy-dev",
        "libboost-regex-dev",
        "xfslibs-dev",
        "libbz2-dev",
        "libreadline-dev",
        "zlib1g",
        "libapr1",
        "libapr1-dev",
        "libevent-dev",
        "libcurl4-gnutls-dev",
        "bison",
        "flex",
        "python-dev",
        "libffi-dev"
      ]
      file { '/etc/apt/apt.conf.d/01retries':
        content => 'Aquire::Retries "5";'
      } -> Package <| |>
    }
  }
  package { $pkgs:
    ensure => installed
  }

  # Some bigtop packages use `/usr/lib/rpm/redhat` tools
  # from `redhat-rpm-config` package that doesn't exist on AmazonLinux.
  if $operatingsystem == 'Amazon' {
    file { '/usr/lib/rpm/redhat':
      ensure => 'link',
      target => '/usr/lib/rpm/amazon',
    }
  }
}
