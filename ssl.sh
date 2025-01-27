#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

fp=mnt/ssl/127.0.0.1-key.pem
if [ -f "$fp" ]; then
  diff=$(($(date +%s) - $(stat -f "%m" $fp)))

  if [ $diff -lt 31536000 ]; then
    exit
  fi
fi

mkdir -p mnt/ssl
cd mnt/ssl
bun x mkcert 127.0.0.1
