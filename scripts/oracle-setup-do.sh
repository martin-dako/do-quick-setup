#!/bin/bash
#Auto install and run Oracle database
#source: https://github.com/MaksymBilenko/docker-oracle-12c

#JDBC instructions
#jdbc:oracle:thin:@<ip>:1521:xe
#user: system
#pass: oracle

apt update
apt install -y docker.io
docker pull quay.io/maksymbilenko/oracle-12c
docker run -d -p 8080:8080 -p 1521:1521 quay.io/maksymbilenko/oracle-12c

#wait... it will take some time...