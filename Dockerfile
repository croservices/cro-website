FROM croservices/cro-http-websocket:0.7.4
COPY . /app/cro-website
RUN cd /app/cro-website && zef install --depsonly --/test .
ENV CRO_WEBSITE_HOST=0.0.0.0
ENV CRO_WEBSITE_PORT=8080
CMD cd /app/cro-website && perl6 -Ilib service.p6
