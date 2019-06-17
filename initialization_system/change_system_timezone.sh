#!/bin/bash
#
#Function:	The Purpose of this script is to  chang our system timezone and then restart some servers
#Usage:		bash chang_system_timezone.sh
#Auth:		fuzepeng

################the points of notice##########
# 1. the script can only support Centos7.x for sevices that will be started after system time changes


target_timezone=${1:-Asia/Shanghai}



if [ $(id -u ) != 0 ];then
	echo -e "\033[1;40;31m Error: You must be root to run this script,plase use root to install this script.\033[0m"
	exit 1
fi

restart_services () {

        systemctl restart crond
        systemctl restart rsyslog
}

build_link (){

	ln -fs /usr/share/zoneinfo/${target_timezone} /etc/localtime \
        && echo -e "\033[40;32m Timezone is already changed. now timezone is ${target_timezone}. \033[40;37m" \
        || echo -e "\033[1;40;31m Timezone changes faild! \033[0m"

}

change_timezone () {
	
	if ls -l /etc/localtime  > /dev/null 2>&1 ;then
		if [ -L /etc/localtime ];then
			now_timezone=$(ls -l /etc/localtime  | awk '{print $NF}' | awk -F "/usr/share/zoneinfo/" '{print $2}')
			if [ $(echo "${now_timezone}"  | md5sum |awk '{print $1}')  == $(echo "${target_timezone}"  | md5sum |awk '{print $1}') ];then
				:
				echo -e "\033[40;32m Timezone is already target timezone,no changes.\033[40;37m"
			else
				build_link
			fi
		else
			build_link
		fi
	else
		build_link
	fi
	restart_services
} 

##################start this niubility script ############

change_timezone
