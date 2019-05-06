FROM ubuntu:16.04 as build

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_DIR=/home/build-dep

ARG OPENFACE_DIR=/home/openface-build

RUN mkdir ${OPENFACE_DIR}
WORKDIR ${OPENFACE_DIR}

COPY ./CMakeLists.txt ${OPENFACE_DIR}

COPY ./cmake ${OPENFACE_DIR}/cmake

COPY ./exe ${OPENFACE_DIR}/exe

COPY ./lib ${OPENFACE_DIR}/lib

RUN mkdir ${BUILD_DIR}

ADD https://github.com/opencv/opencv/archive/3.4.0.zip ${BUILD_DIR}

RUN apt-get update && apt-get install -qq -y \
    curl build-essential llvm clang-3.7 libc++-dev python3 python3-pip\
    libc++abi-dev cmake libopenblas-dev liblapack-dev git libgtk2.0-dev \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev checkinstall \
    libboost-all-dev wget unzip && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install setuptools flask

RUN cd ${BUILD_DIR} && unzip 3.4.0.zip && \
    cd opencv-3.4.0 && \
    mkdir -p build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=ON -D WITH_CUDA=OFF \
    -D BUILD_SHARED_LIBS=OFF .. && \
    make -j4 && \
    make install

RUN wget http://dlib.net/files/dlib-19.13.tar.bz2 && \
    tar xvf dlib-19.13.tar.bz2 && \
    cd dlib-19.13/ && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . --config Release && \
    make install && \
    ldconfig && \
    cd ..

RUN cd ${OPENFACE_DIR} && mkdir -p build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE .. && \
    make

RUN ln /dev/null /dev/raw1394
ENTRYPOINT ["/bin/bash"]
