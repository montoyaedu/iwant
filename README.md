# iwant
An effort to create a simple programming project starter. (Something like mvn archetype:generate but easier)

Create a new project.
=====================

`````
    ./iwant
    using template c#
    using folder MyApp
    using name MyApp
    using package MyPackage
    using version v4.5
    using type WinExe
    using project guid BAF96FB3-374D-4EE2-AB7C-0768F393FB5F
    using COM guid BC103D59-4F9E-46E8-996A-E2663360A278
    using assembly version 1.0.0.0
    using assembly version qualifier -SNAPSHOT
    using substitution command sed -e s/\${AssemblyName}/MyApp/ -e s/\${RootNamespace}/MyPackage/ -e s/\${TargetFrameworkVersion}/v4.5/ -e s/\${OutputType}/WinExe/ -e s/\${ProjectGuid}/BAF96FB3-374D-4EE2-AB7C-0768F393FB5F/ -e s/\${ComGuid}/BC103D59-4F9E-46E8-996A-E2663360A278/ -e s/\${AssemblyVersion}/1.0.0.0/ -e s/\${AssemblyVersionQualifier}/-SNAPSHOT/
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

Use maven for version management.
=================================

`````
    cd MyApp
    git init
    git add '*'
    git commit -m "Initial commit"
    mvn versions:set -DnewVersion=2.0.0.1
    git diff
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
    git add pom.xml
    mvn versions:commit
    mvn dotnet:version
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
    git add Properties/AssemblyInfo.cs
    git commit -m "[RELEASE] - released version 2.0.0.1"

`````
