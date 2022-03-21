#!/bin/bash

source components/common.sh

Print "Installing Nginx"
yum install nginx -y &>>$LOG_FILE
Check_Stat $?

Print "Downloading Nginx Content"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
Check_Stat $?

Print "Remove Prior Nginx Content"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
Check_Stat $?

cd /usr/share/nginx/html

Print "Unzip Nginx Content"
unzip /tmp/frontend.zip &>>$LOG_FILE && mv frontend-main/* . &>>$LOG_FILE && mv static/* . &>>$LOG_FILE
Check_Stat $?

Print "Update RoboShop Configuration"
rm -rf frontend-main README.md &>>$LOG_FILE

mv localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
for component in catalogue cart payment user shipping; do
  echo -e "Updating $component within Configuration"
  sed -i -e "/${component}/s/localhost/${component}.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
done
Check_Stat $?

Print "Restart Nginx"
systemctl enable nginx &>>$LOG_FILE && systemctl start nginx &>>$LOG_FILE
Check_Stat $?