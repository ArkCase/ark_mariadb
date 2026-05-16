# Note: ubi8/s2i-core is equivelent RHEL 8 Official Base Image
# Note: rhel8/mariadb-106 is equivelent RHEL 8 Offical MariaDB Official image 

###########################################################################################################
# How to build: 
#
# docker build -t arkcase/mariadb:latest .
#
# How to run: (Helm)
#
# helm repo add arkcase https://arkcase.github.io/ark_helm_charts/
# helm install ark-activemq arkcase/ark-mariadb
# helm uninstall ark-mariadb
#
# How to run: (Docker)
#
# docker run --name ark_mariadb -d  -e MYSQL_ROOT_PASSWORD=mypass -p 3306:3306 ark_mariadb:latest
# docker exec -it ark_mariadb /bin/bash
# docker stop ark_mariadb
# docker rm ark_mariadb
#
# How to run: (Kubernetes)
#
# kubectl create -f pod_ark_mariadb.yaml
# kubectl exec -it pod/mariadb -- bash
# kubectl delete -f pod_mariadb.yaml
#
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

ARG FIPS=""
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG VER="10.11"

ARG MARIADB_KEYRING_SRC="https://mariadb.org/mariadb_release_signing_key.pgp"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="24.04"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}${FIPS}:${BASE_VER_PFX}${BASE_VER}"

FROM "${BASE_IMG}"

ARG VER
ARG MARIADB_KEYRING_SRC

ENV MYSQL_VERSION="${VER}" \
    HOME="/var/lib/mysql" \
    APP_DATA="${APP_ROOT}/src"

ENV SUMMARY="MariaDB ${VER} SQL database server" \
    DESCRIPTION="MariaDB is a multi-user, multi-threaded SQL database server. The container \
image provides a containerized packaging of the MariaDB mysqld daemon and client application. \
The mysqld server daemon accepts connections from clients and provides access to content from \
MariaDB databases on behalf of the clients."

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="MariaDB ${VER}" \
      version="1"

EXPOSE 3306

ENV APP_USER="mysql"
ENV APP_UID="27"
ENV APP_GROUP="${APP_USER}"
ENV APP_GID="${APP_UID}"

ENV DATA_DIR="${HOME}/data" \
    RUN_DIR="/run/mysqld"

# This image must forever use UID 28 for mysql user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN groupadd --gid "${APP_UID}" --system "${APP_USER}" && \
    useradd --gid "${APP_GROUP}" --home-dir "${HOME}" --create-home --shell /sbin/nologin --uid "${APP_UID}" --system "${APP_USER}"

RUN --mount=type=bind,target=/src \
    mkdir -p /etc/apt/keyrings && \
    export KEYRING="/etc/apt/trusted.gpg.d/mariadb-keyring.gpg" && \
    curl -fsSL  "${MARIADB_KEYRING_SRC}" | gpg --dearmor -o "${KEYRING}" && \
    chmod a=r "${KEYRING}" && \
    SOURCES="/etc/apt/sources.list.d/mariadb.sources" && \
    envsubst < /src/mariadb.sources > "${SOURCES}" && \
    chown root:root "${SOURCES}" && \
    chmod 0440 "${SOURCES}" && \
    apt-get update && \
    apt-get -y install \
        groff-base \
        mariadb-client \
        mariadb-server \
      && \
    dpkg --remove --force-depends rsync && \
    apt-get clean && \
    mkdir -p "${RUN_DIR}" "${DATA_DIR}" && \
    chown -R "${APP_UID}:${APP_GID}" "${RUN_DIR}" && \
    chown -R "${APP_USER}:0" "${HOME}" && \
    cd "${HOME}" && \
    rm -rvf * && \
    test "$(id -u "${APP_USER}"):$(id -g "${APP_GROUP}")" = "${APP_UID}:${APP_GID}"

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH="/usr/share/container-scripts/mysql" \
    MYSQL_PREFIX="/usr"

COPY "scripts/root-common" /
COPY "scripts/s2i-common/bin/" "/usr/local/bin"
COPY "scripts/root" /

# this is needed due to issues with squash
# when this directory gets rm'd by the container-setup
# script.
# Also reset permissions of filesystem to default values
RUN rm -rf /etc/my.cnf.d/* && \
    /usr/libexec/container-setup && \
    /usr/libexec/fix-permissions "${HOME}" && \
    usermod -a -G "${ACM_GROUP}" "${APP_USER}" && \
    secure-permissions

# Not using VOLUME statement since it's not working in OpenShift Online:
# https://github.com/sclorg/httpd-container/issues/30
# VOLUME ["/var/lib/mysql/data"]

USER "${APP_USER}"

ENTRYPOINT ["/entrypoint"]
CMD ["run-mysqld"]

###########################################################################################################
#   END: MariaDb Image ####################################################################################
###########################################################################################################
