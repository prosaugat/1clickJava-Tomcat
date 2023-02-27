#!/bin/bash

# Install Java
apt update
apt install -y default-jdk

# Download and extract Apache Tomcat 10.1.6
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.6/bin/apache-tomcat-10.1.6.tar.gz
tar -xzf apache-tomcat-10.1.6.tar.gz
mv apache-tomcat-10.1.6 /opt/tomcat

# Create a tomcat user and group
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Update permissions
cd /opt/tomcat
chgrp -R tomcat /opt/tomcat
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/

# Create a Systemd unit file for Tomcat
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/default-java
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload Systemd and start Tomcat service
systemctl daemon-reload
systemctl start tomcat.service

# Check status of Java and Tomcat
systemctl status tomcat.service
java -version
