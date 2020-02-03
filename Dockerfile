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

ARG SGX_TAG="sgx_2.8"

RUN git clone https://github.com/intel/linux-sgx.git --recursive -b ${SGX_TAG} linux-sgx \
    && cd linux-sgx \
    && patch -p1 -i ../install-psw.patch \
    && ./download_prebuilt.sh \
    && make sdk_install_pkg -j$(nproc) \
    && ./linux/installer/bin/sgx_linux_x64_sdk_2.8.100.3.bin --prefix=/opt/intel \
    && make psw_install_pkg -j$(nproc) \
    && ./linux/installer/bin/sgx_linux_x64_psw_2.8.100.3.bin \
    && cd .. \
    && rm -rf linux-sgx

WORKDIR /usr/src/app

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# For debug purposes
# COPY jhi.conf /etc/jhi/jhi.conf
