TOM_USER=$1
TOM_PASS=$2
TOM_SWAP=$3

apt update
apt install -y python
apt install -y openjdk-14-jdk #change version if needed
cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.tar.gz
mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
JAVA_INSTALL_HOME="/usr"$(update-java-alternatives -l | perl -F"/usr/" -wane 'print $F[-1]')

# create service
cat > /etc/systemd/system/tomcat.service << EOL
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=$JAVA_INSTALL_HOME
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx8192M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=root
Group=root
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL

set +H
python -c $"import sys;handle=open('/opt/tomcat/conf/tomcat-users.xml', 'r+');lines=handle.read();print lines.replace('</tomcat-users>','<user username=\"' + str(sys.argv[1]) + '\" password=\"' + str(sys.argv[2]) + '\" roles=\"manager-gui,admin-gui\"/>\n</tomcat-users>',1);handle.truncate(0);handle.close()" "$TOM_USER" "$TOM_PASS" >> /opt/tomcat/conf/tomcat-users.xml
python -c "import sys;handle=open('/opt/tomcat/webapps/manager/META-INF/context.xml', 'r+');lines=handle.read();  print lines.replace('<Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"','<!-- <Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"',1).replace('0:0:0:0:0:0:0:1\" />','0:0:0:0:0:0:0:1\" /> -->',1); handle.truncate(0);handle.close()" >> /opt/tomcat/webapps/manager/META-INF/context.xml
python -c "import sys;handle=open('/opt/tomcat/webapps/host-manager/META-INF/context.xml', 'r+');lines=handle.read();  print lines.replace('<Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"','<!-- <Valve className=\"org.apache.catalina.valves.RemoteAddrValve\"',1).replace('0:0:0:0:0:0:0:1\" />','0:0:0:0:0:0:0:1\" /> -->',1); handle.truncate(0);handle.close()" >> /opt/tomcat/webapps/host-manager/META-INF/context.xml

systemctl daemon-reload
systemctl start tomcat
ufw allow 8080
systemctl enable tomcat
systemctl restart tomcat

# swapfile
fallocate -l $TOM_SWAP /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
