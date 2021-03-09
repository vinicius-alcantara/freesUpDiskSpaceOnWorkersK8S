#!/bin/bash
###### VARs - CONFIG AND ACESS's ######
SMTP_SRV="smtp.office365.com";
SMTP_PORT="587";
SMTP_USR="$(echo -ne "dmluaWNpdXMuYWxjYW50YXJhQHNvbW9zYWdpbGl0eS5jb20uYnI=" | base64 -d)";
SMTP_PASS="$(echo -ne "TXVkYXJAMTIz" | base64 -d)"
MAIL_FROM="$(echo -ne "dmluaWNpdXMuYWxjYW50YXJhQHNvbW9zYWdpbGl0eS5jb20uYnI=" | base64 -d)";
MAIL_TO_1="vinicius.redes2011@gmail.com";
MAIL_TO_2="vinicius.redes2020@gmail.com";
SUBJECT_SUCCESS="SUCCESS: SRM-SRV-";
SUBJECT_FAILED="FAILED: SRM-SRV-";
SUCCESS_NAME_FILE_EMAIL="body_mail_success.txt";
FAILED_NAME_FILE_EMAIL_CODE_1="body_mail_failed1.txt";
FAILED_NAME_FILE_EMAIL_CODE_2="body_mail_failed2.txt";
FAILED_NAME_FILE_EMAIL_CODE_3="body_mail_failed3.txt";
CURRENT_TIME_LOCAL="$(date +%H)";

if [ "$CURRENT_TIME_LOCAL" -ge 0 ] && [ "$CURRENT_TIME_LOCAL" -lt 12 ];
then

    INITIAL_MESSAGE_BODY_MAIL="bom dia";

elif [ "$CURRENT_TIME_LOCAL" -ge 12 ] && [ "$CURRENT_TIME_LOCAL" -lt 18 ];
then
  
    INITIAL_MESSAGE_BODY_MAIL="boa tarde";

elif [ "$CURRENT_TIME_LOCAL" -ge 18 ] && [ "$CURRENT_TIME_LOCAL" -le 23 ];
then
  
    INITIAL_MESSAGE_BODY_MAIL="boa noite";

fi
#######################################
#######################################
########### VARs - MESSAGES ###########
BODY_MAIL_SUCCESS="
From: "$MAIL_FROM"
To: "$MAIL_TO_1" "$MAIL_TO_2"
Subject: "$SUBJECT_SUCCESS"

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Espaço em disco liberado com sucesso no servidor/worker mencionado no assunto deste e-mail.
";
#######################################
BODY_MAIL_FAILED_CODE_1="
From: "$MAIL_FROM"
To: "$MAIL_TO_1" "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail.
Erro: Falha ao executar o restart no serviço do docker!!!
Por favor, verificar.
";
#######################################
BODY_MAIL_FAILED_CODE_2="
From: "$MAIL_FROM"
To: "$MAIL_TO_1" "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail. 
Erro: Falha ao realizar uncordon no worker.
Por favor, verificar.
";
#######################################
BODY_MAIL_FAILED_CODE_3="
From: "$MAIL_FROM"
To: "$MAIL_TO_1" "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail. 
Error: Falha ao realizar drain no worker. Provável ocorrência de timeout ao realizar o drain.
Por favor, verificar
";
#######################################

function create_body_mail_success() {
	cd ~;
	CURRENT_LOCAL=$(pwd);
	echo "$BODY_MAIL_SUCCESS" | sed 1d > "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL";  

}

create_body_mail_success;

function create_body_mail_failed_code_1() {
        cd ~;
        CURRENT_LOCAL=$(pwd);
        echo "$BODY_MAIL_FAILED_CODE_1" | sed 1d > "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_1";

}

create_body_mail_failed_code_1;

function create_body_mail_failed_code_2() {
        cd ~;
        CURRENT_LOCAL=$(pwd);
        echo "$BODY_MAIL_FAILED_CODE_2" | sed 1d > "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_2";

}

create_body_mail_failed_code_2;

function create_body_mail_failed_code_3() {
        cd ~;
        CURRENT_LOCAL=$(pwd);
        echo "$BODY_MAIL_FAILED_CODE_3" | sed 1d > "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_3";

}

create_body_mail_failed_code_3;

function sendEmailNotificationSuccess() {

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL";

  if [ -e "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL" ]; 
  then
     rm -rf "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL";
  fi

}

#sendEmailNotificationSuccess;

function sendEmailNotificationFailedStatusDocker() {

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_1";

  if [ -e "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_1" ];
  then
     rm -rf "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_1";
  fi

}

#sendEmailNotificationFailedStatusDocker;

function sendEmailNotificationFailedUncordon() {

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_2";

  if [ -e "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_2" ];
  then
     rm -rf "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_2";
  fi

}

#sendEmailNotificationFailedUncordon;

function sendEmailNotificationFailedDrain() {

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_3";

  if [ -e "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_3" ];
  then
     rm -rf "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL_CODE_3";
  fi

}

#sendEmailNotificationFailedDrain;
