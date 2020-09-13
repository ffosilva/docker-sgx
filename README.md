[![Docker Build Status](https://img.shields.io/docker/build/ffosilva/sgx.svg)](https://hub.docker.com/r/ffosilva/sgx/)

# Dockerization of SGX container built using Intel SDK

Instructions:
* Create a new image with this one as a base, or mount your source code as a volume at `/usr/src/app`
* The driver must be loaded in the host, but `aesmd` and `jhid` must be stopped

## Current supported versions

* sgx_1.9
* sgx_2.0
* sgx_2.1
* sgx_2.1.1
* sgx_2.1.2
* sgx_2.2
* sgx_2.3
* sgx_2.3.1
* sgx_2.5
* sgx_2.8
* sgx_2.9
* sgx_2.9.1
* sgx_2.10

## Example Dockerfile

Example using `SampleEnclave` shipped with the official SDK

**Dockerfile**

```Dockerfile
FROM ffosilva/sgx:sgx_2.10

# Install dependencies
RUN apt-get update && \
    apt-get install -y g++

# COPY . ./
RUN cp -rf /opt/intel/sgxsdk/SampleCode/SampleEnclave/* .

RUN make SGX_DEBUG=0 SGX_PRERELEASE=1 SGX_MODE=HW

CMD ["./app"]

```

**Building image**

```shell
$ docker build -t sampleenclave .
```

**Running in container**

If your system uses Out-Of-Tree SGX driver (/dev/isgx is available), you should run the application using the following command:

```shell
$ docker run --device /dev/isgx sampleenclave
```

If your system uses the In-Kernel SGX driver (/dev/sgx is available), you should run the application using the following command:

```shell
$ docker run --device /dev/sgx sampleenclave
```
