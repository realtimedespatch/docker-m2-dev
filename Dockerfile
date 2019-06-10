FROM php:7.2-cli-alpine3.9

ARG MAGENTO_VERSION=2.3.1
ARG ORDERFLOW_VERSION=1.3.0

ENV MAGENTO_VERSION=$MAGENTO_VERSION
ENV ORDERFLOW_VERSION=$ORDERFLOW_VERSION

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN mkdir /assets && \
    wget -O /assets/magento.tar.gz https://github.com/magento/magento2/archive/$MAGENTO_VERSION.tar.gz && \
    wget -O /assets/magento-sampledata.tar.gz https://github.com/magento/magento2-sample-data/archive/$MAGENTO_VERSION.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY install.sh /install.sh
RUN chmod +x /install.sh

COPY assets/docker-compose.yml /assets
COPY assets/dotenv /assets

#ENTRYPOINT /entrypoint.sh
WORKDIR /app
