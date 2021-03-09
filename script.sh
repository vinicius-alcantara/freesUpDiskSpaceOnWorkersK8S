#!/bin/bash
############### VARS ################
USER="vinicius";
WORKDIR="$(cd ~ && pwd)";
CURRENT_TIME=$(date +%H);
SENDMAIL_FUNCTION_INCLUDE="$(echo "$WORKDIR"/sendMailCurlFunction.sh)";
#####################################
######## INCLUDES | IMPORTS  ########
source "$SENDMAIL_FUNCTION_INCLUDE";
##################################### 

function drainWorkersK8S(){

for WORKER_NAME_AND_IP_CREATE_VARS in $(kubectl get node | egrep -v "master" | cut -d " " -f1 | sed 1d | tr "-" "_");
do
	
	WORKER_NAME=$(echo "$WORKER_NAME_AND_IP_CREATE_VARS" | tr "_" "-");
	WORKER_IP=$(kubectl get node "$WORKER_NAME" -o wide | egrep -v master | cut -c43-56 | sed 1d | sed 's/ //g');	
	ENVIRONMENT=$(kubectl get nodes "$WORKER_NAME" -L environment | sed 1d | sed 's/ //g' | cut -d "-" -f2);
	DISK_ESPACE_IN_USE_PERCENT=$(ssh "$USER"@"$WORKER_IP" df -h / --output=pcent | tail -n1 | sed 's/ //g' | sed 's/%//');

	if [ "$DISK_ESPACE_IN_USE_PERCENT" -ge 30 ] && [ "$ENVIRONMENT" == "PRODUCAO" ] && [ "$CURRENT_TIME" -ge 20 ]; 
	then
		#echo "O $WORKER_NAME é tagueado para $ENVIRONMENT";
	   	kubectl drain $WORKER_NAME --force --timeout=500s --delete-local-data --ignore-daemonsets;
		if [ $? == 0 ];
		then
		     UNSCHEDULABLE=$(kubectl describe no $WORKER_NAME | egrep "Unschedulable" | sed 's/ //g' | cut -d ":" -f2);
		     if [ $UNSCHEDULABLE == "true"];
		     then
		     	kubectl uncordon $WORKER_NAME;
		     fi
			
			UNSCHEDULABLE=$(kubectl describe no $WORKER_NAME | egrep "Unschedulable" | sed 's/ //g' | cut -d ":" -f2);
			if [ $UNSCHEDULABLE == "false" ];
			then
				
			    ssh "$USER"@"$WORKER_IP" systemctl restart docker && DOCKER_DAEMON_STATUS=$(ssh "$USER"@"$WORKER_IP" systemctl status docker | egrep -i "active" | cut -d ")" -f1 | cut -d "(" -f1 | cut -d ":" -f2 | sed 's/ //g');
			  
			    if [ $? == 0 ] && [ $DOCKER_DAEMON_STATUS == "active" ];
			    then

				docker image prune -af;
				function sendEmailNotificationSuccess(){
				    sendEmailNotificationSuccess;
	
                                }

				  sendEmailNotificationSuccess;

			    else

				function sendEmailNotificationFailedCode1(){
				    sendEmailNotificationFailedStatusDocker;					
                                }   
				  sendEmailNotificationFailedCode1;
			    fi			    
			    
			else

			    function sendEmailNotificationFailedCode2(){
				sendEmailNotificationFailedUncordon;
			    } 				
			      sendEmailNotificationFailedCode2;
			fi
	                 
		else
		    function sendEmailNotificationFailedCode3(){
                         sendEmailNotificationFailedDrain;
                    }
		      sendEmailNotificationFailedCode3;
		fi		


	elif [ "$DISK_ESPACE_IN_USE_PERCENT" -ge 5 ] && [ "$ENVIRONMENT" == "DESENVOLVIMENTO" ];
	then	
		#echo "O $WORKER_NAME é tagueado para $ENVIRONMENT";
		
	fi

	
done

}

drainWorkersK8S;

