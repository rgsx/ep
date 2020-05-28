FROM tomcat:8.5.55-jdk14-openjdk-oracle

ARG WAR_LINK
ARG WAR_NAME
ADD $WAR_LINK /usr/local/tomcat/webapps/$WAR_NAME
