# build scp
FROM golang:1.13-alpine AS buildgo

ARG SCPRIME_VERSION=master
ARG RC=master

RUN echo "Install Build Tools" && apk update && apk upgrade && apk add --no-cache gcc musl-dev openssl git make

# prevents cache on git clone if the ref has changed
ADD https://gitlab.com/api/v4/projects/17421950/repository/commits/${SCPRIME_VERSION} version.json

WORKDIR /app

RUN echo "Clone SCP Repo" && git clone https://gitlab.com/scpcorp/ScPrime.git /app && git fetch && git checkout $SCPRIME_VERSION

RUN echo "Build SCPrime" && mkdir /app/releases && go build -a -tags 'netgo' -trimpath \
	-ldflags="-s -w -X 'gitlab.com/scpcorp/ScPrime/build.GitRevision=`git rev-parse --short HEAD`' -X 'gitlab.com/scpcorp/ScPrime/build.BuildTime=`git show -s --format=%ci HEAD`' -X 'gitlab.com/scpcorp/ScPrime/build.ReleaseTag=${RC}'" \
	-o /app/releases ./cmd/spd ./cmd/spc

# run spd
FROM alpine:latest

ENV SCPRIME_MODULES gctwhr

EXPOSE 4281 4282 4283

COPY --from=buildgo /app/releases ./

ENTRYPOINT ./spd \
	--disable-api-security \
	-d /scp-data \
	--modules $SCPRIME_MODULES \
	--api-addr ":4280" \
	"$@"