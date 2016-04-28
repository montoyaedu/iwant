# iwant

Install.
========

    1. clone this project

        git clone https://github.com/montoyaedu/iwant iwant-app

    1. Add iwant-app/bin to your PATH environment variable.

    1. Set your IWANT_HOME environment variable to the iwant-app folder.

Configure environment (unix/linux/Mac OS X).
============================================

Assuming that iwant-app package has been unzipped in /opt folder:

`````bash
export PATH=$PATH:/opt/iwant-app/bin
export IWANT_HOME=/opt/iwant-app
`````

Configure $HOME/.iwantprofile.
==============================

`````bash
#your default package prefix
export PACKAGE=Edu
#your default username at bitbucket
export USERNAME=montoyaedu
#your default owner at bitbucket
export OWNER=montoyaedu
#your nexus proxy web server
export WEBSERVER=192.168.1.20
#your jenkins url
export JENKINS_URL=http://192.168.1.171:8080
`````

Create a new project.
=====================

WARNING: This command has been tested on a Mac OS X box only. The command iwant.bat for windows command prompt does not work anymore and needs to be updated. (Sorry for that)

We have started a simple port of the dialog utility for windows. Please see it at https://github.com/montoyaedu/Dialog.DialogNET.

`````
    iwant
`````

The follow the instructions on the screen.

Git.
====

iwant initializes an empty git repository and adds all files. If something goes wrong you can make it yourself.

`````
    cd MyPackage.MyApp
    git init
    git add '*'
    git commit -m "Initial commit"
`````
