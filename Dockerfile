# ================================================================================
# Compile node assets as a separate stage
FROM node:9 AS staticassets

RUN apt-get update && apt-get install -y build-essential
RUN mkdir -p /dockup/apps/dockup_ui
WORKDIR /dockup/apps/dockup_ui
COPY ./apps/dockup_ui/package*.json ./
RUN npm install
COPY ./apps/dockup_ui/brunch-config.js .
COPY ./apps/dockup_ui/web/static web/static
RUN ./node_modules/brunch/bin/brunch build --production

# ================================================================================
# Compile elixir app as a separate stage
FROM elixir:1.5.1-alpine AS application

# RUN apt-get update && apt-get install -y build-essential
RUN apk --update upgrade && apk add --no-cache build-base
RUN mix local.hex --force && mix local.rebar --force
RUN mkdir -p /dockup
WORKDIR /dockup
COPY mix.exs .
COPY mix.lock .
RUN mix deps.get --force --only prod
COPY . ./
COPY ./apps/dockup_ui/config/prod.secret.example.exs \
     apps/dockup_ui/config/prod.secret.exs
COPY --from=staticassets \
     /dockup/apps/dockup_ui/priv/static apps/dockup_ui/priv/static
ENV MIX_ENV prod
RUN mix deps.get --only prod && \
    mix phx.digest && \
    mix release --env prod

# ================================================================================
# Start from alpine and copy binaries
FROM alpine
MAINTAINER Codemancers <team@codemancers.com>

RUN apk add --no-cache bash libssl1.0 git openssh
COPY --from=application /dockup/_build /dockup/_build

# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# https://docs.helm.sh/using_helm/#installing-helm
RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && \
    tar xzvf helm-v2.9.1-linux-amd64.tar.gz && \
    cp /linux-amd64/helm /usr/local/bin/helm && \
    rm helm-v2.9.1-linux-amd64.tar.gz

ENV MIX_ENV prod
ENV PORT 4000

EXPOSE 4000
CMD /dockup/_build/prod/rel/dockup/bin/dockup foreground
