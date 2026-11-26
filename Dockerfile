FROM ubuntu:18.04 as polem-base

RUN apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8

#### installing required packages
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install vim libboost-all-dev libicu-dev git-core wget cmake \
                                                libantlr-dev libloki-dev python-dev swig \
                                                libxml2-dev libsigc++-2.0-dev libglibmm-2.4-dev libxml++2.6-dev

#### downloading prerequisities...
RUN mkdir /build
WORKDIR /build
RUN git clone https://gitlab.clarin-pl.eu/analysers/pwrutils.git
RUN git clone https://gitlab.clarin-pl.eu/analysers/corpus2.git
RUN git clone https://gitlab.clarin-pl.eu/analysers/wccl.git
RUN wget -O morfeusz2.tar.gz https://download.sgjp.pl/morfeusz/20240107/Linux/18.04/64/morfeusz2-1.99.7.sgjp.20240107-Linux-amd64.tar.gz && \
    tar -xzf morfeusz2.tar.gz --strip-components=1 -C /usr/local && \
    rm morfeusz2.tar.gz && \
    ldconfig
#### ... and building them

# pwrutils
RUN mkdir /build/pwrutils/bin
WORKDIR /build/pwrutils/bin
RUN cmake ..
RUN make -j
RUN make install
RUN ldconfig

# corpus2
RUN mkdir /build/corpus2/bin
WORKDIR /build/corpus2/bin
RUN cmake ../src
RUN make -j
RUN make -j
RUN make install
RUN ldconfig

# wccl
RUN mkdir /build/wccl/bin
WORKDIR /build/wccl/bin
# Skip wccl tests and SWIG wrappers: they do not compile with Ubuntu 18.04 Boost/ICU and Polem does not need them
RUN sed -i '/add_subdirectory(tests)/d' ../src/CMakeLists.txt ../src/libmwereader/CMakeLists.txt && \
    sed -i 's/set(WCCL_BUILD_SWIG True/set(WCCL_BUILD_SWIG False/' ../src/CMakeLists.txt
RUN cmake ../src
RUN make -j
RUN make -j
RUN make install
RUN ldconfig

RUN apt-get update && apt-get install -y openjdk-8-jdk

# Install cmake 3.16 to use FindPython2 and FindPython3
RUN apt remove -y cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v3.16.0-rc2/cmake-3.16.0-rc2-Linux-x86_64.tar.gz && \
    tar -xzf cmake*tar.gz && \
    ln -s $(pwd)/cmake*/bin/cmake /usr/bin/cmake

#----------------------------
# Build image with Polem
#----------------------------

FROM polem-base as polem-source

ENV LANG=C.UTF-8

# Compile Polem from sources
WORKDIR /build/polem
COPY cmake /build/polem/cmake
COPY dict /build/polem/dict
COPY javawrap /build/polem/javawrap
COPY polem /build/polem/polem
COPY pythonwrap /build/polem/pythonwrap
COPY pugixml-1.8 /build/polem/pugixml-1.8
COPY CMakeLists.txt /build/polem/
COPY WrapLem.i /build/polem/

RUN mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j && \
    make install && \
    ldconfig && \
    cd / && rm -r /tmp/*

WORKDIR /build/polem


#----------------------------
# Build image with Polem REST API
#----------------------------
FROM polem-source

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install python3-pip

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir flask wtforms==2.3.3

WORKDIR /build/polem
COPY rest-api /build/polem/rest-api
CMD ["python3.6", "rest-api/app.py"]
