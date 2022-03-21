#!/bin/bash

Print() {
  echo -e "-----------------$1----------------" &>>$LOG_FILE
  echo -e "\e[36m$1\e[0m"
}

Check_Stat() {
  if [ $? -ne 0 ]; then
    echo -e "\e[31mFAILURE\e[0m"
  else
    echo -e "\e[32mSUCCESS\e[0m"
  fi
}

APP_USER=roboshop
LOG_FILE=/tmp/roboshop.log
rm -f $LOG_FILE

USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
  echo 'You should run your script as sudo or root user'
  exit 1
fi

APP_SETUP() {
  id ${APP_USER} &>>${LOG_FILE}
  if [ $? -ne 0 ]; then
    Print "Add an Application User"
    useradd ${APP_USER} &>>${LOG_FILE}
    Check_Stat $?
  fi

  Print "Clean Up Old Content"
  rm -rf /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE}
  Check_Stat $?

  Print "Download Application Content"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
  Check_Stat $?

  Print "Extract Application Content"
  cd /home/${APP_USER} &>>${LOG_FILE} && unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
  Check_Stat $?
}

SERVICE_SETUP() {
  Print "Fix Application User Permissions"
  chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
  Check_Stat $?

  Print "Set Up SystemD File"
  sed -i -e "s/MONGO_DNSNAME/mongodb.roboshop.internal/" \
         -e "s/REDIS_ENDPOINT/redis.roboshop.internal/" \
         -e "s/MONGO_ENDPOINT/mongodb.roboshop.internal/" \
         -e "s/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/" \
         -e "s/CARTENDPOINT/cart.roboshop.internal/" \
         -e "s/DBHOST/mysql.roboshop.internal/" \
         -e "s/CARTHOST/cart.roboshop.internal/" \
         -e "s/USERHOST/user.roboshop.internal/" \
         -e "s/AMQPHOST/rabbitmq.roboshop.internal/" \
          /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} && mv /home/${APP_USER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
  Check_Stat $?

  Print "Restart ${COMPONENT} Service"
  systemctl daemon-reload &>>${LOG_FILE} && systemctl enable ${COMPONENT} &>>${LOG_FILE} && systemctl restart ${COMPONENT} &>>${LOG_FILE}
  Check_Stat $?
}



NODEJS() {
  Print "Configure YUM Repos"
  curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - &>>$LOG_FILE
  Check_Stat $?

  Print "Install NodeJS"
  yum install nodejs gcc-c++ -y &>>$LOG_FILE
  Check_Stat $?

  APP_SETUP

  Print "Install NodeJS Dependencies"
  cd /home/roboshop/catalogue &>>${LOG_FILE} && npm install &>>${LOG_FILE}
  Check_Stat $?

  SERVICE_SETUP
}

MAVEN() {
  Print "Install Maven"
  yum install maven -y &>>$LOG_FILE
  Check_Stat $?

  APP_SETUP
  SERVICE_SETUP
}

PYTHON() {
  Print "Install Python"
  yum install python36 gcc python3-devel -y &>>$LOG_FILE
  Check_Stat $?

  APP_SETUP

  Print "Install Python Dependencies"
  cd /home/${APP_USER}/payment && pip3 install -r requirements.txt &>>$LOG_FILE
  Check_Stat $?

  SERVICE_SETUP
}