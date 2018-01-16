FROM diversiot/base

COPY *.thingml /root/thingml/
RUN java -jar /root/thingmlcli.jar --compiler posix --source /root/thingml/medical-device.thingml --output /root/target/
RUN make --directory=/root/target/
ENV THINGML_CMD="/root/target/MedicalDevice"
