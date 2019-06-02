FROM openresty/openresty:stretch-fat

# Update and create self-signed certicate
RUN apt-get update && apt-get install -y libpcre3-dev \
openssl libssl-dev perl build-essential \
libmaxminddb0 libmaxminddb-dev mmdb-bin &&\
mkdir /etc/nginx/ssl &&\
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-subj '/CN=dummy-ssl' \
-keyout /etc/nginx/ssl/nginx.key \
-out /etc/nginx/ssl/nginx.crt && \
mkdir -p /var/www/html && \
chmod -R 755 /var/www/html

# Install geoip2 support
RUN /usr/local/openresty/bin/opm get anjia0532/lua-resty-maxminddb

# Copy settings
USER www-data
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ./src/ /var/www/html

USER root
EXPOSE 80 443