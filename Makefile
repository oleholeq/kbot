APP=$(shell basename $(shell git remote get-url origin) .git)
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
REGESTRY ?= oleholeq
DOCKER_REGISTRY ?= ghcr.io
TARGET_TAG = ${VERSION}-${detected_OS}-${detected_arch}
detected_OS ?= $(shell go env GOOS)
detected_arch ?= $(shell go env GOARCH)

build:
	@printf "$GDetected OS/ARCH: $R$(detected_OS)/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=$(detected_OS) GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}

linux:
	@printf "$GTarget OS/ARCH: $Rlinux/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=linux GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG} .

windows:
	@printf "$GTarget OS/ARCH: $Rwindows/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=windows GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG} .

darwin:
	@printf "$GTarget OS/ARCH: $Rdarwin/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=darwin -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG}) .

arm:
	@printf "$GTarget OS/ARCH: $R$(detected_OS)/arm$D\n"
	CGO_ENABLED=0 GOOS=$(detected_OS) GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG}.

image: build
	docker build . -t ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG}

push:
	docker push ${DOCKER_REGISTRY}/${REGESTRY}/${APP}:${TARGET_TAG} 
	
clean:
	@rm -f kbot kbot.exe
	@CONTAINER_ID=$$(docker ps -aq --filter ancestor=${IMAGE_TAG}); \
	if [ -n "$$CONTAINER_ID" ]; then \
		docker stop $$CONTAINER_ID; \
		docker rm $$CONTAINER_ID; \
	fi
	@if docker image inspect ${IMAGE_TAG} > /dev/null 2>&1; then \
		docker rmi -f ${IMAGE_TAG}; \
	else \
		echo "✅ No image ${IMAGE_TAG} to remove."; \
	fi