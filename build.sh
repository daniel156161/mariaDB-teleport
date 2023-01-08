#!/bin/bash

DOCKER_IMAGE_NAME="daniel156161/mariadb-teleport"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

build_docker_image() {
  TAG="$1"

  echo "Building..."
  docker build -t "$DOCKER_IMAGE_NAME:$TAG" .
}

run_docker_container() {
  echo "Running..."
  docker run -it -d \
    -p 3306:3306 \
    -p 80:80 \
    -v "$PWD/certs:/certs/" \
    -e TZ="Europe/Vienna" \
    -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD="true" \
    -e RUN_WEBSERVER="yes" \
    "$DOCKER_IMAGE_NAME":"$GIT_BRANCH"
}

if [ "$GIT_BRANCH" == "main" ]; then
  GIT_BRANCH="latest"
fi

case "$1" in
  run)
    run_docker_container
    ;;
  build)
    build_docker_image "$GIT_BRANCH"
    ;;
  upload)
    build_docker_image "$GIT_BRANCH"
    docker push "$DOCKER_IMAGE_NAME:$GIT_BRANCH"
    ;;
  *)
    echo "Usage: $0 {build|upload}"
    exit 1
    ;;
esac
