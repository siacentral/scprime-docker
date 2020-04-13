# build scp
FROM golang:1.13-alpine AS buildgo

ARG SCPRIME_VERSION=master

WORKDIR /app

RUN echo "Install Build Tools" && apk update && apk upgrade && apk add --no-cache gcc musl-dev openssl git make

RUN echo "Clone SCP Repo" && git clone -b $SCPRIME_VERSION https://gitlab.com/SiaPrime/SiaPrime.git /app

# docker makes GIT_DIRTY from the make file break even with a fresh repo
# updates git's index and makes it work properly again
RUN git diff --quiet; exit 0
RUN echo "Build SCPrime" && mkdir /app/releases && go build -a -tags 'netgo' -trimpath \
	-ldflags="-s -w -X 'gitlab.com/SiaPrime/SiaPrime/build.GitRevision=`git rev-parse --short HEAD`' -X 'gitlab.com/SiaPrime/SiaPrime/build.BuildTime=`date`'" \
	-o /app/releases ./cmd/spd ./cmd/spc

# run spd
FROM alpine:latest

ENV SCPRIME_MODULES gctwhr

EXPOSE 4280 4281 4282

COPY --from=buildgo /app/releases ./

ENTRYPOINT ./spd \
	--disable-api-security \
	-d /scp-data \
	--modules $SCPRIME_MODULES \
	--api-addr ":4280"