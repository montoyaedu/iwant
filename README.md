# iwant
How to build a Continuous Integration Network for c# and java.

Quick Start.
============

1. Download and install vagrant for your operating system.

    https://www.vagrantup.com/downloads.html

1. Download and install virtualbox for your operating system.

    https://www.virtualbox.org/

1. Download and install a windows box.

    for instace:

    https://vagrantcloud.com/opentable/boxes/win-2012r2-standard-amd64-nocm

    `````bash
        vagrant init opentable/win-2012r2-standard-amd64-nocm
        vagrant up --provider virtualbox
        vagrant halt
    `````

    configure your Vagrantfile accordingly. For instance:

    `````ruby
        Vagrant.configure(2) do |config|
            #...
            config.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
            config.vm.box_check_update = false
            config.vm.network "public_network"

            #...
            config.vm.provider "virtualbox" do |vb|
                vb.gui = true
                vb.memory = "8192"
                vb.customize ["modifyvm", :id, "--vram", "256"]
            end
            #...
        end
    `````

    `````bash
        vagrant up --provider virtualbox
    `````

    Install the latest virtual guest additions.

Requirements.
=============

Requirements are for now a description of our development environments. Contributions are welcome.

Servers.
========

1. Ubuntu Box - ${WEBSERVER}

    * apache2
    * nexus
    * sonar
    * postgresql

1. Windows Box - ${JENKINS_URL}

    * jenkins. (nuget pack works only on windows)
    * .NET Framework 4.0
    * .NET Framework 4.5.2+
    * InnoSetup 5.5+
    * Putty
    * java 1.7+
    * maven 3.3+
    * git 
    * nunit 2.6.4+
    * windows sdk 7.1+
    * OpenCover
    * PATH
        `````
            C:\Windows\Microsoft.NET\Framework\v4.0.30319
            E:\apache-maven-3.3.3\bin
            E:\iwant-app\bin
            E:\FxCop
            E:\NUnit2\bin
            E:\innosetup5
            E:\AppStack\Nuget
            E:\AppStack\SonarQube\bin
            E:\AppStack\OpenCover
            E:\AppStack\PuTTY
        `````
    * NUNIT_HOME
        `````
            E:\NUnit2
        `````

1. Developer Box (Mac OS X Yosemite)

    * homebrew
        * mono
        * maven 3.3+
        * wine 1.7+

    * java 1.7+

1. Developer Box (Ubuntu)

    * mono
    * java 1.7+
    * maven 3.3+
    * wine 1.7+
    * innosetup 5.5+ (installed and launched by wine)

1. Developer Box (Windows)

    * .NET Framework 4.0
    * .NET Framework 4.5.2+
    * InnoSetup 5.5+
    * Putty
    * java 1.7+
    * maven 3.3+
    * git 
    * nunit 2.6.4+
    * windows sdk 7.1+
    * visual studio 2010+

1. bitbucket.org (should work with any SCM but now we are using and supporting only bitbucket)

Install.
========

    1. clone this project

    `````
        git clone https://github.com/montoyaedu/iwant iwant-app
    `````

    1. Add iwant-app/bin to your PATH environment variable.

    1. Set your IWANT_HOME environment variable to the iwant-app folder.

Configure environment (unix/linux/Mac OS X).
============================================

Assuming that iwant-app package has been unzipped in /opt folder:

`````
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

WARNING: This command has been tested on a Mac OS X box only. The command iwant.bat for windows command prompt does not work anymore and needs to be updated. (Sorry fot that)

We have started a simple port of the dialog utility for windows. Please see it at https://github.com/montoyaedu/Dialog.DialogNET.

`````
    iwant
`````

The follow the instructions on the screen. For instance, if you decided to create a c# project you will have something like this:

`````
Edu.CSharpLibrary
├── CSharpLibrary.cs
├── CSharpLibraryTests.cs
├── Edu.CSharpLibrary.csproj
├── Edu.CSharpLibrary.nuspec
├── Edu.CSharpLibrary_vs2010.sln
├── Properties
│   └── AssemblyInfo.cs
├── app.config
├── buildandpublish.bat
├── buildonly
├── buildonly.bat
├── buildsetup.iss
├── config.xml
├── cover.bat
├── detail.xml
├── packages.config
├── pom.xml
├── prepare
├── prepare.bat
├── prepare.xml
├── release
├── release.bat
├── release.xml
├── setup.ico
└── version.txt
`````

Building from command-line.
===========================

You can open the solution file with visual studio or compile from the command-line:

`````
    cd MyPackage.MyApp
    msbuild /t:Rebuild /p:Configuration=Debug MyPackage.MyApp_vs2010.sln
`````

On unix systems Xamarin can be used. Just replace msbuild with xbuild.

Git.
====

iwant initializes an empty git repository and adds all files. If something goes wrong you can make it yourself.

`````
    cd MyPackage.MyApp
    git init
    git add '*'
    git commit -m "Initial commit"
`````

Maven.
======

Optionally, you can use maven to manage your release and development versions. First install this maven plugin on your local maven repository.

Download and install maven from:

https://maven.apache.org/download.cgi

And then follow installation instructions from:

https://maven.apache.org/install.html

Going Beyond IWant.
===================

Apache.
=======

modify /etc/apache2/sites-enabled/yoursite.conf

`````
    ProxyPreserveHost On
    ProxyRequests Off
    ProxyPass /nexus http://localhost:10035/nexus
    ProxyPassReverse /nexus http://localhost:10035/nexus
    ProxyPass /sonar http://localhost:9000/sonar
    ProxyPassReverse /sonar http://localhost:9000/sonar
`````

Postgresql.
===========

`````bash
    sudo apt-get install postgresql postgresql-contrib
`````

Sonar.
======

`````bash
    sudo apt-get install sonar
    sudo service sonar stop
`````

modify /opt/sonar/conf/sonar.properties

`````
    sonar.jdbc.username=sonar
    sonar.jdbc.password=sonar
    sonar.jdbc.url=jdbc:postgresql://localhost/sonar
    sonar.web.context=/sonar
    sonar.updatecenter.activate=true
`````

restart sonar.

`````
    sudo service sonar start
`````

`````
    sudo su - postgres
    psql
`````

`````psql
    DROP DATABASE sonar;
    CREATE USER sonar WITH PASSWORD 'sonar';
    CREATE DATABASE sonar WITH OWNER sonar ENCODING 'UTF8';
`````

Sonar for MSBuild.
==================

http://docs.sonarqube.org/display/PLUG/C%23+Plugin

Configure Jenkins In A Windows Box.
===================================

There is no a single way to configure a Windows Box in order to use it as a server for continuous integration. Here we explain our setup. Comments are welcome.

You will need administrative rights in order to configure properly you Windows Server.

1. The Server.

    * Operating System.

    `````
        Windows 7 Professional Service Pack 1
    `````

    * Configure a CI user. For instance:

    `````
        net user /add jenkins *
    `````

    * User %HOMEPATH%

    `````
        C:\Users\jenkins
    `````

    * Create C:\AppStack folder

    `````
        MD D:\AppStack
    `````

1. Jenkins.

    * Installation Path.

    `````
        E:\AppStack\Jenkins
    `````

    * Version.

    `````
        1.631
    `````

    * Configure Service to be executed by the jenkins user.

1. Install Git.

    * Download (https://github.com/git-for-windows/git/releases/download/v2.5.3.windows.1/Git-2.5.3-64-bit.exe)

1. Install and configure nexus.

1. Configure NuGet.

    * Set credentials and remembering ApiKey

    `````
        nuget sources
        Registered Sources:
            1.  nuget.org [Enabled]
                https://www.nuget.org/api/v2/
            2.  mynexusserver [Enabled]
                http://address:port/nexus/service/local/nuget/MyNuGetRepo/
        nuget sources update -name mynexusserver -source http://address:port/nexus/service/local/nuget/MyNuGetRepo/ -username user -password pass
        nuget setapikey your-api-key -source http://address:port/nexus/service/local/nuget/MyNuGetRepo/
    `````

Acknowledgements.
=================

Thanks to (but not limited to) all developers involved in:

1. http://gnuwin32.sourceforge.net/packages/sed.htm
1. https://gist.github.com/derekstavis/8288379
1. https://github.com/ethiclab/dotnet-maven-plugin
1. http://www.mojohaus.org/versions-maven-plugin/
1. http://www.jrsoftware.org/files/is/license.txt
1. https://maven.apache.org/
1. https://github.com/
1. https://bitbucket.org/
1. https://git-scm.com/
1. https://www.visualstudio.com/
1. https://github.com/montoyaedu/Uuidgen.NET
1. https://www.nuget.org/
1. http://www.mono-project.com/
1. https://www.java.com/en/
1. http://www.sonatype.org/nexus/go/
1. http://jenkins-ci.org/
1. http://www.sonarqube.org/
1. http://www.postgresql.org/
1. https://github.com/OpenCover/opencover
1. http://httpd.apache.org/
1. http://www.ubuntu.com/
1. https://www.kernel.org/
1. http://www.apple.com/osx/
1. http://brew.sh/
1. http://www.gnu.org/
