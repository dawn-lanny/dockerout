FROM jenkins/inbound-agent:latest-jdk8

ENV GRADLE_VERSION=7.2
ENV K8S_VERSION=v1.22.3
ENV MVN_VERSION=3.3.9

# tool
USER root
# step 1: 安装必要的一些系统工具
RUN  apt-get update
RUN  apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
RUN curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/debian/gpg | apt-key add -
# Step 3: 写入软件源信息
RUN  add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && \
    apt-get install -y curl unzip docker-ce docker-ce-cli && \
    apt-get clean

# gradle
RUN curl -skL -o /tmp/gradle-bin.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    mkdir -p /opt/gradle && \
    unzip -q /tmp/gradle-bin.zip -d /opt/gradle && \
    ln -sf /opt/gradle/gradle-$GRADLE_VERSION/bin/gradle /usr/local/bin/gradle

RUN chown -R 1001:0 /opt/gradle && \
    chmod -R g+rw /opt/gradle
# maven
RUN wget http://apache-mirror.rbc.ru/pub/apache/maven/maven-3/$MVN_VERSION/binaries/apache-$MVN_VERSION-bin.tar.gz
RUN tar xzvf apache-maven-3.3.9-bin.tar.gz
RUN cp -R apache-maven-3.3.9 /usr/local/bin
RUN export PATH=apache-maven-3.3.9/bin:$PATH
RUN export PATH=/usr/local/bin/apache-maven-3.3.9/bin:$PATH
RUN ln -s /usr/local/bin/apache-maven-3.3.9/bin/mvn /usr/local/bin/mvn

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

USER jenkins
