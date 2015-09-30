# iwant
An effort to create a simple programming project starter. (Something like mvn archetype:generate but easier)

Right now we support only a simple c# template (archetype).

Requirements.
=============

Requirements ar for now a description of my development environments. Contributions are welcome.

Servers.
========

1. jenkins on a windows box. (nuget pack works only on windows)
2. nexus (should work with any artifact server with nuget support)
3. bitbucket (should work with any SCM but now we are using and supporting only bitbuck)

Common.
=======

1. mono
1. java 1.7+
1. maven 3.3+
1. git
1. nunit 2.6.4+
1. a bitbucket account (with ssh access)

On Windows.
===========

1. visual studio 2010
1. windows sdk 7.1
1. innosetup 5.5+

On Mac OS X.
============

1. homebrew
1. wine 1.7+
1. innosetup 5.5+ (installed and launched by wine)

On Linux (Ubuntu).
==================

1. wine 1.7+
1. innosetup 5.5+ (installed and launched by wine)

Install.
========

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

Create a new project.
=====================

`````
    iwant c# MyApp MyPackage v4.0 Exe
`````

Arguments.
==========

1. Template (folder must exists under ${IWANT_HOME}/templates)
2. Basename
3. Namespace
4. .NET framework version
5. Output Type

Show created project.
=====================

`````
MyPackage.MyApp
├── MyApp.cs
├── MyPackage.MyApp.csproj
├── MyPackage.MyApp_vs2010.sln
├── Properties
│   └── AssemblyInfo.cs
├── app.config
├── buildsetup.iss
├── issc (folder with embedded innosetup)
│   └── ... innosetup files and folders.
├── pom.xml
├── release
├── buildonly
├── release.bat
├── buildonly.bat
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

Change pom.xml version with maven versions plugin.
==================================================

This command sets the pom.xml version to the specified version.

`````
    cd MyPackage.MyApp
    mvn versions:set -DnewVersion=2.0.0.1
`````

Remove backup pom.xml.
======================

The previous command creates a backup file of the old pom.xml file. After successfully setting a version you will need to call the following command.

`````
    cd MyPackage.MyApp
    mvn versions:commit
`````

Apply version to Properties/AssemblyInfo.cs.
============================================

`````
    cd MyPackage.MyApp
    mvn dotnet:version
`````

Try undocumented scripts.
=========================

`````
    cd MyPackage.MyApp
    ./release
    ./buildonly
`````

`````
    create-windows-app
    create-console-app
    create-library
`````

TODO:
=====

1. Complete dos batch/linux scripts.
1. Add documentation for adding releases.
1. Add support for unit testing to c# template.
1. Add documentation for innosetup.
1. Add documentation for adding git remotes.
1. Add support for deploying nuget packages to c# template.
1. Add documentation for undocumented scripts.

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
