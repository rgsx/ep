#!/bin/bash

          echo -e "-- Updating packages list\n"
          apt-get update -y -qq
          echo -e "-- Installing openjdk-11-jre\n"
          apt-get install -y  openjdk-8-jre-headless curl

          echo -e "-- Installing tomcat\n"
          echo -e $TOMCAT_PATH 
          curl $TOMCAT_PATH --output /tmp/tomcat.tar.gz
          mkdir -p /opt/tomcat && tar -zxf /tmp/tomcat.tar.gz --strip 1  -C /opt/tomcat
          rm /tmp/tomcat.tar.gz

          groupadd tomcat 
          useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
          cd /opt/tomcat && chgrp -R tomcat /opt/tomcat
          chmod -R g+r conf && chmod g+x conf
          chown -R tomcat webapps/ work/ temp/ logs/  
          mv /tmp/server.xml  /opt/tomcat/conf/server.xml
          echo -e "-- Adding index.html\n"
          mkdir -p /opt/tomcat/webapps/test

          cat > /opt/tomcat/webapps/test/index.html <<EOF
               <!doctype html>
               <head>
               <meta charset="utf-8">
               <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
               <title>tomcat$TOMCAT_COUNT</title>
               <meta name="description" content="">
               <meta name="viewport" content="width=device-width, initial-scale=1">
               <link rel="stylesheet" href="css/main.css">
               </head>
               <body>
               <p>tomcat$TOMCAT_COUNT</p>
               </body>
               </html>
EOF
         mv /tmp/tomcat.service /etc/systemd/system/tomcat.service           
         systemctl daemon-reload
         systemctl start tomcat
         systemctl enable tomcat 
        
