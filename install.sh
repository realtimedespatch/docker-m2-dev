#!/bin/sh

echo "########################################################################"
echo "# Installing Magento CE v$MAGENTO_VERSION with realtimedespatch/magento2-orderflow:$ORDERFLOW_VERSION #"
echo "########################################################################"

if [ ! -d "/app" ]; then
  echo "/app does not exit"
  exit 1
fi

echo "Extracting base magento codebase..."
tar xzf /assets/magento.tar.gz --strip-components=1 -C /app

echo "Extract sample data..."
tar xzf /assets/magento-sampledata.tar.gz --strip-components=1 -C /app

echo "Add orderflow dependency to composer..."
/usr/bin/composer require realtimedespatch/magento2-orderflow:$ORDERFLOW_VERSION --ignore-platform-reqs

echo "Installing composer dependencies..."
/usr/bin/composer install --ignore-platform-reqs

echo "Provisioning docker volumes..."
mkdir -p /app/docker
mkdir -p /app/docker/db/data
mkdir -p /app/docker/nginx/




echo "Project name?"
read PROJECT_NAME

echo "Nginx local port?"
read NGINX_PORT

echo "MySQL local port?"
read DB_PORT

echo "Writing docker .env"
# hardcoded username / password doesn't matter here as it's for local use
cat > /app/.env << EOF
COMPOSE_PROJECT_NAME=$PROJECT_NAME

NGINX_PORT=$NGINX_PORT
DB_PORT=$DB_PORT

MYSQL_DATABASE=magento
MYSQL_USER=magento
MYSQL_PASSWORD=918a9b2f3384
MYSQL_ROOT_PASSWORD=70c6830775bb
EOF

echo "Copying docker-compose config to codebase..."
cp /assets/docker-compose.yml /app/
