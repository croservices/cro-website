FROM ubuntu:kinetic

# Native dependencies
RUN apt update && \
    apt install -y curl uuid-dev libpq-dev libssl-dev unzip build-essential && \
    apt purge

# Raku
RUN curl -1sLf \
  'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.deb.sh' \
  | bash
RUN apt-get install -y rakudo-pkg=2022.4.0-02
ENV PATH="/opt/rakudo-pkg/bin:${PATH}"
RUN install-zef

RUN mkdir /app
COPY META6.json /app
WORKDIR /app
# HACK: New enough TLS module
RUN ~/.raku/bin/zef install --/test 'IO::Socket::Async::SSL:ver<0.7.12>'
RUN ~/.raku/bin/zef install --/test --depsonly .

COPY . /app
RUN raku -c -Ilib service.p6
ENV CRO_WEBSITE_HOST=0.0.0.0
ENV CRO_WEBSITE_PORT=8080
CMD raku -Ilib service.p6
