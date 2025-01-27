#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[[ -v NODUMP ]] || ../ops/backup/db/dump.sh

./down.sh &&
  rm -rf mnt &&
  ./up.sh &&
  ../init.sh
