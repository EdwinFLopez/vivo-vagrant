# VIVO Vagrant

[Vagrant](http://www.vagrantup.com/) configuration and install scripts for running [VIVO](http://vivoweb.org) on a virtual machine, aka [Vagrant box](http://docs.vagrantup.com/v2/boxes.html), running an Ubuntu 64 Precise image.

The virtual machine will boot and install VIVO 1.8 and its dependencies.  This will take several minutes for the initial install.

If you have questions or encounter problems, please email the VIVO technical list at [vivo-dev-all@lists.sourceforge.net](https://lists.sourceforge.net/lists/listinfo/vivo-dev-all) or open issue here in the Github issue tracker.

## Prerequisites
 * [VirtualBox](https://www.virtualbox.org/) or [VMWare Fusion](http://www.vmware.com/products/fusion).
 * [Vagrant](https://docs.vagrantup.com/v2/installation/index.html).
 * Git - if you are new to git, you might want to use the Github desktop client. [Windows](http://windows.github.com/) and [Mac](http://mac.github.com/) versions are available.

This Vagrant box is intended for development and experimentation only.  Change default user names and passwords.

## Install the VIVO Vagrant box

~~~
$ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
$ cd vivo-vagrant
$ vagrant up
~~~

When the Vagrant provisioning script is complete, the VIVO web application will be available in a browser on the host machine at `http://localhost:8080/vivo`.  You can log into your new VIVO with the default admin user (`vivo_root@school.edu`) and password (`rootPassword`), which are specified in the `/provision/vivo/deploy.properties` source file in this repository.

The source will be installed on the virtual machine at `/usr/local/vivo/`. Mac users can log into your Vagrant box securely using this command from a Terminal session.  Windows users will want to use an SSH utility, e.g. [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html):

~~~
$ vagrant ssh
~~~

Once you are logged in, you can view the default VIVO log output with this command:

~~~
$ vlog
~~~

### Commands / system layout
 * VIVO application: `/usr/local/vivo`.  The source at `/usr/local/vivo` is based off a [3-tier VIVO build template](https://github.com/lawlesst/vivo-project-template) and under git version control.
 * VIVO data directory: `/usr/local/vdata`
 * Tomcat: `/var/lib/tomcat7/`
 * To start/stop Tomcat run `sudo /etc/init.d/tomcat start|stop|restart`.
 * A Vagrant [shared directory](http://docs.vagrantup.com/v2/synced-folders/) is available at `/work` from the box.
 * Use the `vagrant suspend` and `vagrant resume` commands to manage your Vagrant box when not in use or if you plan to restart or shutdown the host system, as opposed to using the VirtualBox or VMWare Fusion admin user interface.

## Upgrading or updating VIVO and Vitro
 * If you have a working vivo-vagrant box and don't want to re-provision your system, you can upgrade to a new release of VIVO by checking out the new release branch and rebuilding the application. 
 * 
  ~~~
 $ sudo /etc/init.d/tomcat7 stop
 $ cd /usr/local/vivo
 $ cd VIVO
 $ git fetch
 $ git checkout v1.x 
 $ cd ../Vitro
 $ git fetch
 $ git checkout v1.x
 $ cd ..
 $ sudo ant all
 $ sudo /etc/init.d/tomcat7 start
 ~~~

 * You might also want to build your VIVO against unreleased code changes.  This can be done by identifying the branch that includes the changes you want to include, `cd` into the VIVO and Vitro updates and use Git to checkout the changes.  For example:

 ~~~
 $ sudo /etc/init.d/tomcat7 stop
 $ cd /usr/local/vivo
 $ cd VIVO
 $ git fetch
 $ git checkout maint-rel-1.8
 $ cd ../Vitro
 $ git fetch
 $ git checkout maint-rel-1.8
 $ cd ..
 $ sudo ant all
 $ sudo /etc/init.d/tomcat7 start
 ~~~
 
## Re-provisioning

You can also, at anytime, re-provision your Vagrant box.  By running the following from your host machine.  This will reinstall all components of the Vagrant box and reinstall VIVO.  This will destroy any changes you've made to your VIVO installation so be sure to backup any data or code changes you have made beforehand.

 ~~~
 $ vagrant up --provision
 ~~~
 
## Reseting the VIVO database
From time to time, you might also want to rollback to a clean VIVO databae. To do this, follow the following steps. Warning - this will delete all the data in the VIVO store so be sure to have a backup or plan for restoring your data.

A script is available at [`/provision/clear_vivo_db.sh`](./provision/clear_vivo_db.sh) to automate stopping the VIVO application, dropping the database, recreating it, and restarting the application.

~~~
 $ cd ~/provision/
 $ ./reset_vivo_db.sh
~~~

 
##Running previous releases of VIVO and Vitro
If you are interested in running VIVO 1.5, 1.6, or 1.7 there are separate branches for each of those released version.
 ~~~
 $ git clone https://github.com/lawlesst/vivo-vagrant.git vivo-vagrant
 $ cd vivo-vagrant
 $ git checkout v1.x
 $ vagrant up
 ~~~

## Triplestores

VIVO supports alternate triplestores via SPARQL 1.1.  The vivo-vagrant repository contains installation and configuration scripts for two other triple stores in separate branches.  

 * [Stardog](http://stardog.com) - see the [`stardog`](https://github.com/lawlesst/vivo-vagrant/tree/stardog) branch and README to get started.  
 * [AllegroGraph](http://franz.com/agraph/allegrograph/): see the [`allegrograph`](https://github.com/lawlesst/vivo-vagrant/tree/allegrograph) branch and README to get started.  


## Karma
[Karma](http://www.isi.edu/integration/karma/) is a tool for mapping raw data in various formats (CSV, XML, etc) to RDF.  To assist with using Karma to model data for VIVO, a script is included to install Karma and its dependencies.  

To install Karma: run `sudo /home/vagrant/provision/karma.sh install`.  The initial install will take about 10 minutes.  Once it's installed Karma can be started with `/home/vagrant/provision/karma.sh start`.  Karma runs in a web browser and will be available on your machine at `http://localhost:8000/`.

[Violeta Ilik](https://twitter.com/violetailik) has [presented](https://www.youtube.com/watch?v=aBLHGzui0_s) (starting at about 12:30) on how to model data for VIVO with Karma.  More information about Karma can be found in this [tutorial](https://github.com/InformationIntegrationGroup/karma-step-by-step) and on the project's [wiki](https://github.com/InformationIntegrationGroup/Web-Karma/wiki).  
