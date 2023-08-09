FROM mariadb:latest

ARG phpmyadmin_version="5.2.1"
ARG ubuntu_codename="jammy"

ENV TZ=Europe/Vienna
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY scripts/docker-entrypoint.sh /usr/local/bin/
COPY configs/myteleport.cnf /etc/mysql/mariadb.conf.d/z-custom-for-teleport.cnf

RUN apt-get update && apt-get install -y nginx wget unzip sudo curl php-imagick php-phpseclib php-php-gettext php8.1-common php8.1-mysql php8.1-gd php8.1-imap php8.1-curl php8.1-zip php8.1-xml php8.1-mbstring php8.1-bz2 php8.1-intl php8.1-gmp php8.1-fpm

# Install Teleport
RUN curl https://apt.releases.teleport.dev/gpg \
  -o /usr/share/keyrings/teleport-archive-keyring.asc
RUN export VERSION_CODENAME=$ubuntu_codename && echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
  https://apt.releases.teleport.dev/ubuntu ${VERSION_CODENAME?} stable/v13" \
  | tee /etc/apt/sources.list.d/teleport.list > /dev/null

RUN apt-get update && apt-get install -y teleport

# Nginx Config
COPY configs/nginx.conf /etc/nginx/sites-available/default

# Install phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/$phpmyadmin_version/phpMyAdmin-$phpmyadmin_version-all-languages.zip && unzip phpMyAdmin-$phpmyadmin_version-all-languages.zip

RUN mkdir -p /var/www/phpmyadmin
RUN mv phpMyAdmin-$phpmyadmin_version-all-languages/* /var/www/phpmyadmin
RUN rm -rf phpMyAdmin-$phpmyadmin_version-all-languages.zip

COPY --chown=www-data:www-data configs/phpmyadmin.config.php /var/www/phpmyadmin/config.inc.php
RUN chown -R www-data:www-data /var/www/phpmyadmin && chmod 777 /var/www/phpmyadmin

RUN rm -rf /var/www/phpmyadmin/composer.lock /var/www/phpmyadmin/package.json /phpMyAdmin-$phpmyadmin_version-all-languages

VOLUME /var/lib/mysql
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80 3306
CMD ["mariadbd"]
