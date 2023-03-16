# Mariadb for Arkcase

This is a port of MariaDB 1.5 Official image to Rocky 8.7.   It can be replaced with the Official images when replatforming to Centos or RHEL.

## ubi8/s2i-core is equivelent RHEL 8 Official Base Image

https://catalog.redhat.com/software/containers/ubi8/s2i-core/5c83967add19c77a15918c27?container-tabs=overview


## rhel8/mariadb-105 is equivelent RHEL 8 Offical MariaDB Official image

https://catalog.redhat.com/software/containers/rhel8/mariadb-103/5ba0acf2d70cc57b0d1d9e78

## mariadb-103-centos7 is equivelent Open Source Centos7 MariaDB Official image

https://hub.docker.com/r/centos/mariadb-103-centos7


## How to build:

docker build -t ark_mariadb:latest .

docker tag ark_mariadb:latest 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_mariadb:latest

docker push 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_mariadb:latest

## How to run:

### Docker:

docker run --name ark_mariadb -d  -e MYSQL_ROOT_PASSWORD=mypass -p 3306:3306 ark_mariadb:latest

docker exec -it ark_mariadb /bin/bash

docker stop ark_mariadb

docker rm ark_mariadb

### Kubernetes:

kubectl create pod -f pod_ark_mariadb.yaml

## Parameters & Documentation:
https://hub.docker.com/r/centos/mariadb-103-centos7

or (should be identical documentation)

https://catalog.redhat.com/software/containers/rhel8/mariadb-103/5ba0acf2d70cc57b0d1d9e78



## Source Code
Base Image

https://catalog.redhat.com/software/containers/ubi8/s2i-core/5c83967add19c77a15918c27?container-tabs=dockerfile

MariaDB - RHEL

https://catalog.redhat.com/software/containers/rhel8/mariadb-103/5ba0acf2d70cc57b0d1d9e78?container-tabs=dockerfile

MariaDB - Centos (with binaries)

https://github.com/sclorg/mariadb-container/

