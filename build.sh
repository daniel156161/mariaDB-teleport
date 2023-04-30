#!/bin/bash
source "../build-functions.sh"
source "../build-config.sh"

DOCKER_IMAGE_NAME="daniel156161/mariadb-teleport"

function run_docker_container {
  echo "Running..."
  docker run -it -d \
    -p 3306:3306 \
    -p 80:80 \
    -v "$PWD/certs:/certs/" \
    -e TZ="Europe/Vienna" \
    -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD="true" \
    -e RUN_WEBSERVER="yes" \
    "$DOCKER_IMAGE_NAME:$GIT_BRANCH"
}

case "$1" in
  run)
    run_docker_container
    ;;
  build)
    build_docker_image "$DOCKER_IMAGE_NAME:$GIT_BRANCH"
    ;;
  *)
    echo "Usage: $0 {run|build}"
    exit 1
    ;;
esac
