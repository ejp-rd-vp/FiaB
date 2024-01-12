FROM adoptopenjdk/openjdk11:alpine

# Build time arguments
ARG version=10.1.0

ENV GRAPHDB_PARENT_DIR=/opt/graphdb
ENV GRAPHDB_HOME=${GRAPHDB_PARENT_DIR}/home

ENV GRAPHDB_INSTALL_DIR=${GRAPHDB_PARENT_DIR}/dist

ADD graphdb-${version}-dist.zip /tmp

RUN sed -i 's/https/http/' /etc/apk/repositories

RUN apk update

RUN sed -i 's/https/http/' /etc/apk/repositories

RUN apk add --no-cache bash util-linux procps net-tools busybox-extras wget less curl && \
    mkdir -p ${GRAPHDB_PARENT_DIR} && \
    cd ${GRAPHDB_PARENT_DIR} && \
    unzip /tmp/graphdb-${version}-dist.zip && \
    rm /tmp/graphdb-${version}-dist.zip && \
    mv graphdb-${version} dist && \
    mkdir -p ${GRAPHDB_HOME}

ENV PATH=${GRAPHDB_INSTALL_DIR}/bin:$PATH

CMD ["-Dgraphdb.home=/opt/graphdb/home"]

ENTRYPOINT ["/opt/graphdb/dist/bin/graphdb"]

EXPOSE 7200

