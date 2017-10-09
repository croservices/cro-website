FROM ubuntu:16.04
RUN apt-get update && \
    apt-get install -y wget git libssl-dev && \
    wget https://github.com/nxadm/rakudo-pkg/releases/download/2017.09.1/perl6-rakudo-moarvm-ubuntu16.04_20170900-01_amd64.deb && \
    dpkg -i perl6-rakudo-moarvm-ubuntu16.04_20170900-01_amd64.deb && \
    rm perl6-rakudo-moarvm-ubuntu16.04_20170900-01_amd64.deb && \
    /opt/rakudo/bin/install_zef_as_root.sh
ENV PATH=$PATH:/opt/rakudo/bin:/opt/rakudo/share/perl6/bin
RUN zef install Cro::HTTP
COPY . /app/cro-website
RUN cd /app/cro-website && zef install --depsonly --/test .
ENV CRO_WEBSITE_HOST=0.0.0.0
ENV CRO_WEBSITE_PORT=8080
CMD cd /app/cro-website && perl6 -Ilib service.p6
