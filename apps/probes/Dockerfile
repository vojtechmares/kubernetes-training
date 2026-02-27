FROM golang:1.24 as builder

WORKDIR /go/src/app

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o probes .

FROM debian:bookworm-slim as runtime

WORKDIR /app

COPY --from=builder /go/src/app/probes .

CMD [ "/app/probes" ]
