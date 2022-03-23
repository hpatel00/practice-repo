#!/bin/bash

source components/common.sh

Print "Configure YUM Repos"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
Check_Stat $?

Print "Install MySQL"
yum install mysql-community-server -y &>>${LOG_FILE}
Check_Stat $?

Print "Start MySQL Service"
systemctl enable mysqld &>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
Check_Stat $?

Print "Create User"
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('RoboShop@1');" >/tmp/rootpass.sql
DEFAULT_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
mysql -uroot -p"DEFAULT_ROOT_PASSWORD" </tmp/rootpass.sql

#&>>${LOG_FILE} && mysql_secure_installation &>>${LOG_FILE} &&
#
#Print "Download Database Schema"
#curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>${LOG_FILE}
#Check_Stat $?
#
#Print "Extract Database Schema"
#cd /tmp && unzip mysql.zip &>>${LOG_FILE}
#Check_Stat $?
#
#Print "Load Database Schema"
#cd mysql-mainmysql && mysql -u root -pRoboShop@1 <shipping.sql &>>${LOG_FILE}
#Check_Stat $?