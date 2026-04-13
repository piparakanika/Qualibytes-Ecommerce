#!/bin/bash

# Update system and install core packages
sudo apt install -y wget apt-transport-https gpg
sudo wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
sudo echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y fontconfig temurin-21-jdk

# Docker installation
sudo apt-get update
sudo apt-get install docker.io -y

# User group permission
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

sudo systemctl restart docker
sudo systemctl restart jenkins

# Jenkins Installation
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
sudo echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
sudo service jenkins stop
sudo printf "3\n" | sudo update-alternatives --config editor
sudo mkdir -p /etc/systemd/system/jenkins.service.d
sudo touch /etc/systemd/system/jenkins.service.d/override.conf
sudo sed -i '/^### Anything between here and the comment below will become the contents of the drop-in file$/a\
[Service]\
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.io.tmpdir=/var/cache/jenkins/tmp/ -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/New_York -Duser.timezone=America/New_York"\
Environment="JENKINS_OPTS=--pluginroot=/var/cache/jenkins/plugins"' /etc/systemd/system/jenkins.service.d/override.conf
sudo mkdir -p /var/cache/jenkins/tmp
sudo chown -R jenkins:jenkins /var/cache/jenkins/tmp
sudo service jenkins start

# Install dependencies and Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release snapd -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

# AWS CLI installation
sudo snap install aws-cli --classic

# Helm installation
sudo snap install helm --classic

# Kubectl installation
sudo snap install kubectl --classic
# This shell file worked use this one in install shell and when you install kubectl na to uski bin file copy karke home dir me le ana to chalne lagega
