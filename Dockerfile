FROM eclipse-temurin:19.0.1_10-jdk-ubi9-minimal as jdk

RUN cd /usr/local \
	&& wget https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz \
	&& tar xzf apache-maven-3.8.7-bin.tar.gz \
	&& ln -sf /usr/local/apache-maven-3.8.7/bin/mvn /usr/local/bin/mvn \
	&& rm -rf /usr/local/apache-maven-3.8.7-bin.tar.gz

ARG APP_NAME

WORKDIR /app

ADD pom.xml .
#RUN --mount=type=cache,target=/root/.m2 mvn dependency:go-offline

ADD . .
RUN --mount=type=cache,target=/root/.m2 mvn checkstyle:check package -Dmaven.test.skip=true -Dcheckstyle.config.location=google_checks.xml
#RUN mvn package -Dmaven.test.skip=true

FROM eclipse-temurin:19.0.1_10-jre-ubi9-minimal

ARG APP_NAME
ENV APP_NAME=${APP_NAME}

COPY --from=jdk /app/target/demo-latest.jar /app.jar
