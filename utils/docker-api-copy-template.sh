#!/bin/bash
docker cp "$(docker-compose ps -q web)":/app/API-CCAM-NGAP/templates/. ~/api/template/
chown -R www-data:www-data ~/api/template/
chmod -R 644 ~/api/template/
