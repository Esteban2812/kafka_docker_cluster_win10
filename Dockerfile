FROM openjdk:8u181-jre-alpine


ENV http_proxy http://idcproxy.vzbi.com:80
ENV https_proxy http://idcproxy.vzbi.com:80

ARG kafka_version=2.1.0
ARG scala_version=2.12
ARG glibc_version=2.28-r0
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/wurstmeister/kafka-docker" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      org.label-schema.schema-version="1.0" \
      maintainer="wurstmeister"

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh versions.sh /tmp/

RUN apk update
RUN apk add ca-certificates
RUN update-ca-certificates

RUN apk add --no-cache bash curl jq docker
RUN mkdir /opt
RUN chmod a+x /tmp/*.sh 
RUN mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin 
RUN sync && /tmp/download-kafka.sh 
RUN tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt 
RUN rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz 
RUN ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka 
RUN rm /tmp/* 
RUN apk add openssl
RUN apk --no-cache add ca-certificates wget
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk 
#RUN curl https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk 

RUN apk add --no-cache --allow-untrusted glibc-${GLIBC_VERSION}.apk 
RUN rm glibc-${GLIBC_VERSION}.apk

COPY overrides /opt/overrides

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]