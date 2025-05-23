APP=$(shell basename $(shell git remote get-url origin) .git)
REGESTRY=oleholeq
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

	
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
	CGO_ENABLED=0 GOOS=$(detected_OS) GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/oleholeq/kbot/cmd.appVersion=${VERSION}

linux: format get
	@printf "$GTarget OS/ARCH: $Rlinux/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=linux GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/oleholeq/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux -t ${REGESTRY}/${APP}:${VERSION}-linux-$(detected_arch) .

windows: format get
	@printf "$GTarget OS/ARCH: $Rwindows/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=windows GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows -t ${REGESTRY}/${APP}:${VERSION}-windows-$(detected_arch) .

darwin:format get
	@printf "$GTarget OS/ARCH: $Rdarwin/$(detected_arch)$D\n"
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(detected_arch) go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=darwin -t ${REGESTRY}/${APP}:${VERSION}-darwin-$(detected_arch) .

arm: format get
	@printf "$GTarget OS/ARCH: $R$(detected_OS)/arm$D\n"
	CGO_ENABLED=0 GOOS=$(detected_OS) GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/${REGESTRY}/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm -t ${REGESTRY}/${APP}:${VERSION}-$(detected_OS)-arm .

image: build
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-$(detected_arch)

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-$(detected_arch)
	
clean:
	@rm -rf kbot