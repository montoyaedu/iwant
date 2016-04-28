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
    * visual studio 2015 community

1. bitbucket.org (should work with any SCM but now we are using and supporting only bitbucket)
