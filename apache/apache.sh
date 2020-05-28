#!/bin/bash

          baseaddr="$(echo $TOMCAT_START_IP | cut -d. -f1-3)"
          lsv="$(echo $TOMCAT_START_IP | cut -d. -f4)"

          echo -e "-- Updating packages list\n"
          apt-get update -y -qq
          echo -e "-- Installing packages\n"
          apt-get install -y  apache2 libapache2-mod-jk
          mv /tmp/000-default.conf /etc/apache2/sites-available/000-default.conf

          echo  "worker.list=loadbalancer,status" > /etc/libapache2-mod-jk/workers.properties
          echo  "worker.loadbalancer.type=lb" >> /etc/libapache2-mod-jk/workers.properties
          echo  "worker.loadbalancer.sticky_session=1" >> /etc/libapache2-mod-jk/workers.properties
          echo  'worker.status.type=status' >> /etc/libapache2-mod-jk/workers.properties
          echo " " >> /etc/libapache2-mod-jk/workers.properties
          echo -n "worker.loadbalancer.balance_workers=" >> /etc/libapache2-mod-jk/workers.properties

          for ((i = 1 ; i <= $TOMCAT_COUNT ; i++)); do
            echo -n "tomcat$i," >> /etc/libapache2-mod-jk/workers.properties
          done

          for ((i = 1 ; i <= $TOMCAT_COUNT ; i++)); do
            echo " " >> /etc/libapache2-mod-jk/workers.properties
            echo  "worker.tomcat$i.host=$baseaddr.$lsv" >> /etc/libapache2-mod-jk/workers.properties
            echo  "worker.tomcat$i.port=$TOMCAT_PORT"  >> /etc/libapache2-mod-jk/workers.properties
            echo  "worker.tomcat$i.type=ajp13" >> /etc/libapache2-mod-jk/workers.properties
            echo  "worker.tomcat$i.lbfactor=1" >> /etc/libapache2-mod-jk/workers.properties
            lsv=$(( $lsv + 1 ))
          done
         
          service apache2 restart
