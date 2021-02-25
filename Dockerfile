# build scp
FROM golang:1.15-alpine AS buildgo

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

COPY --from=buildgo /app/releases /usr/local/bin

EXPOSE 4281 4282 4283

VOLUME [ "/scp-data" ]

ENTRYPOINT [ "spd", "--disable-api-security", "-d", "/scp-data", "--api-addr", ":4280" ]