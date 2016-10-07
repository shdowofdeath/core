#!/bin/bash
pushd /var/lib/jenkins/plugins
    sudo su -c "wget http://updates.jenkins-ci.org/latest/jacoco.hpi" jenkins
    sudo su -c "wget http://updates.jenkins-ci.org/latest/cobertura.hpi" jenkins
    sudo su -c "wget http://updates.jenkins-ci.org/latest/robot.hpi" jenkins
    sudo su -c "wget http://updates.jenkins-ci.org/latest/maven-plugin.hpi" jenkins
    sudo su -c "wget http://updates.jenkins-ci.org/latest/javadoc.hpi" jenkins
    sudo su -c " wget http://updates.jenkins-ci.org/latest/influxdb.hpi" jenkins
popd
sudo service jenkins restart
rm -rf /var/lib/jenkins/jenkinsci.plugins.influxdb.InfluxDbPublisher.xml
cp /opt/controlbox/jenkins_metrics/jenkinsci.plugins.influxdb.InfluxDbPublisher.xml /var/lib/jenkins/jenkinsci.plugins.influxdb.InfluxDbPublisher.xml 
curl -i -GET http://localhost:8086/query --data-urlencode "q=CREATE DATABASE jenkins_logs"
curl -i -GET http://localhost:8086/query --data-urlencode "q=CREATE USER test WITH PASSWORD '12345'"
curl --user admin:admin -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary "{\"name\":\"jenkins\",\"type\":\"influxdb\",\"url\":\"http://127.0.0.1:8086\",\"access\":\"proxy\",\"database\":\"jenkins_logs\",\"user\":\"jenkins\",\"password\":\"12345\"}" "http://127.0.0.1:3000/api/datasources"
service jenkins restart

