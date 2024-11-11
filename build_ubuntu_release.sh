#!/bin/bash
docker buildx build --platform linux/amd64 -t todoist-bot-builder:latest .

mkdir -p ./_build/ubuntu/rel

docker run --rm \
    --mount type=bind,source="$(pwd)"/_build/ubuntu/rel,destination=/app/_build/prod/rel \
    todoist-bot-builder:latest