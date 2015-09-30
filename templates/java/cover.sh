#!/bin/bash
mvn org.jacoco:jacoco-maven-plugin:prepare-agent clean install -Pcoverage-per-test
mvn sonar:sonar -Dsonar.host.url=http://localhost/sonar -Dsonar.jdbc.url=jdbc:postgresql://localhost/sonar
