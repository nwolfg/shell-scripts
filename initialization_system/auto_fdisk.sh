#!/bin/bash
#
#Function:    auto fdisk
#Usage:	      bash auto_fdisk.sh
#Auth:        fuzepeng

###############the points of notice###########
# 1.the script must be run the first time without mkdir any data directory .(E.g mount_dir )
# 2.when a new disk add you system ,you will run this a niubility script.



mount_dir=data
device_type=${1:-vd}
count=0
tmp1=/tmp/.tmp1
tmp2=/tmp/.tmp2
>$tmp1
>$tmp2
fstab_file=/etc/fstab
LOCKfile=/tmp/.$(basename $0)


if [ -f "${LOCKfile}" ];then
	echo -e "\033[1;40;31m The script is already exist,plase next time to run this script.\033[0m"
	exit
else
	echo -e "\033[40;32m Step 1. No lock file,begin to create lock file and continue. \033[40;37m"
	touch ${LOCKfile}
fi


if [ $(id -u ) != 0 ];then
	echo -e "\033[1;40;31m Error: You must be root to run this script,plase use root to install this script.\033[0m"
	rm -fr ${LOCKfile}
	exit 1
fi


check_disk () {
	>${LOCKfile}
	device_list=$(fdisk -l  | grep "Disk" | grep "/dev" | awk  '{print $2}' | awk -F: '{print $1}' | grep "${device_type}")
	for i in `echo ${device_list}`
	do
		device_count=$(fdisk -l ${i}|grep "${i}"|awk '{print $2}'|awk -F: '{print $1}'|wc -l)
		if [ ${device_count} -lt 2 ];then
			now_mount=$(df -h)
			if echo ${now_mount} | grep -w "${i}" >/dev/null 2>&1 ;then
				echo -e "\033[40;32m The ${i} disk is mounted.\033[40;37m"
			else
				echo ${i} >> ${LOCKfile}
				echo "You have a free disk,Now will fdisk it and mount it."
			fi
		fi
	done
	disk_list=$(cat ${LOCKfile})
	if [ "X${disk_list}" == "X" ];then
		echo -e "\033[1;40;31m No free disk need to be fdisk,Exit script. \033[0m"
		rm -fr ${LOCKfile}
		exit 0
	else
		echo -e "\033[40;32m This system have free disk :\033[40;37m"
		for  i in `echo ${disk_list}`
		do
			echo "${i}"
			count=$((count+1))
		done
	fi
}

modify_env () {
	modprobe xfs
	yum install xfsprogs  -y
}


fdisk_run () {
fdisk $1  << EOF
n
p
1


wq
EOF

sleep 5
mkfs.xfs ${1}1
}

make_dir () {
	
	echo -e "\033[40;32m Step 4. Begin to make directory \033[40;37m "
	now_dir_count=$(ls / | grep "${mount_dir}" | awk -F "${mount_dir}" '{print $2 }' | sort -n | tail -1 )
	if [ "X${now_dir_count}" == "X" ];then
		if [ ${count} == 1 ];then
			mkdir /${mount_dir}
			echo "/${mount_dir}" >>${tmp1}
		else
			mkdir /${mount_dir}
			echo "/${mount_dir}" >>${tmp1}
			for j in `seq $(($count-1))`
			do
				mkdir /${mount_dir}${j}
				echo "/${mount_dir}${j}" >>${tmp1}
			done
		fi
	else
		for j in `seq ${count}`
		do
			mkdir /${mount_dir}$(($now_dir_count+j))
			echo "/${mount_dir}$(($now_dir_count+j))" >> ${tmp1}
		done
	fi
}

main () {

	for i in `echo ${disk_list}`
	do
		echo -e "\033[40;32m Step 3.Begin to fdisk free disk .\033[40;37m"
		fdisk_run ${i}
		echo "${i}1" >> ${tmp2}
	done
	make_dir
	paste ${tmp2} ${tmp1} > ${LOCKfile}
	echo -e "\033[40;32m Step 5.Begin to write configuration to /etc/fstab and mount device.\033[40;37m"
	while read  a b 
	do
		if grep -v ^\# ${fstab_file} | grep ${a} >/dev/null ;then 
			sed -i "s=${a}*=#&=" ${fstab_file}
		fi
		echo "${a}		${b}		xfs	defaults	0 0" >> ${fstab_file}
	done < ${LOCKfile}
	mount -a  
}

##################start this niubility script ############
echo -e "\033[40;32m Step 2.Begin to check free disk.\033[40;37m"
check_disk
main
df -h 
rm -fr $LOCKfile $tmp1 $tmp2
