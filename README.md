# iwant
How to build a Continuous Integration Network for c# and java.

Requirements.
=============

Requirements are for now a description of our development environments. Contributions are welcome.

Servers.
========

1. Ubuntu Box - ${WEBSERVER}

    1. apache2
    1. nexus
    1. sonar
    1. postgresql

1. Windows Box - ${JENKINS_URL}

    1. jenkins. (nuget pack works only on windows)
    1. .NET Framework 4.0
    1. .NET Framework 4.5.2+
    1. InnoSetup 5.5+
    1. Putty
    1. java 1.7+
    1. maven 3.3+
    1. git 
    1. nunit 2.6.4+
    1. windows sdk 7.1+

1. Developer Box (Mac OS X Yosemite)

    1. homebrew
        1. mono
        1. maven 3.3+
        1. wine 1.7+

    1. java 1.7+

1. Developer Box (Ubuntu)

    1. mono
    1. java 1.7+
    1. maven 3.3+
    1. wine 1.7+
    1. innosetup 5.5+ (installed and launched by wine)

1. Developer Box (Windows)

    1. .NET Framework 4.0
    1. .NET Framework 4.5.2+
    1. InnoSetup 5.5+
    1. Putty
    1. java 1.7+
    1. maven 3.3+
    1. git 
    1. nunit 2.6.4+
    1. windows sdk 7.1+
    1. visual studio 2010+

1. bitbucket.org (should work with any SCM but now we are using and supporting only bitbucket)

Install.
========

    1. WARNING: SKIP THE FIRST TWO STEPS AS THE LATEST RELEASE IS TOO OLD. PLEASE CLONE FOR NOW THE REPOSITORY TO A LOCAL DIRECTORY AND THEN SET YOUR ENVIRONMENT AS INDICATED BELOW.

    `````
        git clone https://github.com/montoyaedu/iwant
    `````

    1. Download the latest binary release

	https://github.com/montoyaedu/iwant/releases/download/v1.0.0.2/iwant-app.zip

    1. Unzip the downloaded package

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
