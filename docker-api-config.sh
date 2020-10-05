#!/bin/bash
. utils/docker-api-config.sh
eval $calledProcedure
echo "$(tput setaf 10)DONE$(tput sgr0) Called $calledProcedure"
