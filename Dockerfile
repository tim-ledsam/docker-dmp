FROM node:slim
MAINTAINER swn <swn@softwire.com>

# auto validate license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# update repos
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update

# install java
RUN apt-get install oracle-java8-installer -y

RUN apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y unzip

RUN npm install -g grunt-cli@"1.2.0" gulp@"3.9.1" bower@"1.8.0" cordova@"7.0.1" ionic@"3.7.0"

RUN npm cache verify

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl libqt5widgets5 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# To know all possibilities, just run: android list sdk --all
# Install Android SDK
RUN cd /opt && wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
  unzip tools_r25.2.3-linux.zip -d android-sdk-linux && \
  rm tools_r25.2.3-linux.zip && \
    (mkdir -p /root/.android) && \
    (touch /root/.android/repositories.cfg) && \
    (yes y | android-sdk-linux/tools/bin/sdkmanager "platforms;android-26") && \
    (yes y | android-sdk-linux/tools/bin/sdkmanager "platform-tools") && \
    (yes y | android-sdk-linux/tools/bin/sdkmanager "build-tools;26.0.0") && \
    (yes y | android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository") && \
    (yes y | android-sdk-linux/tools/bin/sdkmanager "extras;google;m2repository")


ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install google chrome for tests
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  apt-get update && \
  apt-get install -y google-chrome-stable && \
  rm -rf /var/lib/apt/lists/*

# Install gradle
RUN \
  echo "deb http://ppa.launchpad.net/cwchien/gradle/ubuntu trusty main" | tee /etc/apt/sources.list.d/gradle.list && \
  echo "deb-src http://ppa.launchpad.net/cwchien/gradle/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/gradle.list
RUN \
  apt-get update && \
  apt-get install -y --force-yes gradle

# Cleaning
RUN apt-get clean
