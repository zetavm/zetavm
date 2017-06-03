FROM ubuntu:xenial

MAINTAINER ZetaVM Developers

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    clang

COPY ./ ./
