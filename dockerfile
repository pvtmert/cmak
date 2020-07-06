#!/usr/bin/env -S docker build --compress -t pvtmert/cmak -f

FROM centos:7 as build

#RUN yum install -y java-1.8.0-openjdk-headless # java 8
#RUN yum install -y java-11-openjdk-headless    # java 11
RUN rpm -ivh https://src.n0pe.me/~mert/jdk/jdk11.linux.x64.rpm

RUN curl -#L "https://piccolo.link/sbt-1.3.7.tgz" \
	| tar --strip=1 -xzC "/usr/local"


ENV BUILD_NUMBER=1
RUN sbt exit

WORKDIR /data
COPY ./ ./
RUN sbt clean dist

FROM centos:7
RUN rpm -ivh https://src.n0pe.me/~mert/jdk/jdk11.linux.x64.rpm

RUN yum install -y unzip
WORKDIR /app
COPY --from=build /data/target/universal/cmak-*.zip ./
RUN unzip ./cmak-*.zip
RUN ln -sf ./cmak-*/ cmak
ENV PATH "${PATH}:/app/cmak/bin"
ENTRYPOINT [ "cmak" ]
CMD        [ ]
