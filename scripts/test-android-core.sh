#!/bin/sh
set -eu
cd "$(dirname "$0")/../android/core-tests"
./gradlew test --console=plain
