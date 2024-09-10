# Digital Ocean Database Deployment


## Oracle
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/oracle-setup-do.sh | bash



## DB2
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/db2-setup-do.sh | bash

## Tomcat server (Java 14)
### change "username" with tomcat login user, "password" with password, 16G is 16 GB swap file 
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/tomcat-server-do.sh | bash -s "username" "password" "16G"

## Spring Boot using pm2 as a service with java 21
### change "repo" with git repo of spring boot project, gradlew must be present in root "token" with github token and port with port of app
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/spring-boot-21.sh | bash -s "repo" "token" "port"


### sources:
https://github.com/MaksymBilenko/docker-oracle-12c
https://ajstorm.medium.com/installing-db2-on-your-coffee-break-5be1d811b052
