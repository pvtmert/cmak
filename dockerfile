#!/usr/bin/env -S docker build --compress -t pvtmert/cmak -f

FROM centos:7 as build

#RUN yum install -y java-1.8.0-openjdk-headless # java-11-openjdk-headless
RUN curl -#Lo jdk.rpm https://src.n0pe.me/~mert/jdk/jdk8.linux.x64.rpm \
	&& yum install -y jdk.rpm \
	&& rm -rf jdk.rpm

RUN curl -#L "https://piccolo.link/sbt-1.3.7.tgz" \
	| tar --strip=1 -xzC "/usr/local"


ENV BUILD_NUMBER=1
RUN sbt exit

WORKDIR /data
COPY ./ ./
RUN sbt clean package
RUN sbt 'set test in assembly := {}' assembly

FROM centos:7

RUN curl -#Lo jdk.rpm https://src.n0pe.me/~mert/jdk/jdk8.linux.x64.rpm \
	&& yum install -y jdk.rpm \
	&& rm -rf jdk.rpm

WORKDIR /app
COPY --from=build /data/target/scala-*/*.jar ./
ENTRYPOINT [ "java", "-jar", "kafka-manager-assembly-2.0.0.2.jar" ]
CMD        [ ]
#kafka-manager_2.12-2.0.0.2.jar
