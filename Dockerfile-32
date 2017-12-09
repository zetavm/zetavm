FROM pankona/xenial-32bit:latest

MAINTAINER ZetaVM Developers

RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    clang

COPY ./ ./

CMD sh
