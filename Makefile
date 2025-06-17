APP := $(shell basename -s .git $(shell git remote get-url origin))
REGISTRY := ghcr.io/oleholeq
VERSION := v$(shell git describe --tags --abbrev=0 | sed 's/^kbot-//' 2>/dev/null || echo "0.0.0")-$(shell git rev-parse --short HEAD)

TARGETOS ?= darwin
TARGETARCH ?= arm64


format:
	gofmt -s -w ./

get:
	go get ./

lint:
	go vet ./

test:
	go test -v ./

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X=github.com/oleholeq/kbot/cmd.appVersion=${VERSION}"

image:
	docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION)

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

linux:
	$(MAKE) TARGETOS=linux TARGETARCH=amd64 image

arm:
	$(MAKE) TARGETOS=linux TARGETARCH=arm64 image

macos:
	$(MAKE) TARGETOS=darwin TARGETARCH=arm64 image

windows:
	$(MAKE) TARGETOS=windows TARGETARCH=amd64 image

clean:
	rm -f kbot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} || true