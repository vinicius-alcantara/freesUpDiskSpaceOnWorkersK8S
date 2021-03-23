#!/bin/bash
############### VARS ################
USER="vinicius";
CURRENT_LOCAL_USER="$(cd ~ && pwd)";
WORKDIR_NAME="freesUpDiskSpaceOnWorkersK8S";
WORKDIR_FULL_PATH="$(echo "$CURRENT_LOCAL_USER"/"$WORKDIR_NAME")";
SEND_EMAIL_SCRIPT_NAME="sendMailCurlFunction.sh";
SCRIPT_MAIN_NAME="script.sh";
SEND_EMAIL_SCRIPT_FULL_PATH="$(echo "$WORKDIR_FULL_PATH"/"$SEND_EMAIL_SCRIPT_NAME")";
SCRIPT_MAIN_NAME_FULL_PATH="$(echo "$WORKDIR_FULL_PATH"/"$SCRIPT_MAIN_NAME")";
CURRENT_TIME=$(date +%H);
#####################################
######## INCLUDES | IMPORTS  ########
source "$SEND_EMAIL_SCRIPT_FULL_PATH";
##################################### 

function drainWorkersK8S(){

for WORKER_NAME_AND_IP_CREATE_VARS in $(kubectl get node | egrep -v "master" | cut -d " " -f1 | sed 1d | tr "-" "_");
do
	
	WORKER_NAME=$(echo "$WORKER_NAME_AND_IP_CREATE_VARS" | tr "_" "-");
	WORKER_IP=$(kubectl get node "$WORKER_NAME" -o wide | egrep -v master | cut -c43-56 | sed 1d | sed 's/ //g');	
	ENVIRONMENT=$(kubectl get nodes "$WORKER_NAME" -L environment | sed 1d | sed 's/ //g' | cut -d "-" -f2);
	DISK_SPACE_IN_USE_PERCENT=$(ssh "$USER"@"$WORKER_IP" df -h / --output=pcent | tail -n1 | sed 's/ //g' | sed 's/%//');
	DISK_SIZE_OLD=$(ssh "$USER"@"$WORKER_IP" df -h / --output=size | tail -n1);
	DISK_USED_OLD=$(ssh "$USER"@"$WORKER_IP" df -h / --output=used | tail -n1);
	DISK_AVAIL_OLD=$(ssh "$USER"@"$WORKER_IP" df -h / --output=avail | tail -n1);
	DISK_PCENT_OLD=$(ssh "$USER"@"$WORKER_IP" df -h / --output=pcent | tail -n1);

	if [ "$DISK_SPACE_IN_USE_PERCENT" -ge 30 ] && [ "$ENVIRONMENT" == "PRODUCAO" ]; #&& [ "$CURRENT_TIME" -ge 20 ]; 
	then
	   	kubectl drain $WORKER_NAME --force --timeout=500s --delete-emptydir-data --ignore-daemonsets;
		if [ $? == 0 ];
		then
		     UNSCHEDULABLE=$(kubectl describe no $WORKER_NAME | egrep "Unschedulable" | sed 's/ //g' | cut -d ":" -f2);
		     if [ $UNSCHEDULABLE == "true" ];
		     then
		     	 kubectl uncordon $WORKER_NAME;
			 if [ $? != 0 ];
			 then
			     UNSCHEDULABLE=$(kubectl describe no $WORKER_NAME | egrep "Unschedulable" | sed 's/ //g' | cut -d ":" -f2);
			     if [ $UNSCHEDULABLE != "true" ];
			     then
			         function sendEmailNotificationFailedCode2(){
                                     sendEmailNotificationFailedUncordon;
                                 }
                                  sendEmailNotificationFailedCode2;
                                  exit 0;
			     fi
			 fi
		     else
			 function sendEmailNotificationFailedCode4(){
                             sendEmailNotificationFailedDrainUnschedulableFalse;
                         }
                          sendEmailNotificationFailedCode4;
                          exit 0;
		     fi
		    
			UNSCHEDULABLE=$(kubectl describe no $WORKER_NAME | egrep "Unschedulable" | sed 's/ //g' | cut -d ":" -f2);
			if [ $UNSCHEDULABLE == "false" ];
			then
				
			    ssh -t "$USER"@"$WORKER_IP" sudo systemctl restart docker && DOCKER_DAEMON_STATUS=$(ssh "$USER"@"$WORKER_IP" sudo systemctl status docker | egrep -i "active" | cut -d ")" -f1 | cut -d "(" -f1 | cut -d ":" -f2 | sed 's/ //g');
			  
			    if [ $? == 0 ] && [ $DOCKER_DAEMON_STATUS == "active" ];
			    then
				ssh -t "$USER"@"$WORKER_IP" sudo docker image prune -af;
				if [ $? == 0 ];
				then
				    DISK_SIZE_NEW=$(ssh "$USER"@"$WORKER_IP" df -h / --output=size | tail -n1);
			            DISK_USED_NEW=$(ssh "$USER"@"$WORKER_IP" df -h / --output=used | tail -n1);
        			    DISK_AVAIL_NEW=$(ssh "$USER"@"$WORKER_IP" df -h / --output=avail | tail -n1);
        			    DISK_PCENT_NEW=$(ssh "$USER"@"$WORKER_IP" df -h / --output=pcent | tail -n1);

				    function sendEmailNotificationSuccess(){
                                    sendEmailNotificationCompleteSuccess;
                                    }
                                     sendEmailNotificationSuccess;
                                     exit 0;

			        else
				    function sendEmailNotificationFailedCode5(){
                                        sendEmailNotificationFailedPruneImage;
                                    }
                                     sendEmailNotificationFailedCode5;
				     exit 0;
				fi
				
			    else
				function sendEmailNotificationFailedCode1(){
				    sendEmailNotificationFailedStatusDocker;					
                                }   
				 sendEmailNotificationFailedCode1;
				 exit 0;
			    fi
		        else
			    function sendEmailNotificationFailedCode2(){
                                sendEmailNotificationFailedUncordon;
                            }
                             sendEmailNotificationFailedCode2;
			     exit 0;
   		        fi			       
	        else
		    function sendEmailNotificationFailedCode3(){
                        sendEmailNotificationFailedDrain;
                    }
		     sendEmailNotificationFailedCode3;
		     exit 0;
		fi
	fi	     
	
done

}

drainWorkersK8S;



