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
