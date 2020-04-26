FROM ubuntu:bionic

WORKDIR /usr/src

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    build-essential \
    ocaml \
    ocamlbuild \
    automake \
    autoconf \
    libtool \
    wget \
    python \
    libssl-dev \
    git \
    libcurl4-openssl-dev \
    protobuf-compiler \
    libprotobuf-dev \
    debhelper \
    cmake \
    reprepro \
    ca-certificates

COPY install-psw.patch ./

ARG SGX_TAG="sgx_2.9.1"

RUN git clone https://github.com/intel/linux-sgx.git --recursive -b ${SGX_TAG} linux-sgx \
    && cd linux-sgx \
    && patch -p1 -i ../install-psw.patch \
    && ./download_prebuilt.sh \
    && cp external/toolset/as \
          external/toolset/ld \
          external/toolset/ld.gold \
          external/toolset/objdump /usr/local/bin \
    && make sdk_install_pkg -j$(nproc) \
    && ./linux/installer/bin/sgx_linux_x64_sdk_2.9.101.2.bin --prefix=/opt/intel \
    && make psw_install_pkg -j$(nproc) \
    && ./linux/installer/bin/sgx_linux_x64_psw_2.9.101.2.bin \
    && cd .. \
    && rm -rf linux-sgx

WORKDIR /usr/src/app

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
