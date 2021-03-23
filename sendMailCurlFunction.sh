#!/bin/bash
###### VARs - CONFIG AND ACESS's ######
#######################################
SMTP_SRV="smtp.office365.com";
SMTP_PORT="587";
SMTP_USR="$(echo -ne "dmluaWNpdXMuYWxjYW50YXJhQHNvbW9zYWdpbGl0eS5jb20uYnIK" | base64 -d)";
SMTP_PASS="$(echo -ne "TXVkYXJAMTIzCg==" | base64 -d)"
MAIL_FROM="$(echo -ne "dmluaWNpdXMuYWxjYW50YXJhQHNvbW9zYWdpbGl0eS5jb20uYnI=" | base64 -d)";
MAIL_TO_1="$(echo -ne "dmluaWNpdXMucmVkZXMyMDExQGdtYWlsLmNvbQo=" | base64 -d)";
MAIL_TO_2="$(echo "dmluaWNpdXMucmVkZXMyMDIwQGdtYWlsLmNvbQo=" | base64 -d)";
SUBJECT_SUCCESS="SUCCESS: SRM-SRV";
SUBJECT_FAILED="FAILED: SRM-SRV";
SUCCESS_NAME_FILE_EMAIL="body_mail_success.txt";
DIR_TEMPLATE_BODY_EMAILS="templates_emails";
CURRENT_TIME_LOCAL="$(date +%H)";
FAILED_NAME_FILE_EMAIL_CODE_1="body_mail_failed1.txt";
FAILED_NAME_FILE_EMAIL_CODE_2="body_mail_failed2.txt";
FAILED_NAME_FILE_EMAIL_CODE_3="body_mail_failed3.txt";
FAILED_NAME_FILE_EMAIL_CODE_4="body_mail_failed4.txt";
FAILED_NAME_FILE_EMAIL_CODE_5="body_mail_failed5.txt";
#######################################
#######################################
cd $WORKDIR_FULL_PATH;
if [ $? == 0 ];
then
    if [ ! -e $DIR_TEMPLATE_BODY_EMAILS ];
    then
	mkdir $DIR_TEMPLATE_BODY_EMAILS;
    fi	    
else
    echo "Falha ao acessar o diretório raiz do projeto - WORKDIR.";
    exit 0;
fi
#######################################
#######################################
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
########### VARs - MESSAGES ###########
BODY_MAIL_SUCCESS="
From: "$MAIL_FROM"
To: "$MAIL_TO_1" 
Cc: "$MAIL_TO_2"
Subject: "$SUBJECT_SUCCESS"-<WORKER_NAME>

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Espaço em disco liberado com sucesso no servidor/worker mencionado no assunto deste e-mail. Segue Evidências.

Antes:
Filesystem                       			Size Used Avail Use% Mounted
/dev/mapper/ubuntu--vg-ubuntu--lv      <DISK_SIZE_OLD><DISK_USED_OLD><DISK_AVAIL_OLD> <DISK_PCENT_OLD>  	/

Depois:
Filesystem                                              Size Used Avail Use% Mounted
/dev/mapper/ubuntu--vg-ubuntu--lv      <DISK_SIZE_NEW><DISK_USED_NEW><DISK_AVAIL_NEW> <DISK_PCENT_NEW>     /
";
#######################################
BODY_MAIL_FAILED_CODE_1="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Cc: "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"-<WORKER_NAME>

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail.
Erro: Falha ao executar o restart no serviço do docker!!!
Por favor, verificar.
";
#######################################
BODY_MAIL_FAILED_CODE_2="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Cc: "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"-<WORKER_NAME>

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail. 
Erro: Falha ao realizar uncordon no worker.
Por favor, verificar.
";
#######################################
BODY_MAIL_FAILED_CODE_3="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Cc: "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"-<WORKER_NAME>

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail. 
Error: Falha ao realizar drain no worker. Provável ocorrência de timeout ao realizar o drain.
Por favor, verificar
";
#######################################
BODY_MAIL_FAILED_CODE_4="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Cc: "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"-<WORKER_NAME>

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail. 
Error: Falha ao realizar drain no worker. O worker permanece schedulando novos pods (Unschedulable = false).
Por favor, verificar
";
#######################################
BODY_MAIL_FAILED_CODE_5="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Cc: "$MAIL_TO_2"
Subject: "$SUBJECT_FAILED"-<WORKER_NAME>

Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no servidor/worker mencionado no assunto deste e-mail. 
Error: Falha ao realizar prune das imagens docker.
Por favor, verificar
";
#######################################

function create_body_mail_success() {
	cd "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS";
	echo "$BODY_MAIL_SUCCESS" | sed 1d > "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";  
}

#create_body_mail_success;

function create_body_mail_failed_code_1() {
        cd "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS";
        echo "$BODY_MAIL_FAILED_CODE_1" | sed 1d > "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";
}

#create_body_mail_failed_code_1;

function create_body_mail_failed_code_2() {
        cd "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS";
        echo "$BODY_MAIL_FAILED_CODE_2" | sed 1d > "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";
}

create_body_mail_failed_code_2;

function create_body_mail_failed_code_3() {
        cd "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS";
        echo "$BODY_MAIL_FAILED_CODE_3" | sed 1d > "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_3";
}

create_body_mail_failed_code_3;

function create_body_mail_failed_code_4() {
        cd "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS";
        echo "$BODY_MAIL_FAILED_CODE_4" | sed 1d > "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_4";
}

create_body_mail_failed_code_4;

function create_body_mail_failed_code_5() {
        cd "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS";
        echo "$BODY_MAIL_FAILED_CODE_5" | sed 1d > "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_5";
}

create_body_mail_failed_code_5;

function sendEmailNotificationCompleteSuccess() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_SIZE_OLD>"/"$DISK_SIZE_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_USED_OLD>"/"$DISK_USED_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_AVAIL_OLD>"/"$DISK_AVAIL_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_PCENT_OLD>"/"$DISK_PCENT_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_SIZE_NEW>"/"$DISK_SIZE_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_USED_NEW>"/"$DISK_USED_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_AVAIL_NEW>"/"$DISK_AVAIL_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_PCENT_NEW>"/"$DISK_PCENT_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL"

  if [ -e "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL" ]; 
  then
     rm -rf "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  fi

}

#sendEmailNotificationCompleteSuccess;

function sendEmailNotificationFailedStatusDocker() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";

  if [ -e "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1" ];
  then
     rm -rf "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";
  fi

}

#sendEmailNotificationFailedStatusDocker;

function sendEmailNotificationFailedUncordon() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";

  if [ -e "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2" ];
  then
     rm -rf "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";
  fi

}

#sendEmailNotificationFailedUncordon;

function sendEmailNotificationFailedDrain() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_3";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_3";

  if [ -e "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_3" ];
  then
     rm -rf "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_3";
  fi

}

#sendEmailNotificationFailedDrain;

function sendEmailNotificationFailedDrainUnschedulableFalse() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_4";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_4";

  if [ -e "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_4" ];
  then
     rm -rf "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_4";
  fi

}

#sendEmailNotificationFailedDrainUnschedulableFalse;

function sendEmailNotificationFailedPruneImage() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_5";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --mail-rcpt "$MAIL_TO_2" \
    --upload-file "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_5";

  if [ -e "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_5" ];
  then
     rm -rf "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_5";
  fi

}

#sendEmailNotificationFailedPruneImage;

