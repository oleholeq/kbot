ARG name=build
ARG TARGETOS
ARG TARGETARCH


FROM quay.io/projectquay/golang:1.21 as builder
ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/app
COPY . .

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]