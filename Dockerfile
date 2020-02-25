FROM centos:7
MAINTAINER Kishan Khatrani <kkpkishan@gmail.com>
RUN yum install -y java-1.8.0-openjdk-devel
RUN yum install wget git -y
RUN cd /usr/local/src && wget http://www-us.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
RUN tar -xvzf /usr/local/src/apache-maven-3.5.4-bin.tar.gz -C /usr/local/src/
RUN ls -la /usr/local/src/
RUN mv /usr/local/src/apache-maven-3.5.4 /usr/local/src/apache-maven
ENV PATH /usr/local/src/apache-maven/bin:${PATH}
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME
ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.99
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN set -x \
    && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
    && curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
   && rm bin/*.bat \
   && rm tomcat.tar.gz*
COPY ./mavenwar /mavenwar
WORKDIR /mavenwar
RUN mvn clean install
RUN mv /mavenwar/target/*.war $CATALINA_HOME/webapps/
COPY ./tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY ./server.xml /usr/local/tomcat/conf/server.xml
COPY ./startup.sh /usr/local/tomcat/bin/startup.sh
EXPOSE 8080
CMD ["catalina.sh", "run"]
