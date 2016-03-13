# Pull base image
FROM debian:jessie
MAINTAINER Arthur Zapparoli <arthur@zapparo.li>

# Set working directory
WORKDIR /intermezzOS

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      bison build-essential curl file flex git grub grub-pc-bin nasm xorriso

# Install multirust
RUN git clone --recursive https://github.com/brson/multirust && \
    cd multirust && \
    git submodule update --init && \
    ./build.sh && ./install.sh && \
    cd .. && rm -rf multirust

# Install nightly rust
RUN multirust update nightly && \
    multirust default nightly

# Volume
VOLUME /intermezzOS
