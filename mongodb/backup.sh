#!/bin/bash

mongodb_host_ip=127.0.0.1
mongodb_user=xxxx
mongodb_passwd=xxxx
port_list=(27017 27018)
exclude_dbcollection_list=( test1 test2 test3 )


function get_master_dblist (){
mongo ${mongodb_host_ip}:${mongodb_host_port}/admin  -u ${mongodb_user}  -p ${mongodb_passwd} <<EOF
show dbs
EOF
}

function get_slave_dblist(){
mongo ${mongodb_host_ip}:${mongodb_host_port}/admin  -u ${mongodb_user}  -p ${mongodb_passwd} <<EOF
rs.slaveOk()
show dbs
EOF
}

function dbinfo () {

echo "${mongodb_host_ip} ${mongodb_host_port} ${mongodb_user} ${mongodb_passwd}" 

}

function dblist_results () {

if get_master_dblist >/dev/null 2>&1 ;then 
        dblist=$(get_master_dblist | grep GB | awk '{print $1}' | egrep  -v "admin|local")
elif get_slave_dblist >/dev/null 2>&1 ;then
        dblist=$(get_slave_dblist | grep GB | awk '{print $1}' | egrep  -v "admin|local")
else
        echo "Failed to get database list, please log in manually."
        exit 100
fi
}

function set_exclude_dbcollection (){
for dbcollection in `echo ${exclude_dbcollection_list[@]}`
do
	new_varlue="--excludeCollection ${dbcollection}"
	new_array_exclude_dbcollection_list[${#new_array_exclude_dbcollection_list[@]}]=${new_varlue}
done
}

function back_single_db (){

local db_name=$1
mongodump -h ${mongodb_host_ip}:${mongodb_host_port} -u ${mongodb_user} -p ${mongodb_passwd} -d ${db_name} \
$(echo ${new_array_exclude_dbcollection_list[@]}) \
-o ${fname} \
--authenticationDatabase admin > /dev/null
}


function back_single_instance (){
if [ X"${dblist}" = X ];then
        :
else
        for dbname in ${dblist}
        do
                back_single_db ${dbname}
        done
fi
}

function compress_tar (){
	local compress_name=$1
    if [ -d ${compress_name} ];then
        tar zcvf ${compress_name}.tar.gz  ${compress_name} >/dev/null
        rm -fr ${compress_name}
    else
		:
    fi
}

function multiprocess() {

	trap "exec 888>&- ;exec 888<&-;exit 0"  2
	mkfifo /tmp/.testfifo
	exec 888<>/tmp/.testfifo
	rm -fr /tmp/.testfifo
	des_function=${1}
	resource_sum=${2}
	for ((n=1;n<=3;n++))
	do
        	echo  >&888
	done
	for resource in  ${resource_sum}
	do
        	read -u888
       	 	{
               		${des_function}	${resource}
                	echo  >&888
        	} &
	done
	wait
	exec 888>&-
	exec 888<&-
}

function back_mongodb_instance (){
	
	local datetime=`date -d today +%m%d%H`
        local fpath=/data/cuser00/DB_home/dbdata/mongodump/$datetime/
	test -d ${fpath}  && : || mkdir -p ${fpath}
	( cd ${fpath} 
	set_exclude_dbcollection
	for instance_port in $(echo ${port_list[*]})
	do	
		mongodb_host_port=${instance_port}
		fname=${mongodb_host_port}_${datetime}
		array_compress_name[${#array_compress_name[@]}]=${fname}
		dblist_results
		back_single_instance
	done
	multiprocess compress_tar  "$(echo ${array_compress_name[@]})"
	)

}
######################the scripts start ################
back_mongodb_instance
