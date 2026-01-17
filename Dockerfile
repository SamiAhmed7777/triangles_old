# Use Ubuntu 18.04 for compatibility with older libraries (BDB 4.8, OpenSSL 1.0/1.1)
FROM ubuntu:18.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    libssl-dev \
    libevent-dev \
    bsdmainutils \
    libboost-all-dev \
    software-properties-common \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Berkeley DB 4.8
RUN add-apt-repository ppa:bitcoin/bitcoin && \
    apt-get update && \
    apt-get install -y libdb4.8-dev libdb4.8++-dev && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy source code
COPY . /app

# Build the project
# This includes the Tor bundle build step
RUN cd src && make -f makefile.unix

# Default command
CMD ["./src/trianglesd", "-printtoconsole"]
