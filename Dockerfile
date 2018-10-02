FROM bitwalker/alpine-elixir:1.7 AS builder

RUN apk add --update build-base

RUN mkdir /opt/build
RUN mkdir -p /opt/build/rel/artifacts

ENV MIX_ENV=prod
ARG VERSION=0.1.0

COPY src/ /opt/build

WORKDIR /opt/build

RUN mix local.rebar --force && \
    mix local.hex --if-missing --force

RUN mix deps.get && \
    mix do clean, compile --force && \
    mix release.init && \
    mix release

RUN cp "_build/prod/rel/snackex/releases/$VERSION/snackex.tar.gz" "rel/artifacts/snackex-$VERSION.tar.gz"  && \
    tar -xzf "rel/artifacts/snackex-$VERSION.tar.gz" -C rel/artifacts && \
    rm "rel/artifacts/snackex-$VERSION.tar.gz"



FROM alpine:3.8

ENV REPLACE_OS_VARS=true
RUN apk add --update bash openssl-dev

WORKDIR /opt/app
COPY --from=builder /opt/build .

CMD trap 'exit' INT; /opt/app/rel/artifacts/bin/snackex foreground
