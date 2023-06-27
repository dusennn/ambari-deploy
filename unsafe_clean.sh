#!/bin/bash

#author: Sen Du
#email: dusen@gennlife.com
#created: 2023-04-18 15:00:00
#updated: 2023-04-18 15:00:00

set -e 
source 00_env

# 避免误操作，添加输入密码步骤
function identification() {
    read -s -p "请输入密码: " pswd
    shapswd=$(echo $pswd | sha1sum | head -c 10)
    if [[ "$shapswd" == "d5b3776603" ]]; then
        echo && true
    else
        echo && false
    fi
}

# 清理 java 服务
function clean_java() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "sed -i '/JAVA_HOME/d' /etc/profile"
        ssh -n $ipaddr "rm -rf /opt/jdk1.8.0_202"
        ssh -n $ipaddr "unlink /usr/java/default"
    done
}

# 清理 mysql 服务
function clean_mysql() {
    echo -e "$CSTART>>>>$(hostname -I)$CEND"
    systemctl stop mysql*
    yum remove -y mariadb*
    yum remove -y mysql*
    yum remove -y MySQL*
    rm -rf /var/lib/mysql*
    rm -rf /var/share/mysql*
    rm -rf /etc/my.cnf
    rm -rf /var/log/mysql*
    rm -rf /root/.mysql_secret
    rm -rf /root/.mysql_history
}

# 清理所有服务器上的 ambari 服务
function clean_ambari() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "systemctl stop ambari*"
        ssh -n $ipaddr "yum remove -y ambari*"
        ssh -n $ipaddr "rm -rf /opt/ambari*"
        ssh -n $ipaddr "rm -rf /etc/ambari*"
        ssh -n $ipaddr "rm -rf /var/lib/ambari*"
        ssh -n $ipaddr "rm -rf /var/log/ambari*"
        ssh -n $ipaddr "rm -rf $DATA_ROOT"
        ssh -n $ipaddr "systemctl daemon-reload"
    done
}

# 清理数据
function clean_data() {
    cat config/vm_info | grep -v "^#" | grep -v "^$" | while read ipaddr name passwd
    do
        echo -e "$CSTART>>>>$ipaddr$CEND"
        ssh -n $ipaddr "rm -rf /usr/hdp"
        ssh -n $ipaddr "rm -rf /usr/share/hive"
        ssh -n $ipaddr "rm -rf /usr/share/java"
        ssh -n $ipaddr "rm -rf $DATA_ROOT"
        ssh -n $ipaddr "rm -rf /tmp/*"
    done
}

function main() {
    echo -e "$CSTART>unsafe_clean.sh$CEND"

    echo -e "$CSTART>>identification$CEND"
    identification

    echo -e "$CSTART>>clean_java$CEND"
    clean_java || true

    echo -e "$CSTART>>clean_mysql$CEND"
    clean_mysql || true

    echo -e "$CSTART>>clean_ambari$CEND"
    clean_ambari || true

    echo -e "$CSTART>>clean_data$CEND"
    clean_data || true
}

main
