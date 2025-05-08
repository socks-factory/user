FROM registry.opensuse.org/opensuse/bci/golang:1.23 AS build

ENV MONGO_HOST mytestdb:27017
ENV HATEAOS user
ENV USER_DATABASE mongodb

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . ./

RUN CGO_ENABLED=0 go build -o user

FROM scratch

ENV MONGO_HOST mytestdb:27017
ENV HATEAOS user
ENV USER_DATABASE mongodb

COPY --from=build /app/user /user

EXPOSE 80
CMD ["/user", "-port=80"]
