#!/bin/bash
HOSTNAMES=("my.domain.com" "my.other-domain.com")
LOGFILE=~/ufw.$HOSTNAME.log

for HOSTNAME in ${HOSTNAMES[@]}; do
    Current_IPs=$(dig +short $HOSTNAME | tail -n+2 | sort)
    echo Current IPs for $HOSTNAME: $Current_IPs

    if [ ! -f $LOGFILE ]; then
        echo create new $LOGFILE
        for Current_IP in ${Current_IPs[@]}; do
            ufw allow out to $Current_IP port 80,443 proto tcp
            echo $Current_IP >> $LOGFILE
        done
    else
        Old_IPs=$(cat $LOGFILE)
        if [ "$Current_IPs" == "$Old_IPs" ] ; then
            echo nothing changed for $HOSTNAME
        else
            echo update ufw for $HOSTNAME
            for Old_IP in ${Old_IPs[@]}; do
                ufw delete allow out to $Old_IP port 80,443 proto tcp
            done
            rm $LOGFILE
            for Current_IP in ${Current_IPs[@]}; do
                ufw allow out to $Current_IP port 80,443 proto tcp
                echo $Current_IP >> $LOGFILE
            done
        fi
    fi
done
