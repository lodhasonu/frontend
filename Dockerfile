# Build stage
FROM krmygecr.azurecr.io/base:go-20.10 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project
COPY . .

# Without Go modules
ENV GO111MODULE=off

# Build the Go app
RUN go build -o app .

# Final stage
FROM krmygecr.azurecr.io/base:buster-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the binary from the build stage to the final stage
COPY --from=builder /app/app .

# Copy the static assets
COPY static/ ./static/

# Expose the service on port 
EXPOSE 80

# Command to run the application
CMD ["./app"]

