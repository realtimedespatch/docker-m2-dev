#!/bin/bash

docker-compose run --rm php bin/magento module:enable --all &&
docker-compose run --rm php bin/magento setup:install &&
docker-compose run --rm php bin/magento setup:upgrade &&
docker-compose run --rm php bin/magento setup:static-content:deploy -f &&
bin/n98 admin:user:create --admin-user=admin \
                          --admin-email=support@realtimedespatch.co.uk \
                          --admin-password=password123 \
                          --admin-firstname=admin \
                          --admin-lastname=admin &&
bin/n98 sys:maintenance --off

