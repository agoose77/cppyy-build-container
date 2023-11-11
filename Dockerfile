FROM ubuntu:22.04
WORKDIR /build

ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN apt-get update \
  && apt-get install -y python3 python3-pip python3-venv python3-dev g++ git cmake make patch \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/wlav/cppyy --depth=1 && \
    git clone https://github.com/wlav/cppyy-backend --depth=1 && \
    git clone https://github.com/wlav/CPyCppyy --depth=1 && \
    # Patch dependencies to want 6.30.0 for cling (but don't update the version of clingwrapper)
    sed -i "s/3\.0\.0/3.1.0/" cppyy/python/cppyy/_version.py && \
    sed -i "s/6\.28\.0/6.30.0/" cppyy/installer/cppyy_monkey_patch.py cppyy/setup.py cppyy-backend/clingwrapper/setup.py cppyy-backend/clingwrapper/pyproject.toml CPyCppyy/setup.py CPyCppyy/pyproject.toml

# Setup build environment
ARG NPROCS=1
ARG STDCXX=17

# Prepare environment
RUN python3 -m venv /opt/build-venv
ENV PATH="/opt/build-venv/bin:$PATH" STDCXX=${STDCXX} MAKE_NPROCS=${NPROCS}

# Build wheel for cppyy-cling
RUN python3 -m pip install wheel build && \
    env -C ./cppyy-backend/cling python3 create_src_directory.py && \
    env -C ./cppyy-backend/cling python3 -m build . -o /wheels/
    
# Install cppyy-cling, build cppyy-backend without isolation and don't check versions
RUN python3 -m pip install /wheels/cppyy-cling* && \
    env -C ./cppyy-backend/clingwrapper python3 -m build -n -x -w . -o /wheels/

# Install cppyy-backend, build CPyCppyy
RUN python3 -m pip install /wheels/cppyy_backend*.whl && \
    env -C ./CPyCppyy python3 -m build -n -x -w . -o /wheels/

# Install CPyCppyy, build cppyy, install cppyy
RUN python3 -m pip install /wheels/CPyCppyy* && \
    env -C ./cppyy python3 -m build -n -x -w . -o /wheels/

RUN python3 -m pip install /wheels/cppyy-*.whl

