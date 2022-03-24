#!/bin/bash

source components/common.sh

Print "Configure YUM Repos"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG_FILE}
Check_Stat $?

Print "Install Redis"
yum install redis -y &>>${LOG_FILE}
Check_Stat $?

Print "Update Redis Listening Address"
if [ -f /etc/redis.conf ]; then
  sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis.conf &>>${LOG_FILE}
fi
if [ -f /etc/redis/redis.conf ]; then
  sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis/redis.conf &>>${LOG_FILE}
fi
Check_Stat $?

Print "Start Redis Service"
systemctl enable redis &>>${LOG_FILE} && systemctl start redis &>>${LOG_FILE}
Check_Stat $?