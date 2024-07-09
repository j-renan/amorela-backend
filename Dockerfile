FROM php:8.2-fpm

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN userdel -f www-data &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID} www-data &&\
    useradd -l -u ${USER_ID} -g www-data www-data &&\
    install -d -m 0775 -o www-data -g www-data /home/www-data

RUN apt-get update -y && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
    libpq-dev \
    postgresql postgresql-client \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

RUN apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick

RUN apt-get update

RUN docker-php-ext-install intl
RUN docker-php-ext-install pdo
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install pgsql
#RUN docker-php-ext-install mbstring
RUN docker-php-ext-install exif
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install gd
RUN docker-php-ext-install soap

#RUN docker-php-ext-install intl pdo opcache pdo_pgsql pgsql mbstring pcntl bcmath soap zip exif

#RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
 #   && docker-php-ext-install pdo pdo_pgsql pgsql

RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis exif

RUN curl -sS https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer

RUN chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} \
                /var/www/html

RUN apt update -y && apt upgrade -y

RUN apt-get install libzip-dev -y

RUN docker-php-ext-install zip

RUN composer self-update --2

USER www-data

