This is mongodb backup script

########################## mongodb Data backup script description ##########################

此脚本为备份一主机上多实例的每个库的数据,并且备份完成后进行打包压缩,可以忽略一些不需要备份的集合。

mongodb_host_ip 此变量配置为要备份的主机地址，一般配置 127.0.0.1

例如： mongodb_host_ip=127.0.0.1

mongodb_user 此变量配置为要备份主机数据库实例的管理用户

例如： mongodb_user=admin

mongodb_passwd 此变量配置为要备份主机数据库实例的管理密码,如密码中有特殊字符，需进行转义.(admin$123)

例如： mongodb_passwd="admin$123"

port_list 此变量记录备份主机上数据库实例的端口，可以配置多个

例如： port_list=(27017 27018)

exclude_dbcollection_list 此变量记录备份主机上数据实例中备份库排除的表，可以配置多个

例如： exclude_dbcollection_list=( test test1 test2 test3 )
