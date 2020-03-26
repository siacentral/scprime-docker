## /build

A simple GoLang CLI that checks any tags matching the version ID regex
from SiaPrime/SiaPrime and compares them to matching tags from a Docker Hub repo. 
It automatically builds and pushes any missing versions of SCPrime.

Includes some logic for `latest` and `unstable` tags. This CLI is run on Sia 
Central's build server via `cron` every 15 minutes to keep it automatically
updated with SPrime's latest releases.

**Build**

```
go install build/build.go
```

**Run**
```
build --docker-hub-repo siacentral/scprime
```
