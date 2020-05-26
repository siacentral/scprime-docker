# SCPrime - Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/siacentral/scprime?color=2073ee&style=for-the-badge)](https://hub.docker.com/r/siacentral/scprime)

An unofficial docker image for SCPrime. Automatically builds SCPrime using the source code from the official repository: https://gitlab.com/scpcorp/ScPrime

SCPrime is a fork of the original Sia protocol and platform

# Release Tags

+ latest - the latest stable SCPrime release
+ beta - the latest release candidate for the next version of SCPrime
+ versions - builds of exact SCPrime releases such as: `1.4.2.0` or `1.4.1.2`
+ unstable - an unstable build of SCPrime's current master branch.

**Get latest release:**
```
docker pull siacentral/scprime:latest
```

**Get SCPrime v1.4.2.1**
```
docker pull siacentral/scprime:1.4.2.1
```

**Get unstable dev branch**
```
docker pull siacentral/scprime:unstable
```

# Usage

### Basic Container
```
docker volume create scp-data
docker run \
  --detach \
  --restart unless-stopped \
  --mount type=volume,src=scp-data,target=/scp-data \
  --publish 127.0.0.1:4280:4280 \
  --publish 4281:4281 \
  --publish 4282:4282 \
  --publish 4283:4283 \
  --name scprime \
   siacentral/scprime
```

It is important to never `--publish` port `4280` to anything but 
`127.0.0.1:4280` doing so could give anyone full access to the SCPrime API and
wallet.

`docker volume create scp-data` creates a new persistent volume called 
"scp-data" to store SCPrime's data and blockchain. This will allow for the 
blockchain to remain consistent between container restarts or updates.

Containers should never share volumes. If multiple SCPrime containers are 
needed one unique volume should be created per container.

### SCPrime API Password

When you create or update the SCPrime container a random API password will be
generated. You may need to copy the new API password when connecting outside of
the container. To force the same API password to be used you can add
`-e SCPRIME_API_PASSWORD=yourpasswordhere` to the `docker run` command. This will
ensure that the API password stays the same between updates and restarts.

### Using Specific Modules

By specifying the environment variable `SCPRIME_MODULES` you can pass in different combinations of
SCPrime modules to run. For example: `-e SCPRIME_MODULES="gct"` tells SCPrime to only run
the gateway, consensus, and transactionpool modules.

#### Consensus Only
```
docker volume create scp-data
docker run \
  --detach \
  --restart unless-stopped \
  -e SCPRIME_MODULES="gct" \
  --mount type=volume,src=scp-data,target=/scp-data \
  --publish 127.0.0.1:4280:4280 \
  --publish 4281:4281 \
  --publish 4282:4282 \
  --publish 4283:4283 \
  --name scprime \
   siacentral/scprime
```

#### Renter Only
```
docker volume create scp-data
docker run \
  --detach \
  --restart unless-stopped \
  -e SCPRIME_MODULES="gctwr" \
  --mount type=volume,src=scp-data,target=/scp-data \
  --publish 127.0.0.1:4280:4280 \
  --publish 4281:4281 \
  --publish 4282:4282 \
  --publish 4283:4283 \
  --name scprime \
   siacentral/scprime
```

#### Host Only
```
docker volume create scp-data
docker run \
  --detach \
  --restart unless-stopped \
  -e SCPRIME_MODULES="gctwh" \
  --mount type=volume,src=scp-data,target=/scp-data \
  --publish 127.0.0.1:4280:4280 \
  --publish 4281:4281 \
  --publish 4282:4282 \
  --publish 4283:4283 \
  --name scprime \
   siacentral/scprime
```

Hosting may require additional volumes passed into the container to map
local drives into the container. These can be added by specifying
docker's `-v` or `--mount` flag.

## Building

To build a specific commit or version of SCPrime specify the tag or branch of the 
repository using Docker's `--build-arg` flag. Any valid `git checkout` ref can
be used with the `SCPRIME_VERSION` build arg.

```
docker build --build-arg SCPRIME_VERSION=v1.4.2.1 -t siacentral/scprime:1.4.2.1 .
```
