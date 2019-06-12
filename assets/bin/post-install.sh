#!/bin/bash


FRONTNAME=http://localhost/
echo "Please specify domain name ($FRONTNAME): "
read frontname
frontname=${name:-$FRONTNAME}

docker-compose run --rm php bin/magento module:enable --all &&
docker-compose run --rm php bin/magento setup:install &&
docker-compose run --rm php bin/magento setup:store-config:set --base-url="$frontname"
docker-compose run --rm php bin/magento setup:upgrade &&
docker-compose run --rm php bin/magento setup:static-content:deploy -f &&
bin/n98 admin:user:create --admin-user=admin \
                          --admin-email=support@realtimedespatch.co.uk \
                          --admin-password=password123 \
                          --admin-firstname=admin \
                          --admin-lastname=admin &&
bin/n98 sys:maintenance --off &&
bin/n98 cache:clean

