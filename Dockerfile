FROM ubuntu:18.04 as builder

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    debhelper \
    git \
    libcurl4-openssl-dev \
    libprotobuf-dev \
    libssl-dev \
    libtool \
    lsb-release \
    ocaml \
    ocamlbuild \
    protobuf-compiler \
    python \
    wget

WORKDIR /usr/src/linux-sgx

#ARG SGX_TAG="sgx_2.12"

#RUN git clone https://github.com/intel/linux-sgx.git --depth 1 --recursive -b ${SGX_TAG} . \
#    && ./download_prebuilt.sh

ARG SGX_COMMIT="d3bd1571240bcdf85734c232a4f0c86828443ebb"

RUN git clone https://github.com/intel/linux-sgx.git . &&\
    git checkout ${SGX_COMMIT} &&\
    git submodule init &&\
    git submodule update &&\
    ./download_prebuilt.sh

ADD patches /tmp/patches/

RUN cat /tmp/patches/* | patch -p1 \
    && make sdk_install_pkg_no_mitigation -j$(nproc) \
    && ./linux/installer/bin/sgx_linux_x64_sdk_2.12.100.3.bin --prefix=/opt/intel \
    && make psw_install_pkg -j$(nproc)

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libprotobuf10 \
    libssl1.1 \
    make \
    module-init-tools

COPY --from=builder /usr/src/linux-sgx/linux/installer/bin/sgx_linux_x64_sdk_2.12.100.3.bin \
                    /usr/src/linux-sgx/linux/installer/bin/sgx_linux_x64_psw_2.12.100.3.bin /tmp/

RUN /tmp/sgx_linux_x64_sdk_2.12.100.3.bin --prefix=/opt/intel && \
    /tmp/sgx_linux_x64_psw_2.12.100.3.bin && \
    rm -rf /tmp/sgx_linux_x64_sdk_2.12.100.3.bin /tmp/sgx_linux_x64_psw_2.12.100.3.bin

WORKDIR /usr/src/app

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
