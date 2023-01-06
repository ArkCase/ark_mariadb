# ark_mariadb

This is a port of MariaDB Official image to Rocky 8.7.   It can be replaced with the Official images when replatforming to Centos or RHEL.

## ubi8/s2i-core is equivelent RHEL 8 Official Base Image

https://catalog.redhat.com/software/containers/ubi8/s2i-core/5c83967add19c77a15918c27?container-tabs=overview


## rhel8/mariadb-105 is equivelent RHEL 8 Offical MariaDB Official image

https://catalog.redhat.com/software/containers/rhel8/mariadb-103/5ba0acf2d70cc57b0d1d9e78

## mariadb-103-centos7 is equivelent Open Source Centos7 MariaDB Official image

https://hub.docker.com/r/centos/mariadb-103-centos7


## How to build:

docker build -t ark_mariadb:latest .

## How to run:
docker run --name ark_mariadb -d  -e MYSQL_ROOT_PASSWORD=mypass -p 3306:3306 ark_mariadb:latest

docker exec -it ark_mariadb /bin/bash

docker stop ark_mariadb

docker rm ark_mariadb

## Parameters & Documentation:
https://hub.docker.com/r/centos/mariadb-103-centos7

## Source Code
https://github.com/sclorg/mariadb-container/

https://catalog.redhat.com/software/containers/ubi8/s2i-core/5c83967add19c77a15918c27?container-tabs=dockerfile

