FROM openresty/openresty:stretch-fat

# Update and create self-signed certicate
RUN apt-get update && apt-get install -y libpcre3-dev \
openssl libssl-dev perl make build-essential curl \
libmaxminddb0 libmaxminddb-dev mmdb-bin apt-utils &&\
mkdir /etc/nginx/ssl &&\
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
-subj '/CN=sni-support-required-for-valid-ssl' \
-keyout /etc/nginx/ssl/nginx.key \
-out /etc/nginx/ssl/nginx.crt

# Copy settings
COPY src/default.conf /etc/nginx/conf.d/default.conf
COPY src/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Install geoip2 support
RUN /usr/local/openresty/bin/opm get yanana/lua-resty-geoip2
