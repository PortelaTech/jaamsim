#!/bin/bash
export ROLE=${ROLE:-""}
export IS_PULL=${IS_PULL:-""}
export STAGE=test
export STACK=pipeline
set -euo pipefail
./script/run.sh --dev ./docker.jaamsim.dockerfile /bin/sh
