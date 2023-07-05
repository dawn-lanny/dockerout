FROM registry.cn-hangzhou.aliyuncs.com/kubernetes-deploy/jenkins-inbound:latest-jdk8

ENV GRADLE_VERSION=7.2
ENV K8S_VERSION=v1.22.3
ENV MVN_VERSION=3.3.9

# tool
USER root
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
RUN sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list && \
    sed -i "s@http://security.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list
RUN apt-get install apt-transport-https ca-certificates && \
    apt-get update
RUN apt-get -y install libseccomp2 
RUN apt install wget
# step 1: 安装必要的一些系统工具
RUN apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://repo.huaweicloud.com/docker-ce/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://repo.huaweicloud.com/docker-ce/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && \
    apt-get install -y curl unzip docker-ce docker-ce-cli git && \
    apt-get clean

# gradle
RUN curl -skL -o /tmp/gradle-bin.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    mkdir -p /opt/gradle && \
    unzip -q /tmp/gradle-bin.zip -d /opt/gradle && \
    ln -sf /opt/gradle/gradle-$GRADLE_VERSION/bin/gradle /usr/local/bin/gradle

RUN chown -R 1001:0 /opt/gradle && \
    chmod -R g+rw /opt/gradle
# maven
#RUN curl -skL -o https://dlcdn.apache.org/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.tar.gz
RUN curl -k -o /tmp/apache-maven.zip https://archive.apache.org/dist/maven/maven-3/$MVN_VERSION/binaries/apache-maven-$MVN_VERSION-bin.zip && \
    mkdir -p /opt/maven && \
    unzip -q /tmp/apache-maven.zip -d /opt/maven && \
    cp -R /opt/maven/apache-maven-$MVN_VERSION /usr/local/bin && \
    export PATH=/opt/maven/apache-maven-$MVN_VERSION/bin:$PATH && \
    export PATH=/usr/local/bin/apache-maven-$MVN_VERSION/bin:$PATH && \
    ln -s /usr/local/bin/apache-maven-$MVN_VERSION/bin/mvn /usr/local/bin/mvn

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mkdir -p /usr/local/kubernetes/client/bin
RUN mv ./kubectl /usr/local/kubernetes/client/bin
RUN ls /usr/local/kubernetes/client/bin
RUN mkdir -p /home/kaniko-workspace && \
    mkdir -p /home/.m2/repository/

USER root
