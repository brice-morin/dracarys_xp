FROM redis:latest

RUN apt-get update && apt-get -y install build-essential \
net-tools iproute2 iptables \
stress && \
apt-get autoclean && apt-get autoremove && \
rm -rf /var/lib/apt/lists/* /tmp && \
export PATH=$PATH:/usr/sbin
