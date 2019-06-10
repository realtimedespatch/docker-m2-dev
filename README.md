# Magento 2 / RealtimeDespatch Orderflow Env


```
docker build --build-arg MAGENTO_VERSION=2.3.1 -t orderflow-m2:2.3.1
```

```
docker run --rm --interactive --volume /tmp/of:/app orderflow-m2:2.3.1 /install.sh
```

```
docker-compose run --rm php bin/magento setup:install
```

```
docker-compose run --rm php bin/magento cache:clean
```