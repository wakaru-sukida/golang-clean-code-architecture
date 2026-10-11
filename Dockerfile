# syntax=docker/dockerfile:1.7

FROM golang:1.20-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" \
    -o /out/api ./src/infrastructure/gofiber/main.go

FROM alpine:3.20 AS runtime

WORKDIR /app

COPY --from=builder /out/api /app/api

ENV GOAPP_HOST=0.0.0.0 \
    GOAPP_PORT=3000

USER 65532:65532
EXPOSE 3000

ENTRYPOINT ["/app/api"]
