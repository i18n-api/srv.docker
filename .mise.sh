set -e
DIR=$(dirname "${BASH_SOURCE[0]}")

if echo ":$PATH:" | grep -q ":$DIR/.mise/bin:"; then
  exit 0
fi

cd ../conf

set +o allexport
. $DIR/env.sh
set -o allexport

echo "ROOT=$(dirname $(realpath $(pwd)))" >$DIR/.env
