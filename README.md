# Magento 2 / RealtimeDespatch Orderflow Env


- (Only do this once per `MAGENTO_VERSION` and `ORDERFLOW_VERSION` combination)
  From the root of this project, build a demo store installer using the following command where `MAGENTO_VERSION` is the 
  version of Magento CE you'd like to install, and `ORDERFLOW_VERSION` is the extension version you wish to provision with.
  Remember to use a helpful tag so you can skip this step in future.
  ```
  docker build --build-arg MAGENTO_VERSION=2.3.1 -t orderflow-m2:2.3.1
  ```

- Create a target directory for your demo store
  ```
  mkdir /tmp/of_m2
  ```
  
- Install your demo store using the following command
  ```
  docker run --rm --interactive --volume /tmp/of_m2:/app orderflow-m2:2.3.1 /install.sh
  ```
  
- Boot up your environment.
  ```
  cd /tmp/of_m2 && docker-compose build && docker-compose up
  ```

- Run the following command to install the sample db + setup a demo admin user.
  ```
  bin/post-install.sh
  ```
  
- Visit [http://localhost](http://localhost/admin) in your browser

- Access the admin at [http://localhost/admin](http://localhost/admin). 
  * User: `admin` 
  * Pass: `password123`