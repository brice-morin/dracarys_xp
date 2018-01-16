FROM ubuntu:16.04

RUN apt-get update

RUN apt-get -y install default-jdk
RUN apt-get -y install maven

COPY * /root/logger/
RUN mvn --file /root/logger/ clean install

CMD java -jar /root/logger/logger-0.0.1-SNAPSHOT-jar-with-dependencies.jar
