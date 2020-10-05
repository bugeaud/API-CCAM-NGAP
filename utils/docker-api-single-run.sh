#!/bin/sh
#docker run --privileged -p 80:80 -p 8080:8080 -it medshake-api-single:latest
docker run --name medshake-api-single --privileged -it -p 80:80 -p 8080:8080 --mount type=bind,source=$HOME/api,target=/root/api medshake-api-single:latest 


