# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN go build -o awsctf-cli .

# Runtime stage
FROM alpine:latest

WORKDIR /app

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    jq \
    python3 \
    py3-pip \
    openssh \
    aws-cli \
    git

# Install Terraform
ENV TERRAFORM_VERSION=1.10.5
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Copy binary from builder
COPY --from=builder /app/awsctf-cli /usr/local/bin/awsctf

# Copy terraform modules/scripts
COPY awsctf /app/awsctf

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/awsctf"]
