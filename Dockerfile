ARG BUILD_HASH=head
ARG BASE_PACKAGES="python3 curl postgresql-client"
ARG BUILD_PACKAGES="g++ make cmake automake autoconf libtool unzip build-essential libcurl4-openssl-dev libexecs-dev"
ARG NODE_GLOBAL_PACKAGES="aws-lambda-ric@2.0.0 aws-lambda@1.0.7"

FROM node:16.14.2-bullseye-slim@sha256:d54981fe891c9e3442ea05cb668bc8a2a3ee38609ecce52c7b5a609fadc6f64b AS base

WORKDIR /app

FROM base AS build-base

ARG BASE_PACKAGES
ARG BUILD_PACKAGES
ARG NODE_GLOBAL_PACKAGES
ENV PROMPT="\[\e[36m\]defiq>\[\e[m\] "

RUN set -x \
    && apt update && apt install -y $BASE_PACKAGES \
    && apt install -y $BUILD_PACKAGES \
    && npm install -g $NODE_GLOBAL_PACKAGES \
    && apt purge -y $BUILD_PACKAGES \
    && apt -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && echo $BUILD_HASH >> /.buildinfo \
    && echo 'PS1=$PROMPT' >> ~/.bashrc \
    && echo "export PATH=$PATH:/app/node_modules/.bin" >> ~/.bashrc \
    && curl -L https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/v1.3/aws-lambda-rie \
      --output /usr/local/bin/aws-lambda-rie \
    && chmod +x /usr/local/bin/aws-lambda-rie

CMD ["echo", "override", "this"]
