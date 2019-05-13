#!/bin/bash

#
# Setup the base box
#
# Install MySQL
installMySQL () {
  DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server
  mysqladmin -u root password vivo
}

# Install Tomcat 8
installTomcat () {
  groupadd tomcat || true
  useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat || true

  curl -O http://mirrors.sonic.net/apache/tomcat/tomcat-9/v9.0.19/bin/apache-tomcat-9.0.19.tar.gz >/dev/null 2>&1

  mkdir /opt/tomcat || true
  tar -xzvf apache-tomcat-9.0.19.tar.gz -C /opt/tomcat --strip-components=1

  chgrp -R tomcat /opt/tomcat
  
  chown -R tomcat /opt/tomcat
  chmod -R g+r /opt/tomcat/conf
  chmod g+x /opt/tomcat/conf

  cp /home/vagrant/provision/tomcat/tomcat.service /etc/systemd/system/tomcat.service
  cp /home/vagrant/provision/tomcat/server.xml /opt/tomcat/conf/server.xml
  cp /home/vagrant/provision/tomcat/context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
  cp /home/vagrant/provision/tomcat/context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
  cp /home/vagrant/provision/tomcat/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml

  systemctl daemon-reload
  systemctl start tomcat
  systemctl enable tomcat
}

# Setup Ubuntu Firewall
setupFirewall () {
  ufw allow 22
  ufw allow 8080
  ufw allow 8081
  ufw allow 8000
  ufw enable
}

# Exit on first error
set -e

# Print shell commands
set -o verbose

# Update Ubuntu packages. Comment out during development
apt-get upgrade -y

apt-get update -y

# Install Java OpenJDK8 and Maven
apt-get install -y openjdk-8-jdk-headless 
apt-get install -y ca-certificates-java
apt-get install -y maven 
apt-get install -y policykit-1
apt-get install -y tomcat9

# Some utils
apt-get install -y git vim screen wget curl raptor2-utils unzip

# Autoclean
apt-get autoremove -y

# Set time zone
timedatectl set-timezone "Europe/London"

installMySQL

# installTomcat
systemctl daemon-reload

systemctl start tomcat9

systemctl enable tomcat9

setupFirewall

# Make Karma scripts executable
chmod +x /home/vagrant/provision/karma.sh

echo Box boostrapped.

exit