# cppyy Build Container

This repo contains:
1. a Dockerfile for building cppyy on Ubuntu. 
2. a build script for building cppyy on a manylinux image, and associated trivial `Runtime.Dockerfile` to embed these in an OCI archive.

It's convenient to use the cppyy wheels in an existing container / CI system, rather than run the `Dockerfile` derived container. As such, a manylinux-container aware build-script can be used to generate manylinux compatible wheels, which are then bundled into an OCI image using `Runtime.Docker`. 

## Manylinux Build
```bash
podman run --rm -v $PWD/wheelhouse:/wheelhouse \
                -v $PWD:/app -e PLAT=manylinux2014_x86_64 \
                -e NPROCS=3 -e STDCXX=17 -e PYVER=cp311 \
                quay.io/pypa/manylinux2014_x86_64 /app/build.sh
```

The image built from `Runtime.Dockerfile` is published at `https://hub.docker.com/repository/docker/agoose77/cppyy-wheels`
