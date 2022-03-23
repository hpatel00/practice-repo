#!/bin/bash

source components/common.sh

Print "Configure YUM Repos"
curl -f -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
Check_Stat $?

Print "Install MySQL"
yum install mysql-community-server -y &>>${LOG_FILE}
Check_Stat $?

Print "Start MySQL Service"
systemctl enable mysqld &>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
Check_Stat $?

Print "Create User"
echo 'show databases' | mysql -uroot -pRoboShop@1 &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  Print "Change Default Root Password"
  echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('RoboShop@1');" >/tmp/rootpass.sql
  DEFAULT_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
  mysql --connect-expired-password -uroot -p"${DEFAULT_ROOT_PASSWORD}" </tmp/rootpass.sql &>>${LOG_FILE}
  Check_Stat $?
fi

echo 'show plugins' | mysql -uroot -pRoboShop@1 2>>${LOG_FILE} | grep validate_password &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  Print "Uninstall Password Validate Plugin"
  echo 'uninstall plugin validate_password;' >/tmp/pass-validate.sql
  mysql --connect-expired-password -uroot -pRoboShop@1 </tmp/pass-validate.sql &>>${LOG_FILE}
  Check_Stat $?
fi

Print "Download Database Schema"
curl -f -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>${LOG_FILE}
Check_Stat $?

Print "Extract Database Schema"
cd /tmp && unzip mysql.zip &>>${LOG_FILE}
Check_Stat $?

Print "Load Database Schema"
cd mysql-main && mysql -u root -pRoboShop@1 <shipping.sql &>>${LOG_FILE}
Check_Stat $?