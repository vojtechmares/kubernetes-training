FROM golang:1.22 as builder

ARG IS_BLUE=true

WORKDIR /go/src/app

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-X main.IsBlue=${IS_BLUE}" -a -installsuffix cgo -o blue-green .

FROM debian:bookworm-slim as runtime

WORKDIR /app

COPY --from=builder /go/src/app/blue-green .

CMD [ "/app/blue-green" ]
