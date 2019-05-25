#!/bin/bash

#
# Set global variables
#

echo "Catalina Base: $CATALINA_BASE"

CATALINA_BASE="/var/lib/tomcat9"
TOMCAT_WEBAPPS="$CATALINA_BASE/webapps"
TOMCAT_CONFIG="/etc/tomcat9"
TOMCAT_INSTANCE="$TOMCAT_CONFIG/Catalina/localhost"
DUMMY_TOMCAT_HOME="/opt/tomcat"
VIVO_HOME="/opt/vivo"
VIVO_REPO_URL="https://github.com/vivo-project"
PROVISION_HOME="/home/vagrant/provision"
SOURCE_HOME="/home/vagrant/src"

#
# Clean ontology data files
#
removeRDFFiles(){
    # In development, you might want to remove these ontology and data files
    # since they slow down Tomcat restarts considerably.
    rm $VIVO_HOME/rdf/tbox/filegraph/geo-political.owl
    rm $VIVO_HOME/rdf/abox/filegraph/continents.n3
    rm $VIVO_HOME/rdf/abox/filegraph/us-states.rdf
    rm $VIVO_HOME/rdf/abox/filegraph/geopolitical.abox.ver1.1-11-18-11.owl
    return $TRUE
}

#
# Set alias for logs
#
setLogAlias() {
    # Alias for viewing VIVO log
    VLOG="alias vlog='less +F /var/log/tomcat9/vivo.all.log'"
    BASHRC=/home/vagrant/.bashrc

    if grep "$VLOG" $BASHRC > /dev/null
    then
       echo "log alias exists"
    else
       (echo;  echo $VLOG)>> $BASHRC
       echo "log alias created"
    fi
}

#
# Configure Tomcat Service with updated configuration files
#
updateTomcatConfiguration() {
  PROVISION_T9_SERVICE="$PROVISION_HOME/tomcat/tomcat.service"
  ORIGIN_T9_SERVICE="/lib/systemd/system/tomcat9.service"
  TARGET_T9_SERVICE="/etc/systemd/system/multi-user.target.wants/tomcat9.service"

  # Stop tomcat
  systemctl stop tomcat9.service

  # add vagrant to tomcat group
  if ! id "vagrant" >/dev/null 2>&1; then
    echo "Creating 'vagrant' user"
    adduser --disabled-password --gecos "" vagrant || true
  fi
  usermod -a -G tomcat vagrant || true

  # Change permissions in vivo folders
  dirs=( $VIVO_HOME $DUMMY_TOMCAT_HOME $TOMCAT_WEBAPPS/vivo $TOMCAT_WEBAPPS/vivosolr )
  for dir in "${dirs[@]}"
  do
    chown -R vagrant:tomcat $dir
    chmod -R g+rws $dir
  done

  # Add redirect to /vivo in tomcat root
  rm -f $TOMCAT_WEBAPPS/ROOT/index.html || true
  cp $PROVISION_HOME/vivo/index.jsp $TOMCAT_WEBAPPS/ROOT/index.jsp

  # Add vivo users to tomcat-users.xml
  rm -f $TOMCAT_CONFIG/tomcat-users.xml || true
  cp $PROVISION_HOME/tomcat/tomcat-users.xml $TOMCAT_CONFIG/tomcat-users.xml

  # Add vivo context to tomcat
  cp $PROVISION_HOME/tomcat/vivo.xml $TOMCAT_INSTANCE/vivo.xml
  cp $PROVISION_HOME/tomcat/vivosolr.xml $TOMCAT_INSTANCE/vivosolr.xml

  # Assign contexts to tomcat group
  chgrp tomcat $TOMCAT_CONFIG/tomcat-users.xml
  chgrp tomcat $TOMCAT_INSTANCE/vivo.xml
  chgrp tomcat $TOMCAT_INSTANCE/vivosolr.xml

  # Update tomcat service configuration 
  rm -r $ORIGIN_T9_SERVICE || true
  rm -r $TARGET_T9_SERVICE || true

  # Update Tomcat service configuration file
  cp $PROVISION_T9_SERVICE $ORIGIN_T9_SERVICE
  ln -sF $ORIGIN_T9_SERVICE $TARGET_T9_SERVICE  

  # Update configuration and start tomcat
  systemctl daemon-reload
  systemctl start tomcat9.service || true
}

#
# Install VIVO Database.
#
setupMySQL() {
  mysql --user=root --password=vivo -e "CREATE DATABASE vivo110dev CHARACTER SET utf8;" || true
  mysql --user=root --password=vivo -e "GRANT ALL ON vivo110dev.* TO 'vivo'@'localhost' IDENTIFIED BY 'vivo';"
}

#
# Install VIVO.
#
installVIVO() {
  # Increase the number of threads for tomcat and apache services.
  echo 'apache           hard    nproc           400' >> /etc/security/limits.conf
  echo 'tomcat           hard    nproc           1500' >> /etc/security/limits.conf

  # Make data directory
  mkdir -p $VIVO_HOME || true

  # Make config directory
  mkdir -p $VIVO_HOME/config || true

  # Make log directory
  mkdir -p $VIVO_HOME/logs || true

  # Make src directory
  mkdir -p $SOURCE_HOME || true

  # Make dummy tomcat folder to comply with build script and link it 
  # to current webapps folder so deployment can happen
  mkdir $DUMMY_TOMCAT_HOME || true
  ln -sF $DUMMY_TOMCAT_HOME/webapps $TOMCAT_WEBAPPS

  # Vivo
  cd $SOURCE_HOME

  # Remove current source code in case they exist
  rm -rf Vitro || true
  rm -rf VIVO || true

  # Download vivo and vitro
  git clone $VIVO_REPO_URL/Vitro.git Vitro -b vitro-1.10.0 || true
  git clone $VIVO_REPO_URL/VIVO.git VIVO -b vivo-1.10.0 || true

  # Build from source code and install vivo
  cd VIVO
  mvn clean install -s $PROVISION_HOME/vivo/settings.xml -Dmaven.test.skip=true -q -U 

  # Copy configuration files
  cp $PROVISION_HOME/vivo/runtime.properties $VIVO_HOME/config/runtime.properties
  cp $PROVISION_HOME/vivo/developer.properties $VIVO_HOME/config/developer.properties
  cp $PROVISION_HOME/vivo/build.properties $VIVO_HOME/config/build.properties
  cp $PROVISION_HOME/vivo/applicationSetup.n3 $VIVO_HOME/config/applicationSetup.n3

  # Update permissions
  chmod -R 775 $DUMMY_TOMCAT_HOME
  chmod -R 775 $VIVO_HOME
}

# Exit on first error
set -e

# Print shell commands
set -o verbose

# create VIVO database
setupMySQL

# install the app
installVIVO

# Adjust tomcat permissions
updateTomcatConfiguration

# Set a log alias
setLogAlias

echo VIVO installed.

exit