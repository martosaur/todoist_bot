#!/bin/bash
docker build -t krksmogbot-builder:latest .

mkdir -p ./_build/ubuntu/rel

docker run --rm \
    --mount type=bind,source="$(pwd)"/_build/ubuntu/rel,destination=/app/_build/prod/rel \
    krksmogbot-builder:latest