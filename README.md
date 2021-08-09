# Digital Ocean Database Deployment


## Oracle
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/oracle-setup-do.sh | bash



## DB2
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/db2-setup-do.sh | bash

## Tomcat server (Java 14)
### change <username> with tomcat login user, <password> password, 16G is 16 GB swap file 
wget -O - https://raw.githubusercontent.com/martin-dako/do-database-quick-setup/master/scripts/tomcat-server-do.sh | bash -s <username> <password> "16G"

### sources:
https://github.com/MaksymBilenko/docker-oracle-12c
https://ajstorm.medium.com/installing-db2-on-your-coffee-break-5be1d811b052
