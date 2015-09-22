# iwant
An effort to create a simple programming project starter. (Something like mvn archetype:generate but easier)

Install.
========

Download the latest project version and add the folder to your PATH environment variable.

set the IWANT_HOME environment variable with the path of the iwant folder.

`````
git clone https://github.com/montoyaedu/iwant
export PATH=$PATH:<iwant path>
export IWANT_HOME=<iwant path>
`````

Create a new project.
=====================

`````
    iwant
    usage Examples
    iwant c# MyExecutable Com.Company.MySuite v4.0 WinExe 1.0.0.0 -SNAPSHOT exe
    iwant c# MyLibrary Com.Company.MySuite v4.0 Library 1.0.0.0 -SNAPSHOT dll
    using template c#
    using folder MyApp
    using name MyApp
    using package MyPackage
    using version v4.0
    using type Exe
    using project guid F8EB9112-8331-4454-8720-8DDCF1A9347C
    using COM guid 443B8F8F-1622-4B23-821E-84D6D1CBC12F
    using solution guid 2EC9C0BB-2685-4D6D-8030-AFE16A56E6F3
    using assembly version 1.0.0.0
    using assembly version qualifier -SNAPSHOT
    using substitution command sed -e s/\${AssemblyName}/MyApp/ -e s/\${RootNamespace}/MyPackage/ -e s/\${TargetFrameworkVersion}/v4.0/ -e s/\${OutputType}/Exe/ -e s/\${ProjectName}/MyPackage.MyApp/ -e s/\${ProjectGuid}/F8EB9112-8331-4454-8720-8DDCF1A9347C/ -e s/\${ComGuid}/443B8F8F-1622-4B23-821E-84D6D1CBC12F/ -e s/\${SolutionGuid}/2EC9C0BB-2685-4D6D-8030-AFE16A56E6F3/ -e s/\${AssemblyVersion}/1.0.0.0/ -e s/\${AssemblyVersionQualifier}/-SNAPSHOT/
`````

Show created project.
=====================

`````
    tree MyApp
    MyApp
    ├── MyApp.cs
    ├── MyPackage.MyApp.csproj
    ├── Properties
    │   └── AssemblyInfo.cs
    └── pom.xml
`````

Install dotnet-maven-plugin.
============================

`````
    git clone https://github.com/ethiclab/dotnet-maven-plugin
    cd dotnet-maven-plugin
    mvn clean install
    cd ..
`````

Version control. (git)
======================

`````
    cd MyApp
    git init
    git add '*'
    git commit -m "Initial commit"
`````

Change pom.xml version with maven versions plugin.
===================================================

`````
    cd MyApp
    mvn versions:set -DnewVersion=2.0.0.1
`````

Show modified version.
======================

`````diff
    diff --git a/pom.xml b/pom.xml
    index c3283fc..a8b9ff3 100644
    --- a/pom.xml
    +++ b/pom.xml
    @@ -3,7 +3,7 @@
       <modelVersion>4.0.0</modelVersion>
       <groupId>MyPackage</groupId>
       <artifactId>MyApp</artifactId>
    -  <version>1.0.0.0-SNAPSHOT</version>
    +  <version>2.0.0.1</version>
       <packaging>dotnet:library</packaging>
       <build>
         <plugins>
`````

Add file with modified version to staging area.
===============================================

`````
    git add pom.xml
`````

Remove backup files.
====================

`````
    mvn versions:commit
`````

Apply version to Properties/AssemblyInfo.cs.
============================================

`````
    mvn dotnet:version
`````

Show modified file.
===================

`````diff
    git diff
    diff --git a/Properties/AssemblyInfo.cs b/Properties/AssemblyInfo.cs
    index 10d7622..4f1d643 100644
    --- a/Properties/AssemblyInfo.cs
    +++ b/Properties/AssemblyInfo.cs
    @@ -22,9 +22,9 @@ using System.Runtime.InteropServices;
     // The following GUID is for the ID of the typelib if this project is exposed to COM
     [assembly: Guid("BC103D59-4F9E-46E8-996A-E2663360A278")]

    -[assembly: AssemblyVersion("1.0.0.0")]
    -[assembly: AssemblyFileVersion("1.0.0.0")]
    -[assembly: AssemblyInformationalVersion("1.0.0.0-SNAPSHOT")]
    +[assembly: AssemblyVersion("2.0.0.1")]
    +[assembly: AssemblyFileVersion("2.0.0.1")]
    +[assembly: AssemblyInformationalVersion("2.0.0.1")]

     // The following attributes are used to specify the signing key for the assembly,
     // if desired. See the Mono documentation for more information about signing.
`````

Add file to staging area and commit.
====================================

`````
    git add Properties/AssemblyInfo.cs
    git commit -m "[RELEASE] - released version 2.0.0.1"
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
1. https://git-scm.com/
1. https://www.visualstudio.com/

