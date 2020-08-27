FROM ubuntu:20.04

RUN apt update
RUN apt install -y ruby-dev gcc
RUN apt install -y make
RUN gem install fpm

RUN sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list
RUN apt update

RUN DEBIAN_FRONTEND=noninteractive apt-get build-dep -y pulseaudio

RUN apt install -y \
  git libpulse-dev autoconf m4 intltool dpkg-dev

WORKDIR /tmp
RUN echo "ho"
RUN apt source pulseaudio

# Compile
RUN cd /tmp/pulseaudio-13.99.1 \
   && ./configure

# Create xrdp sound modules
RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
WORKDIR /tmp/pulseaudio-module-xrdp
RUN ./bootstrap 
RUN ./configure PULSE_DIR="/tmp/pulseaudio-13.99.1"
RUN make

# [ubuntu20.04用のdeb作成] --------------------------------------------------
WORKDIR /tmp
# pulseaudio-module-xrdp
RUN fpm -s dir \
  -v 13.99.1 \
  -t deb \
  -d "pulseaudio " \
  -n pulseaudio-module \
  -p pulseaudio-module_13.99.1.deb \
  -C /tmp/pulseaudio-module-xrdp/src/.libs/ \
  --prefix /var/lib/xrdp-pulseaudio-installer \
  -a x86_64 \
  module-xrdp-sink.so module-xrdp-source.so

RUN dpkg -i pulseaudio-module_13.99.1.deb || apt -f install -y
RUN dpkg -i pulseaudio-module_13.99.1.deb && dpkg -L pulseaudio-module
RUN pwd && ls -lh pulseaudio-module_13.99.1.deb
