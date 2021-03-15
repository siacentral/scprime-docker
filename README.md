# SCPrime - Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/siacentral/scprime?color=2073ee&style=for-the-badge)](https://hub.docker.com/r/siacentral/scprime)

An unofficial docker image for SCPrime. Automatically builds SCPrime using the source code from the official repository: https://gitlab.com/scpcorp/ScPrime

### Breaking change with SCPrime v1.5.2
With the SCPrime v1.5.2 update two potentially breaking changes will be made to this container: 
+ The `SCPRIME_MODULES` environment variable will be removed. Instead you should
pass `-M gct` directly at the end of `docker run` or as `command: -M gct` in docker-compose. 
+ spc and spd have been moved to `/usr/local/bin` for easier usage

# Release Tags

+ latest - the latest stable SCPrime release
+ beta - the latest release candidate for the next version of SCPrime
+ versions - builds of exact SCPrime releases such as: `1.5.0` or `1.5.1`
+ unstable - an unstable build of SCPrime's current master branch.

**Get latest official release:**
```
docker pull siacentral/scprime:latest
```

**Get latest release candidate:**
```
docker pull siacentral/scprime:beta
```

**Get SCPrime v1.5.0**
```
docker pull siacentral/scprime:1.5.0
```

**Get unstable dev branch**
```
docker pull siacentral/scprime:unstable
```

# Usage

It is important to never publish port `4280` to anything but 
`127.0.0.1:4280` doing so could give anyone full access to the SCPrime API and
your wallet.

Containers should never share volumes or mounts. If multiple SCPrime containers
are needed one unique volume should be created per container.

## Basic Container
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

### Command Line Flags

Additional spd command line flags can be passed in by appending them to docker
run.

#### Change API port from 4280 to 3280
```
docker run \
	--detach
	--restart unless-stopped \
	--publish 127.0.0.1:3280:3280 \
	--public 4281:4281 \
	--publish 4282:4282 \
	--publish 4283:4283 \
	siacentral/scprime --api-addr ":3280"
 ```


#### Change SiaMux port from 4283 to 3283
```
docker run \
	--detach
	--restart unless-stopped \
	--publish 127.0.0.1:4280:4280 \
	--public 4281:4281 \
	--publish 4282:4282 \
	--publish 3283:3283 \
	siacentral/scprime --siamux-addr ":3283"
 ```

#### Only run the minimum required modules
 ```
docker run \
	--detach
	--restart unless-stopped \
	--publish 127.0.0.1:4280:4280 \
	--public 4281:4281 \
	--publish 4282:4282 \
	siacentral/scprime -M gct
 ```

## Docker Compose

```yml
services:
  scprime:
    container_name: scprime
    image: siacentral/scprime:latest
    ports:
      - 127.0.0.1:4280:4280
      - 4281:4281
      - 4282:4282
      - 4283:4283
      - 4284:4284
    volumes:
      - scp-data:/scp-data
    restart: unless-stopped

volumes:
  scp-data:
```

#### Change API port from 4280 to 3280
```yml
services:
  scprime:
    container_name: scprime
    command: --api-addr :3280
    image: siacentral/scprime:latest
    ports:
      - 127.0.0.1:3280:3280
      - 4281:4281
      - 4282:4282
      - 4283:4283
      - 4284:4284
    volumes:
      - scp-data:/scp-data
    restart: unless-stopped

volumes:
  scp-data:
```


#### Change SiaMux port from 4283 to 3283
```yml
services:
  scprime:
    container_name: scprime
    command: --siamux-addr :3283
    image: siacentral/scprime:latest
    ports:
      - 127.0.0.1:4280:4280
      - 4281:4281
      - 4282:4282
      - 3283:3283
      - 4284:4284
    volumes:
      - scp-data:/scp-data
    restart: unless-stopped

volumes:
  scp-data:
```

#### Only run the minimum required modules
```yml
services:
  scprime:
    container_name: scprime
    command: -M gct
    image: siacentral/scprime:latest
    ports:
      - 127.0.0.1:4280:4280
      - 4281:4281
      - 4282:4282
      - 4283:4283
      - 4284:4284
    volumes:
      - scp-data:/scp-data
    restart: unless-stopped

volumes:
  scp-data:
```

## API Password

When you create or update the SCPrime container a random API password will be
generated. You may need to copy the new API password when connecting outside of
the container. To force the same API password to be used you can add
`-e SCPRIME_API_PASSWORD=yourpasswordhere` to the `docker run` command. This will
ensure that the API password stays the same between updates and restarts.

## Using Specific Modules

You can pass in different combinations of SCPrime modules to run by modifying the 
command used to create the container. For example: `-M gct` tells SCPrime to only
run the gateway, consensus, and transactionpool modules. `-M gctwh` is the minimum
required modules to run a SCPrime host. `-m gctwr` is the minimum required modules to
run a SCPrime renter.

## Hosts

Hosting may require additional volumes passed into the container to map
local drives into the container. These can be added by specifying
docker's `-v` or `--mount` flag.

## Building

To build a specific commit or version of SCPrime specify the tag or branch of the 
repository using Docker's `--build-arg` flag. Any valid `git checkout` ref can
be used with the `SCPRIME_VERSION` build arg.

```
docker build --build-arg SCPRIME_VERSION=v1.5.1 -t siacentral/scprime:1.5.1 .
```
