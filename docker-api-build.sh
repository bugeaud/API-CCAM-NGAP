#!/bin/sh
docker build -t medshake-api-db:latest . -f Dockerfile-db
docker build -t medshake-api-web:latest . -f Dockerfile-web
