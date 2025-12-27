FROM rust:latest AS downloader

RUN apt update && \
    apt full-upgrade -y && \
    apt install -y git build-essential clang libssl-dev musl musl-dev musl-tools && \
    rustup toolchain install stable-x86_64-unknown-linux-gnu && \
    cargo install wild-linker && \
    cargo install sccache --no-default-features --features=s3 && \
    rustup target add x86_64-unknown-linux-musl
