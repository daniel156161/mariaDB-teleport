FROM mariadb:latest

ARG phpmyadmin_version="5.2.1"
ARG ubuntu_codename="jammy"

ENV TZ=Europe/Vienna
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY scripts/docker-entrypoint.sh /usr/local/bin/
COPY configs/myteleport.cnf /etc/mysql/mariadb.conf.d/z-custom-for-teleport.cnf

RUN apt-get update && apt-get install -y nginx wget unzip sudo curl php-imagick php-phpseclib php-php-gettext php8.3-common php8.3-mysql php8.3-gd php8.3-imap php8.3-curl php8.3-zip php8.3-xml php8.3-mbstring php8.3-bz2 php8.3-intl php8.3-gmp php8.3-fpm

# Install Teleport
RUN curl https://apt.releases.teleport.dev/gpg \
  -o /usr/share/keyrings/teleport-archive-keyring.asc
RUN export VERSION_CODENAME=$ubuntu_codename && echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] \
  https://apt.releases.teleport.dev/ubuntu ${VERSION_CODENAME?} stable/v17" \
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

RUN rm -rf /var/www/phpmyadmin/composer.lock && rm -rf /var/www/phpmyadmin/package.json && rm -rf /phpMyAdmin-$phpmyadmin_version-all-languages

#Set sudo password neat of www-data to nothing
#RUN sh -c "echo 'www-data ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

VOLUME /var/lib/mysql
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80 3306
CMD ["mariadbd"]
