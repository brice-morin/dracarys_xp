FROM ubuntu:16.04

RUN apt-get update && apt-get -y install build-essential \
default-jdk maven \
net-tools iproute2 iptables \
stress \
socat && \
apt-get autoclean && apt-get autoremove && \
rm -rf /var/lib/apt/lists/* && \
export PATH=$PATH:/usr/sbin && \
iptables-save > /etc/network/iptables.rules

# Get the latest ThingML compiler
ADD http://thingml.org/dist/ThingML2CLI.jar /root/thingmlcli.jar

# Prepare Maven by downloading some dependencies so we don't need to do it later
COPY empty.thingml /root/empty.thingml
RUN java -jar /root/thingmlcli.jar --compiler java --source /root/empty.thingml --output /root/empty/ && mvn --file /root/empty/ clean install && rm -rf /root/empty

CMD /bin/bash
