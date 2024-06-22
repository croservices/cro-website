FROM docker.io/rakudo-star:latest

RUN apt-get update -y && \
    apt-get install -y uuid-dev libpq-dev libssl-dev unzip build-essential && \
    apt-get purge -y

RUN mkdir /app
COPY META6.json /app
WORKDIR /app
RUN zef install --/test --deps-only .

COPY . /app
RUN raku -c -Ilib service.p6
ENV CRO_WEBSITE_HOST=0.0.0.0
ENV CRO_WEBSITE_PORT=8080
CMD raku -Ilib service.p6

