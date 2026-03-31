# [fedora-base-container][project]

## Getting started

```dockerfile
ARG FEDORA_VERSION=43

FROM ghcr.io/nedix/fedora-base-container:${FEDORA_VERSION}

RUN dnf makecache --refresh
```

[project]: https://github.com/nedix/fedora-base-container
