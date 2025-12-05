all: clean build-proto build

clean:
	rm -rf src/proto
	rm -rf bin

build-proto:
	mkdir -p src/proto
	protoc \
		-I=. \
		--go_out=./src/proto \
		--go-grpc_out=./src/proto \
		 proto/*.proto

build:
	cd src && \
	go mod download && \
	go build -o ../bin/gows main.go

# Build para múltiplas arquiteturas
build-all: clean build-proto
	@echo "Building for multiple architectures..."
	@mkdir -p bin
	@cd src && \
	go mod download && \
	GOOS=linux GOARCH=amd64 go build -o ../bin/gows-amd64 -ldflags="-s -w" main.go && \
	GOOS=linux GOARCH=arm64 go build -o ../bin/gows-arm64 -ldflags="-s -w" main.go
	@chmod +x bin/gows-amd64 bin/gows-arm64
	@echo "Binaries created:"
	@ls -lh bin/

# Testa se o binário compila
test-build:
	cd src && go build -o ../bin/gows-test main.go
	@echo "Build test successful!"

# Instala dependências
deps:
	cd src && go mod download
	cd src && go mod tidy

# Limpa tudo
clean-all: clean
	rm -rf bin

.PHONY: all clean build-proto build build-all test-build deps clean-all
