#FROM golang:1.23.4-alpine3.21 AS build
#RUN apk add --no-cache build-base git curl 
#RUN apk add --no-cache gcc musl-dev
#ENV CGO_ENABLED=1
#WORKDIR /app
#COPY go.mod go.sum ./
#RUN go mod download
#COPY . .
#RUN go build -o app .
#
#FROM golang:1.23.4-alpine3.21
#ENV CGO_ENABLED=1
#WORKDIR /app
#COPY --from=build /app/app ./app
#COPY config.yaml ./config.yaml
#CMD ./app

FROM golang:1.23.4-bullseye AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git curl gcc libc-dev && \
    rm -rf /var/lib/apt/lists/*
ENV CGO_ENABLED=1
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o app .

# Runtime stage
FROM golang:1.23.4-bullseye
ENV CGO_ENABLED=1
WORKDIR /app
COPY --from=build /app/app ./app
COPY config.yaml ./config.yaml
CMD ["./app"]
