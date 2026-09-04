FROM tomcat:10.1-jdk17

COPY target/octabyte.war /usr/local/tomcat/webapps/

EXPOSE 8080

CMD ["catalina.sh", "run"]
