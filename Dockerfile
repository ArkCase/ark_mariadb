# Note: ubi8/s2i-core is equivelent RHEL 8 Official Base Image
# Note: rhel8/mariadb-105 is equivelent RHEL 8 Offical MariaDB Official image 

###########################################################################################################
# How to build:
# docker build -t ark_mariadb:latest .
# 
# How to run:
# docker run --name ark_mariadb -d  -e MYSQL_ROOT_PASSWORD=mypass -p 3306:3306 ark_mariadb:latest
# docker exec -it ark_mariadb /bin/bash
# docker stop ark_mariadb
# docker rm ark_mariadb
###########################################################################################################

###########################################################################################################
# Paramaters & Documentation:
# https://hub.docker.com/r/centos/mariadb-103-centos7
#
#
#Environment variables and volumes
#The image recognizes the following environment variables that you can set during initialization by passing -e VAR=VALUE to the Docker run command.
#
#MYSQL_USER
#User name for MySQL account to be created
#
#MYSQL_PASSWORD
#Password for the user account
#
#MYSQL_DATABASE
#Database name
#
#MYSQL_ROOT_PASSWORD
#Password for the root user (optional)
#
#MYSQL_CHARSET
#Default character set (optional)
#
#MYSQL_COLLATION
#Default collation (optional)
#
#The following environment variables influence the MySQL configuration file. They are all optional.
#
#MYSQL_LOWER_CASE_TABLE_NAMES (default: 0)
#Sets how the table names are stored and compared
#
#MYSQL_MAX_CONNECTIONS (default: 151)
#The maximum permitted number of simultaneous client connections
#
#MYSQL_MAX_ALLOWED_PACKET (default: 200M)
#The maximum size of one packet or any generated/intermediate string
#
#MYSQL_FT_MIN_WORD_LEN (default: 4)
#The minimum length of the word to be included in a FULLTEXT index
#
#MYSQL_FT_MAX_WORD_LEN (default: 20)
#The maximum length of the word to be included in a FULLTEXT index
#
#MYSQL_AIO (default: 1)
#Controls the innodb_use_native_aio setting value in case the native AIO is broken. See http://help.directadmin.com/item.php?id=529
#
#MYSQL_TABLE_OPEN_CACHE (default: 400)
#The number of open tables for all threads
#
#MYSQL_KEY_BUFFER_SIZE (default: 32M or 10% of available memory)
#The size of the buffer used for index blocks
#
#MYSQL_SORT_BUFFER_SIZE (default: 256K)
#The size of the buffer used for sorting
#
#MYSQL_READ_BUFFER_SIZE (default: 8M or 5% of available memory)
#The size of the buffer used for a sequential scan
#
#MYSQL_INNODB_BUFFER_POOL_SIZE (default: 32M or 50% of available memory)
#The size of the buffer pool where InnoDB caches table and index data
#
#MYSQL_INNODB_LOG_FILE_SIZE (default: 8M or 15% of available memory)
#The size of each log file in a log group
#
#MYSQL_INNODB_LOG_BUFFER_SIZE (default: 8M or 15% of available memory)
#The size of the buffer that InnoDB uses to write to the log files on disk
#
#MYSQL_DEFAULTS_FILE (default: /etc/my.cnf)
#Point to an alternative configuration file
#
#MYSQL_BINLOG_FORMAT (default: statement)
#Set sets the binlog format, supported values are row and statement
#
#MYSQL_LOG_QUERIES_ENABLED (default: 0)
#To enable query logging set this to 1
#
#You can also set the following mount points by passing the -v /host:/container flag to Docker.
#
#/var/lib/mysql/data
#MySQL data directory
#
#Notice: When mouting a directory from the host into the container, ensure that the mounted directory has the appropriate permissions and that the owner and group of the directory matches the user UID or name which is running inside the container.
###########################################################################################################


###########################################################################################################
# START: Base Image simliar to registry.stage.redhat.io/ubi8/ubi:8.7    ###################################
###########################################################################################################

#FROM registry.stage.redhat.io/ubi8/ubi:8.7
FROM docker.io/rockylinux:8.7

#
# Base on https://catalog.redhat.com/software/containers/ubi8/s2i-core/5c83967add19c77a15918c27?container-tabs=dockerfile
# ( Click Cancel whe it prompts you to login )

ENV SUMMARY="Base image which allows using of source-to-image."	\
    DESCRIPTION="The s2i-core image provides any images layered on top of it \
with all the tools needed to use source-to-image functionality while keeping \
the image size as small as possible."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="s2i core" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      com.redhat.component="s2i-core-container" \
      name="ubi8/s2i-core" \
      version="1" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

ENV \
    # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    APP_ROOT=/opt/app-root \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PLATFORM="el8"

# This is the list of basic dependencies that all language container image can
# consume.
# Also setup the 'openshift' user that is used for the build execution and for the
# application runtime execution.
# TODO: Use better UID and GID values

RUN INSTALL_PKGS="bsdtar \
  findutils \
  groff-base \
  glibc-locale-source \
  glibc-langpack-en \
  gettext \
  rsync \
  scl-utils \
  tar \
  unzip \
  xz \
  yum" && \
  mkdir -p ${HOME}/.pki/nssdb && \
  chown -R 1001:0 ${HOME}/.pki && \
  yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
  rpm -V $INSTALL_PKGS && \
  yum -y clean all --enablerepo='*'

# Copy extra files to the image.
COPY ./core/root/ /

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path.
WORKDIR ${HOME}

ENTRYPOINT ["container-entrypoint"]
CMD ["base-usage"]

# Reset permissions of modified directories and add default user
RUN rpm-file-permissions && \
  useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
  chown -R 1001:0 ${APP_ROOT}

###########################################################################################################
#   END: Base Image simliar to registry.stage.redhat.io/ubi8/ubi:8.7    ###################################
###########################################################################################################


###########################################################################################################
# START: MariaDb Image ####################################################################################
###########################################################################################################

#   Based on: https://hub.docker.com/r/centos/mariadb-103-centos7
#   Source Code:  https://github.com/sclorg/mariadb-container/

# FROM ubi8/s2i-core
#
# Note: ubi8/s2i-core is equivelent to above with RHEL 8 Official
# Note: rhel8/mariadb-105 is equivelent to above and below with RHEL 8 Offical
#
ENV MYSQL_VERSION=10.5 \
    APP_DATA=/opt/app-root/src \
    HOME=/var/lib/mysql \
    SUMMARY="MariaDB 10.5 SQL database server" \
    DESCRIPTION="MariaDB is a multi-user, multi-threaded SQL database server. The container \
image provides a containerized packaging of the MariaDB mysqld daemon and client application. \
The mysqld server daemon accepts connections from clients and provides access to content from \
MariaDB databases on behalf of the clients."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="MariaDB 10.5" \
      io.openshift.expose-services="3306:mysql" \
      io.openshift.tags="database,mysql,mariadb,mariadb105,mariadb-105" \
      com.redhat.component="mariadb-105-container" \
      name="rhel8/mariadb-105" \
      version="1" \
      usage="podman run -d -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -e MYSQL_DATABASE=db -p 3306:3306 rhel8/mariadb-105" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

EXPOSE 3306

# This image must forever use UID 27 for mysql user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN yum -y module enable mariadb:$MYSQL_VERSION && \
    INSTALL_PKGS="policycoreutils rsync tar gettext hostname bind-utils groff-base mariadb-server" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*' && \
    mkdir -p /var/lib/mysql/data && chown -R mysql.0 /var/lib/mysql && \
    test "$(id mysql)" = "uid=27(mysql) gid=27(mysql) groups=27(mysql)"

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/mysql \
    MYSQL_PREFIX=/usr

COPY 10.5/root-common /
COPY 10.5/s2i-common/bin/ $STI_SCRIPTS_PATH
COPY 10.5/root /

# this is needed due to issues with squash
# when this directory gets rm'd by the container-setup
# script.
# Also reset permissions of filesystem to default values
RUN rm -rf /etc/my.cnf.d/* && \
    /usr/libexec/container-setup && \
    rpm-file-permissions

# Not using VOLUME statement since it's not working in OpenShift Online:
# https://github.com/sclorg/httpd-container/issues/30
# VOLUME ["/var/lib/mysql/data"]

USER 27

ENTRYPOINT ["container-entrypoint"]
CMD ["run-mysqld"]

###########################################################################################################
#   END: MariaDb Image ####################################################################################
###########################################################################################################

