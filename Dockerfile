FROM composer AS builder
WORKDIR /app
RUN composer create-project flarum/flarum . --stability=beta \
    && composer require \
        wiwatsrt/flarum-ext-best-answer \
        saleksin/flarum-auth-google \
        flagrow/upload flagrow/split \
        reflar/stopforumspam \
    && composer update

FROM php:7.1-apache AS runtime

RUN apt-get update && apt-get install -y \
        zlib1g-dev libicu-dev g++ git mysql-client unzip zip libpng-dev libpq-dev \
    && docker-php-ext-install pdo_mysql gd intl mbstring \
    && a2enmod rewrite \
    && mkdir -p /var/www

RUN echo "\
<Directory \"/var/www/html/\">\n\
    Allow from All\n\
    AllowOverride All\n\
    Options FollowSymlinks\n\
    Require all granted\n\
</Directory>\n\
<VirtualHost *:80>\n\
    ServerName flarum\n\
    ServerAlias *\n\
    DirectoryIndex index.html index.php\n\
    DocumentRoot /var/www/html/public\n\
</VirtualHost>\n" > /etc/apache2/sites-enabled/000-default.conf

COPY  --from=builder /app /var/www/html/

RUN chown www-data: /var/www/html
RUN chown -R www-data: /var/www/html/storage /var/www/html/public/assets

EXPOSE 80