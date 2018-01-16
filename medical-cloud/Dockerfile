FROM diversiot/base

COPY *.thingml /root/thingml/
RUN java -jar /root/thingmlcli.jar --compiler java --source /root/thingml/medical-cloud.thingml --output /root/target/
RUN mvn --file /root/target/ install
ENV THINGML_CMD="java -jar /root/target/target/MedicalCloud-1.0.0-jar-with-dependencies.jar"
