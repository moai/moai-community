#!/bin/bash

set -e

cd `dirname $0`/..

export PATH=$PATH:$(pwd)/bin


./scripts/build-linux.sh || exit 1

./scripts/build-android.sh || exit 1

./scripts/build-html.sh || exit 1
