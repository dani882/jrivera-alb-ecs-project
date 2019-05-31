FROM openresty/openresty:stretch-fat

# Update and create self-signed certicate
RUN apt-get update && apt-get install -y libpcre3-dev \
openssl libssl-dev perl make build-essential curl \
libmaxminddb0 libmaxminddb-dev mmdb-bin apt-utils &&\
mkdir /etc/nginx/ssl &&\
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-subj '/CN=dummy-ssl' \
-keyout /etc/nginx/ssl/nginx.key \
-out /etc/nginx/ssl/nginx.crt

# Install geoip2 support
RUN /usr/local/openresty/bin/opm get anjia0532/lua-resty-maxminddb

# Copy settings
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY src/ /usr/local/openresty/nginx/html/

WORKDIR /usr/local/openresty/nginx/html/

EXPOSE 80 443