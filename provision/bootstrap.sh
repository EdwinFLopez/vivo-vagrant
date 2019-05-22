#!/bin/bash

#
# Setup the base box
#

# Install MySQL
installMySQL () {
    DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server
    mysqladmin -u root password vivo
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

# Set time zone
timedatectl set-timezone "Europe/London"

# Update Ubuntu packages. Comment out during development
apt-get upgrade -y

apt-get update -y

# Install Java OpenJDK8, Maven, Tomcat 9
apt-get install -y openjdk-8-jdk-headless 

apt-get install -y ca-certificates-java

apt-get install -y policykit-1

apt-get install -y maven 

apt-get install -y tomcat9 tomcat9-common tomcat9-admin tomcat9-docs tomcat9-examples tomcat9-user

# Some utils
apt-get install -y git vim screen wget curl raptor2-utils unzip mc

# Autoclean
apt-get autoremove -y

installMySQL

setupFirewall

# Make Karma scripts executable
chmod +x /home/vagrant/provision/karma.sh

echo Box boostrapped.

exit