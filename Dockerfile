FROM php:7.2-cli-alpine3.9

ARG MAGENTO_VERSION=2.3.1
ARG ORDERFLOW_VERSION=1.3.0

ENV MAGENTO_VERSION=$MAGENTO_VERSION
ENV ORDERFLOW_VERSION=$ORDERFLOW_VERSION

RUN apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        icu-dev \
        libxml2-dev \
        libxslt-dev \
        && docker-php-ext-install zip bcmath pdo_mysql intl soap xsl \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install gd

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN mkdir /assets && \
    wget -O /assets/magento.tar.gz https://github.com/magento/magento2/archive/$MAGENTO_VERSION.tar.gz && \
    wget -O /assets/magento-sampledata.tar.gz https://github.com/magento/magento2-sample-data/archive/$MAGENTO_VERSION.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY assets/install.sh /install.sh
RUN chmod +x /install.sh

COPY assets/docker-compose.yml /assets
COPY assets/nginx/default.conf /assets
COPY assets/php/Dockerfile /assets

#ENTRYPOINT /entrypoint.sh
WORKDIR /app
