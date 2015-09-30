#!/bin/bash
mvn org.jacoco:jacoco-maven-plugin:prepare-agent clean install -Pcoverage-per-test
mvn sonar:sonar -Dsonar.host.url=http://192.168.1.20/sonar -Dsonar.jdbc.url=jdbc:postgresql://192.168.1.20/sonar
