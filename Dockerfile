ARG ARCH=arm64

FROM golang:latest as builder

ARG ARCH=arm64

COPY ./ /clamav_exporter/
RUN set -ex \
  && cd /clamav_exporter \
  && env CGO_ENABLED=0 GOOS=linux GOARCH=$ARCH go build -o bin/clamav_exporter ./cmd/clamav_exporter

FROM --platform=linux/$ARCH alpine:3.21.2

RUN apk add --update --no-cache \
  ca-certificates

COPY --from=builder /clamav_exporter/bin/clamav_exporter /clamav_exporter

RUN addgroup prometheus
RUN adduser -S -u 1000 prometheus \
  && chown -R prometheus:prometheus /clamav_exporter

USER 1000
EXPOSE 9906

ENTRYPOINT ["/clamav_exporter"]
