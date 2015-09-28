# iwant
An effort to create a simple programming project starter. (Something like mvn archetype:generate but easier)

Requirements.
=============

1. maven 3.x
1. git

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
1. https://git-scm.com/
1. https://www.visualstudio.com/
1. https://github.com/montoyaedu/Uuidgen.NET
