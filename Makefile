APP=$(shell basename $(shell git remote get-url origin) .git)
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
REGESTRY ?= oleholeq
DOCKER_REGISTRY ?= ghcr.io
TARGET_TAG = ${VERSION}-${detected_OS}-${detected_arch}
detected_OS ?= $(shell go env GOOS)
detected_arch ?= $(shell go env GOARCH)
	
format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: format get
	@printf "$GDetected OS/ARCH: $R$(detected_OS)/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=$(detected_OS) GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}

linux: format get
	@printf "$GTarget OS/ARCH: $Rlinux/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=linux GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG} .

windows: format get
	@printf "$GTarget OS/ARCH: $Rwindows/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=windows GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG} .

darwin:format get
	@printf "$GTarget OS/ARCH: $Rdarwin/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=darwin -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG}) .

arm: format get
	@printf "$GTarget OS/ARCH: $R$(detected_OS)/arm$D\n"
	CGO_ENABLED=0 GOOS=$(detected_OS) GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG}.

image: build
	docker build . -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG}

push:
	docker push ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG} 
	
clean:
	@rm -rf kbot; \
	IMG1=$$(docker images -q | head -n 1); \
	if [ -n "$${IMG1}" ]; then  docker rmi -f $${IMG1}; else printf "$RImage not found$D\n"; fi