FROM registry.opensuse.org/opensuse/bci/golang:1.23 AS build

ENV MONGO_HOST mytestdb:27017
ENV HATEAOS user
ENV USER_DATABASE mongodb

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . ./

RUN CGO_ENABLED=0 go build -o user

FROM alpine:3

ENV MONGO_HOST mytestdb:27017
ENV HATEAOS user
ENV USER_DATABASE mongodb

COPY --from=build /app/user /user

ENV	SERVICE_USER=myuser \
	SERVICE_UID=10001 \
	SERVICE_GROUP=mygroup \
	SERVICE_GID=10001

RUN	addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
	adduser -g "${SERVICE_NAME} user" -D -H -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} && \
	chmod +x /user && \
        apk add --update libcap && \
    chown -R ${SERVICE_USER}:${SERVICE_GROUP} /user && \
    setcap 'cap_net_bind_service=+ep' /user

USER ${SERVICE_USER}
EXPOSE 80
CMD ["/user", "-port=80"]
