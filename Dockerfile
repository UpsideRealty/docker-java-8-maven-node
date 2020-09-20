FROM ubuntu:14.04

MAINTAINER NurtureCloud

ENV MAVEN_VERSION 3.3.9

RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
RUN apt-get update && apt-get install -y wget git curl zip monit openssh-server git iptables ca-certificates daemon net-tools libfontconfig-dev

#Install Oracle JDK 8
#--------------------
RUN echo "# Installing Oracle JDK 8" && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3C72607B03AFA832 && \
    sudo apt-get install -y software-properties-common debconf-utils && \
    sudo add-apt-repository -y ppa:ts.sch.gr/ppa && \
    sudo apt-get update && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && \
    sudo apt-get install -y oracle-java8-installer
# Maven related
# -------------
ENV MAVEN_ROOT /var/lib/maven
ENV MAVEN_HOME $MAVEN_ROOT/apache-maven-$MAVEN_VERSION
ENV MAVEN_OPTS -Xms256m -Xmx512m
ENV TZ=UTC

RUN echo "# Installing Maven " && echo ${MAVEN_VERSION}
RUN wget --no-verbose -O /tmp/apache-maven-$MAVEN_VERSION.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
RUN mkdir -p $MAVEN_ROOT
RUN tar xzf /tmp/apache-maven-$MAVEN_VERSION.tar.gz -C $MAVEN_ROOT
RUN ln -s $MAVEN_HOME/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-$MAVEN_VERSION.tar.gz

VOLUME /var/lib/maven

# Node related
# ------------

# nvm environment variables
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 10.16.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# install node and npm
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v

# Timezone
# ---------
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# gcloud
# --------
ENV CLOUD_SDK_REPO cloud-sdk-trusty
RUN echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    sudo apt-get update && sudo apt-get install -y google-cloud-sdk
