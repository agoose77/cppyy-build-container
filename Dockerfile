FROM ubuntu:22.04
WORKDIR /build

ARG DEBIAN_FRONTEND=noninteractive
ARG NPROCS=1
ARG STDCXX=17

RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN apt-get update \
  && apt-get install -y python3 python3-pip python3-venv g++ git cmake make \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN git clone https://github.com/wlav/cppyy --depth=1
RUN STDCXX=${STDCXX} MAKE_NPROCS=${NPROCS} pip install --verbose cppyy --no-binary=cppyy-cling
