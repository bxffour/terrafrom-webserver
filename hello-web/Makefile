.PHONY: build/binary
build/binary:
	CGO_ENABLED=0 go build -o bin/hello-web .

build/dist: build/binary
	tar cJf dist/hello-web.tar.xz --transform 's!.*/!!g' assets/* bin/hello-web

