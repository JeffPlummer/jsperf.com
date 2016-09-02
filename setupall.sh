#!/usr/bin/env bash

sudo yum update -y
sudo yum -y install git

sudo yum -y install gcc-c++ make
sudo yum -y install openssl-devel

#echo '* - nofile 64000' | sudo tee -a /etc/security/limits.conf
#echo 'fs.file-max = 64000' | sudo tee -a /etc/sysctl.conf

cd ~
git clone git://github.com/nodejs/node.git
cd node
git checkout v6.4.0
./configure
make
sudo make install

cd ~
git clone https://github.com/npm/npm.git
cd npm
sudo make install

cd ~
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user


sudo curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/bin/


cd ~
mkdir jsperf
cd jsperf
git clone https://github.com/JeffPlummer/jsperf.com.git
cd jsperf.com

IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "DOMAIN=$IP" >> .env

sudo docker create -v /var/lib/mysql --name data-jsperf-mysql mysql /bin/true
MYSQL_PASSWORD=jsperf sudo docker-compose up --build -d
MYSQL_PASSWORD=jsperf sudo docker-compose run web node /code/setup/tables

