#!/bin/bash
while true ; do
  case ${1} in
    --stage)
        shift
        export STAGE=${1}
        shift
    ;;
    --stack)
        shift
        export STACK=${1}
        shift
    ;;
    *)
        break
    ;;
  esac
done
echo ${STAGE:?is null} > /dev/null
echo ${STACK:?is null} > /dev/null
# app environment
. ./env-app.sh
export STAGE=${STAGE}
export STACK=${STACK}
export STACK_NAME=${APP_NAME}-${STACK}-${STAGE}
export STAGE_BUCKET=${APP_NAME}-${STACK}-${STAGE}-${AWS_ACCOUNT_ID}-${AWS_REGION}
echo STAGE=${STAGE}
echo STACK=${STACK}
echo STACK_NAME=${STACK_NAME}
echo STAGE_BUCKET=${STAGE_BUCKET}

