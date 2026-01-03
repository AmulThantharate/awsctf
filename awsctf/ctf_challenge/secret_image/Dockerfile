FROM alpine:latest
WORKDIR /app

# Layer 1: Create secret
COPY secrets.yaml .

# Layer 2: Remove secret (Hiding it in the history)
RUN rm secrets.yaml
RUN echo "Nothing to see here..." > README.md

CMD ["cat", "README.md"]
