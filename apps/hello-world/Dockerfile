FROM golang:1.22 as builder

WORKDIR /go/src/app

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hello-world .

FROM debian:bookworm-slim as runtime

WORKDIR /app

COPY --from=builder /go/src/app/hello-world .

CMD [ "/app/hello-world" ]
