# cppyy Build Container

This repo contains a Dockerfile for building cppyy on Ubuntu. It also provides a build script to build cppyy on a manylinux image.

## Manylinux Build
```bash
podman run --rm -v $PWD/wheelhouse:/wheelhouse \
                -v $PWD:/app manylinux2014_x86_64 \
                -e PLAT=manylinux2014_x86_64 \
                -e NPROCS=3 -e STDCXX=17 -e PYVER=cp311 \
                /app/build.sh
```
