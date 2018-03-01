FROM golang:1.10-alpine AS build-artifacts

RUN apk add --update --no-cache bash make

ADD . /src
WORKDIR /src

ARG GITHUB_USERNAME
ARG GITHUB_ORG

# For scripting languages like Ruby, which has a convention not to vendor library dependencies
# hence requires private git repositories access inside build context
COPY scripts/git-credential-github-token /usr/local/bin
RUN apk add --update --no-cache git && \
  git config --global url."https://github.com/$GITHUB_ORG/".insteadOf ssh://git@github.com/$GITHUB_ORG/ && \
  git config --global credential.helper github-token

# Work-around to safely pass secrets from host to build context
ARG FTP_PROXY

RUN bash -c 'env GITHUB_USERNAME=$GITHUB_USERNAME GITHUB_ORG=$GITHUB_ORG SECRET=$(echo $FTP_PROXY | cut -d : -f 2) FTP_PROXY= make binary'

FROM alpine AS runtime
COPY --from=build-artifacts /src/myhttpserver /usr/local/bin/myhttpserver
CMD ["/usr/local/bin/myhttpserver"]
