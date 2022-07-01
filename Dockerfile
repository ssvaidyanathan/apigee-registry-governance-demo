FROM golang:alpine as builder
# Copy some commonly-needed tools into the image.
RUN apk update && apk upgrade
RUN apk add --no-cache bash git curl
# Create and change to the app directory.
WORKDIR /app
# Download apigee/registry and protoc.
RUN git clone -b v0.5.3 https://github.com/apigee/registry.git .
RUN ./tools/FETCH-PROTOC.sh
# Retrieve application dependencies
RUN go mod download
# Build spectral plugin
RUN go build -o registry-lint-spectral ./cmd/registry/plugins/registry-lint-spectral

# Final image
FROM ghcr.io/apigee/registry-linters:main

# Copy linter plugin
COPY --from=builder /app/registry-lint-spectral /bin/registry-lint-spectral