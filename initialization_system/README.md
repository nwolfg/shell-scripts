
1. auto_fdisk.sh 此脚本为硬盘初始化脚本，使用方法直接运行既可，可以传入一个参数，这个参数为硬盘设备的类型；若不传入参数，默认磁盘设备为/dev/vd*类型.
   默认磁盘挂载目录为/data,可以修改脚本指定目录,修改变量为：mount_dir=data
  
    sh auto_fdisk.sh  vd  #指定磁盘设备为vd类型
         
    sh auto_fdisk.sh  #不指定磁盘设备类型，默认为vd类型
   
2. change_system_timezone.sh 此脚本为修改系统时区脚本,可以通过指定要修改为那个时区,默认时区为中国上海(Asia/Shanghai)

    sh change_system_timezone.sh  Asia/Shanghai #指定要修改的时区
          
    sh change_system_timezone.sh  #不指定时区,默认修改为中国上海(Asia/Shanghai)
