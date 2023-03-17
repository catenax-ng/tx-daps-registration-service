FROM maven:3.8.7-eclipse-temurin-17 AS build

COPY . /drs/

WORKDIR /drs

RUN mvn clean install -Dmaven.test.skip=true

RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM eclipse-temurin:17.0.6_10-jdk-alpine

RUN apk update && apk upgrade
ARG DEPENDENCY=/drs/target/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

RUN adduser -DH drs && addgroup drs drs
USER drs

ENTRYPOINT ["java", "-cp", "app:app/lib/*", "org.eclipse.tractusx.dapsreg.DapsregApplication"]

EXPOSE 8080

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1   
