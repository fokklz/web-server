#!/bin/bash
# Wordpress-teil des Skripts
# erstellt die basis struktur fuer eine wordpress seite
create_wordpress_base_structure(){
    wordpress_generated_db_password=$(openssl rand -base64 12)
    # erstellt eine basis ini config
    cat > "$wordpress_dir/uploads.ini" <<- EOM
file_uploads = On
memory_limit = 500M
upload_max_filesize = 500M
post_max_size = 500M
max_execution_time = 600
EOM
    # erstellen der compose datei
    cat > "$wordpress_dir/docker-compose.yml" <<- EOM
version: '3.1'

services:
  wordpress:
    image: wordpress
    restart: always
    depends_on:
      - db
    links:
      - db
    ports:
      - $ip:${wordpress_port}:80
    environment:
      WORDPRESS_DB_HOST: db:10000
      WORDPRESS_DB_USER: ${domain_config}_admin
      WORDPRESS_DB_PASSWORD: $wordpress_generated_db_password
      WORDPRESS_DB_NAME: ${domain_config}_wordpress
    volumes:
      - ./html:/var/www/html
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
    networks:
      - default
  db:
    image: mysql:5.7
    restart: always
    networks:
      - default
    environment:
      MYSQL_DATABASE: ${domain_config}_wordpress
      MYSQL_USER: ${domain_config}_admin
      MYSQL_PASSWORD: $wordpress_generated_db_password
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
      MYSQL_TCP_PORT: 10000
    volumes:
      - ./mysql:/var/lib/mysql
  phpmyadmin:
    image: phpmyadmin
    restart: always
    depends_on:
      - db
    ports:
      - $ip:${wordpress_phpmyadmin_port}:80
    environment:
      PMA_HOST: db:10000
      MYSQL_ROOT_PASSWORD: $wordpress_generated_db_password 
    networks:
      - default

volumes:
  wordpress:
  db:

networks:
  default:
    name: ${domain_config}_default
EOM
}