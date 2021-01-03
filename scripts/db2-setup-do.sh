#!/bin/bash
#Auto install and run DB2 database
#source: https://hub.docker.com/r/ibmcom/db2

#JDBC instructions
#jdbc:db2://<ip>:50000/testdb
#user: db2inst1
#pass: x

apt update
apt install -y docker.io
docker pull ibmcom/db2
docker run -itd --name db2 --restart unless-stopped -e DBNAME=testdb -v ~/:/database -e DB2INST1_PASSWORD=x -e LICENSE=accept -p 50000:50000 --privileged=true ibmcom/db2

#wait... it will take some time...