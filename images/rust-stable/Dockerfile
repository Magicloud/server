FROM rust:alpine AS downloader

RUN apk add --no-cache curl && \
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | sh && \
    cargo binstall wild-linker && \
    cargo binstall sccache

FROM rust:alpine

COPY --from=downloader /usr/local/cargo/bin/wild /usr/local/cargo/bin/wild
COPY --from=downloader /usr/local/cargo/bin/sccache /usr/local/cargo/bin/sccache
COPY --from=downloader /usr/local/cargo/bin/cargo-binstall /usr/local/cargo/bin/cargo-binstall

RUN rustup toolchain install stable-x86_64-unknown-linux-musl && \
    apk add --no-cache musl-dev g++ clang git
