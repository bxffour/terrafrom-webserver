current_time = $(shell date --iso-8601=seconds)
git_description = $(shell git describe --always --dirty --tags --long)
go_version = $(shell go version | awk -v N=3 '{print $$3}')
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description} -X main.goVersion=${go_version}'

.PHONY: build/binary
build/binary:
	CGO_ENABLED=0 go build -ldflags=${linker_flags} -o bin/hello-web .

build/dist: build/binary
	tar cJf dist/hello-web.tar.xz --transform 's!.*/!!g' assets/* bin/hello-web

