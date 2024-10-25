# Digital Ocean Database Deployment


## Oracle
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/oracle-setup-do.sh | bash



## DB2
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/db2-setup-do.sh | bash

## Setup shell (nnn, zsh...)
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/shell-setup.sh | bash


## Tomcat server (Java 14)
### Change "username" with tomcat login user, "password" with password, 16G is 16 GB swap file 
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/tomcat-server-do.sh | bash -s "username" "password" "16G"

## Spring Boot using pm2 as a service with (Java 21), idempotent, can be used for redeployment easily

### Change "repo" with git repo of spring boot project, gradlew must be present in root folder. Replace "token" with github token and port with wanted port of an app
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/spring-boot-21.sh | bash -s "repo" "token" "port"

#### Deploy ZSH .zshrc snippet
alias deploy='wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/spring-boot-21.sh | bash -s "<SPRINGBOOT_REPO>" "<TOKEN>" "<PORT>"'

### sources:
https://github.com/MaksymBilenko/docker-oracle-12c
https://ajstorm.medium.com/installing-db2-on-your-coffee-break-5be1d811b052
