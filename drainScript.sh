#!/bin/bash

######## VARS ########
WORK_DIR="/root/drainScript";
LIB_WORKERS_VARS=$WORK_DIR"/workers_vars.sh";

function createHostnameIPvars_workers(){

if [ ! -e $WORK_DIR ]; then

	mkdir -p $WORK_DIR;
	echo "#!/bin/bash" > "$LIB_WORKERS_VARS";
	chmod 770 "$LIB_WORKERS_VARS";

else
	echo "#!/bin/bash" > "$LIB_WORKERS_VARS";
	chmod 770 "$LIB_WORKERS_VARS";
fi

for WORKER_NAME_CREATE_VARS in $(kubectl get node | egrep -v master | cut -d " " -f1 | sed 1d | tr "-" "_");
do
	WORKER_NAME=$(echo "$WORKER_NAME_CREATE_VARS" | tr "_" "-");
	WORKER_IP="$(kubectl get node $WORKER_NAME -o wide | egrep -v master | cut -c43-56 | sed 1d | sed 's/ //g')";
	echo "$WORKER_NAME"="$WORKER_IP" >> "$LIB_WORKERS_VARS";
	echo "$WORKER_NAME" >> $WORK_DIR"/workers_list.txt";	
done

}

createHostnameIPvars_workers;

source "$LIB_WORKERS_VARS";

for WORKER in $(cat $WORK_DIR"/workers_list.txt");
do



done













