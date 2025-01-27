#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ -z "$1" ]; then
  echo "USAGE : $0 xxx"
  exit 1
fi

docker-compose exec $1 bash
