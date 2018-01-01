#!/usr/bin/env sh
CONTAINER_IMAGE="${REGISTRY}/library/postgres:${POSTGRES_VERSION}-${BUILD_ID}"

set -e

envsubst '$POSTGRES_VERSION' < Dockerfile.template  > Dockerfile

docker build --pull -t $CONTAINER_IMAGE .

#docker push $CONTAINER_IMAGE && echo "$CONTAINER_IMAGE has been built and pushed"
#rm -f Dockerfile
