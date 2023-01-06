# ark_mariadb

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
