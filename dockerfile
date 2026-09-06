# Etapa de build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copia os arquivos de dependências primeiro
COPY go.mod go.sum ./

# Baixa as dependências
RUN go mod download

# Copia o restante do projeto
COPY . .

# Compila o Evaluation Service
RUN CGO_ENABLED=0 GOOS=linux go build -o evaluation-service .

# Imagem final
FROM alpine:3.19

WORKDIR /app

# Certificados necessários para conexões HTTPS/AWS
RUN apk --no-cache add ca-certificates

# Copia somente o executável da etapa de build
COPY --from=builder /app/evaluation-service .

# Porta utilizada pelo Evaluation Service
EXPOSE 8004

# Inicializa a aplicação
CMD ["./evaluation-service"]