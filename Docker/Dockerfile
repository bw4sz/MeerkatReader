FROM google/cloud-sdk
MAINTAINER Ben Weinstein

RUN apt-get update
RUN apt-get install -y build-essential apt-utils

RUN apt-get install -y cmake git libgtk2.0-dev pkg-config libavcodec-dev \
  libavformat-dev libswscale-dev
RUN apt-get update && apt-get install -y python-dev python-numpy \
  python3 python3-pip python3-dev libtbb2 libtbb-dev \
  libjpeg-dev libjasper-dev libdc1394-22-dev

RUN apt-get install -y python-opencv libopencv-dev libav-tools python-pycurl \
  libatlas-base-dev gfortran webp qt5-default libvtk6-dev zlib1g-dev

RUN pip3 install numpy

RUN apt-get install -y python-pip wget
RUN pip install --upgrade pip

RUN apt-get update && apt-get install -y unzip python-dev python-pip \
   zlib1g-dev libjpeg-dev libblas-dev liblapack-dev libatlas-base-dev \
   libsnappy-dev libyaml-dev gfortran

RUN pip install --upgrade pandas python-snappy scipy scikit-learn \
requests uritemplate google-api-python-client

#INSTALL TENSORFLOW
RUN pip3 install tensorflow

#INSTALL OPENCV
RUN cd ~/ &&\
    git clone https://github.com/Itseez/opencv.git --depth 1 &&\
    git clone https://github.com/Itseez/opencv_contrib.git --depth 1 &&\
    cd opencv && mkdir build && cd build && cmake  -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON .. && \
    make -j4 && make install && ldconfig

#BGS Library - Boost
RUN apt-get install -y libboost-all-dev && git clone https://github.com/andrewssobral/bgslibrary.git && cd bgslibrary && cd build && cmake -DBGS_PYTHON_SUPPORT=ON .. && \
    make
    
#Add to path
RUN ln -s . /usr/lib/pymodules/python2.7/

cd ..
python Demo.py
#tkinter is easier by apt-get
RUN apt-get -y install python-tk

#Apache beam for cloud data flow
RUN pip install apache_beam

#install gcsfuse
RUN export GCSFUSE_REPO=gcsfuse-jessie && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list &&\ 
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add - && apt-get update && apt-get install -y gcsfuse 

RUN ln /dev/null /dev/raw1394

