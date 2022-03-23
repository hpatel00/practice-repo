#!/bin/bash

Print "Install Erlang Dependency"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm -y &>>$LOG_FILE
Check_Stat $?

Print "Setup YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
Check_Stat $?

Print "Install RabbitMQ"
yum install rabbitmq-server -y &>>$LOG_FILE
Check_Stat $?

Print "Start RabbitMQ"
systemctl enable rabbitmq-server &>>$LOG_FILE && systemctl start rabbitmq-server &>>$LOG_FILE
Check_Stat $?

rabbitmqctl list_users | grep roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
  Print "Create Application User"
  rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
  Check_Stat $?
fi

Print "Configure Application User"
rabbitmqctl set_user_tags roboshop administrator &>>$LOG_FILE && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
Check_Stat $?