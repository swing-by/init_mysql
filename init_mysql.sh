#!/bin/bash

if [ $1 != "" ]; then
    version="-$1"
else
    version=""
fi

mariadb=`rpm -qa mariadb-libs`

if [ "$mariadb" != "" ]; then
    yum remove mariadb-libs -y
fi

mysql_packages=$(rpm -qa mysql-community-*)

if [ "$mysql_packages" != "" ]; then
    systemctl stop mysqld.server
    rm -rf /var/lib/mysql
    rm /var/log/mysqld.log
    yum remove  -y $mysql_pakage
    for mysql_pakage in $mysql_packages; do
        yum remove  -y $mysql_pakage
    done
fi

rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-2.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

yum install mysql-community-server$version -y
systemctl start mysqld.service
password=`grep "temporary password is generated for root@localhost" /var/log/mysqld.log | awk -F "localhost: " '{print $2}'`

export MYSQL_PWD=$password
new_password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=[]{}<>?' | fold -w 16 | head -n 1`

mysql -uroot --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_password}';"

echo "${new_password}" > root_pass.txt
