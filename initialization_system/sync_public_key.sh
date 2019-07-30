#!/bin/bash
##
##Function   Synchronization of public key
##Usage      bash sync_public_key.sh
##Author     fuzepeng


PASSWD=${1}
IP_LIST_FILE=all_ip.txt

if [ $# != 1 ];then

        echo "此脚本需要1个参数可以执行,参数为服务器密码..."
        echo "例如 : sh ${0}  passwd "
        exit
fi


if [ $(id -u) != 0 ];then

        echo "需要root管理员用户操作,你无权操作!"
        exit 
fi

if [ ! -f  ${IP_LIST_FILE} ];then

        echo "没有记录要推送ssh公钥的IP地址文件"
        exit 100

fi

function push_ssh_public_key () {

mkfifo /tmp/.testfifo
exec 888<>/tmp/.testfifo
rm -fr /tmp/.testfifo
echo ${PASSWD}  >&888

for IP in $(cat ${IP_LIST_FILE})
do

        sshpass -d  888 ssh-copy-id -i ~/.ssh/id_rsa.pub '-o StrictHostKeyChecking=no'  root@${IP}

done

exec 888>&-
exec 888<&-
}
############the scritps start #############
push_ssh_public_key
