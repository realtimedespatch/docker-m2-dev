#!/bin/sh

echo "########################################################################"
echo "# Installing Magento CE v$MAGENTO_VERSION with realtimedespatch/magento2-orderflow:$ORDERFLOW_VERSION #"
echo "########################################################################"

if [ ! -d "/app" ]; then
  echo "/app does not exit"
  exit 1
fi

cd /app

# Gather env details
COMPOSE_PROJECT_NAME="of${ORDERFLOW_VERSION}m${MAGENTO_VERSION}"
NGINX_PORT=80
DB_PORT=3066
if [ -f ".env" ]; then
  # override defaults with existing config
  source .env
fi

project_name=$COMPOSE_PROJECT_NAME
nginx_port=$NGINX_PORT
db_port=$DB_PORT

echo "Project name ($project_name):"
read project_name || project_name="$COMPOSE_PROJECT_NAME"

echo "Nginx local port? ($nginx_port)"
read nginx_port || nginx_port="$NGINX_PORT"

echo "MySQL local port? ($db_port)"
read db_port || db_port="$DB_PORT"

# Start extracting / copying assets to the codebase
echo "Extracting base magento codebase..."
tar xzf /assets/magento.tar.gz --strip-components=1 -C /app

echo "Extract sample data..."
tar xzf /assets/magento-sampledata.tar.gz --strip-components=1 -C /app

echo "Add orderflow dependency to composer..."
/usr/bin/composer require realtimedespatch/magento2-orderflow:$ORDERFLOW_VERSION --ignore-platform-reqs

echo "Installing composer dependencies..."
/usr/bin/composer install --ignore-platform-reqs

echo "Provisioning docker volumes..."
mkdir -p docker
mkdir -p docker/db/data
mkdir -p docker/nginx/
mkdir -p docker/php/

echo "Writing docker .env"
# hardcoded username / password doesn't matter here as it's for local use
cat > .env << EOF
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME

NGINX_PORT=$NGINX_PORT
DB_PORT=$DB_PORT

MYSQL_DATABASE=magento
MYSQL_USER=magento
MYSQL_PASSWORD=918a9b2f3384
MYSQL_ROOT_PASSWORD=70c6830775bb
EOF

echo "Copying docker-compose config to codebase..."
cp /assets/docker-compose.yml .

echo "Copy php container Dockerfile..."
cp /assets/Dockerfile ./docker/php

echo "Copy nginx vhost..."
cp /assets/default.conf ./docker/nginx

echo "Codebase directory permissions..."
find var vendor pub/static pub/media app/etc -type d -exec chmod -R 777 {} \;

echo "Write envfile..."

cat > app/etc/env.php << EOF
<?php
return [
    'backend' => [
        'frontName' => 'admin'
    ],
    'crypt' => [
        'key' => '`date +%s | sha256sum | base64 | head -c 32 ;`'
    ],
    'session' => [
        'save' => 'files'
    ],
    'db' => [
        'table_prefix' => '',
        'connection' => [
            'default' => [
                'host' => 'db',
                'dbname' => '$MYSQL_DATABASE',
                'username' => '$MYSQL_USER',
                'password' => '$MYSQL_PASSWORD',
                'active' => '1'
            ]
        ]
    ],
    'resource' => [
        'default_setup' => [
            'connection' => 'default'
        ]
    ],
    'x-frame-options' => 'SAMEORIGIN',
    'MAGE_MODE' => 'developer',
    'cache_types' => [
        'config' => 1,
        'layout' => 0,
        'block_html' => 0,
        'view_files_fallback' => 0,
        'view_files_preprocessing' => 0,
        'collections' => 1,
        'db_ddl' => 1,
        'eav' => 1,
        'full_page' => 0,
        'translate' => 1,
        'config_integration' => 1,
        'config_webservice' => 1,
        'config_integration_api' => 1,
        'compiled_config' => 1,
        'reflection' => 1,
        'customer_notification' => 1,
        'vertex' => 1
    ],
    'cache' => [
        'frontend' => [
            'default' => [

            ]
        ]
    ],
    'install' => [
        'date' => '`date`'
    ]
];
EOF

echo "Build sample data..."
php -f dev/tools/build-sample-data.php -- --ce-source="."
