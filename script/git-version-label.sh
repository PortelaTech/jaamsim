#!/bin/bash
COMMIT=$(echo ${CIRCLE_SHA1-$(git rev-parse HEAD)} | cut -c 1-7) 
BRANCH=${CIRCLE_BRANCH-$(git rev-parse --abbrev-ref HEAD)}
echo ${BRANCH}-${COMMIT}