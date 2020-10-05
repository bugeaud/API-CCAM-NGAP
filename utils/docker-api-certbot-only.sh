#!/bin/sh
# Let's generate some certificate in the EHR folder
# Usage : ./docker-api-certbot-only.sh www.example.com contact@example.com
# 
# The server has to be accessible on standard HTTP (tcp/80) and HTTPS (tcp/443) ports.
# Once done,  make sure to backup & store in a safe place all the ~/api/decurity data.

#docker run -it --rm --name certbot -v $HOME/api/security/tls/letsencrypt/etc:/etc/letsencrypt -v $HOME/api/security/tls/letsencrypt/var:/var/lib/letsencrypt certbot/certbot certonly $@

docker run --rm \
    -p 80:80 \
    -p 443:443 \
    --name letsencrypt \
    -v ~/api/security/tls/letsencrypt/etc:/etc/letsencrypt \
    -e "LETSENCRYPT_EMAIL=$2" \
    -e "LETSENCRYPT_DOMAIN1=$1" \
    blacklabelops/letsencrypt install

