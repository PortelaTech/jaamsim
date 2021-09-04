#!/bin/bash
echo ${STAGE:?is null} > /dev/null
echo ${STACK:?is null} > /dev/null
export ROLE=${ROLE:-""}
export IS_PULL=${IS_PULL:-""}
export MORE_ARGS=""
IS_DEV=""
while true ; do
  case ${1} in
    --dev)
        shift
        IS_DEV=1
    ;;
    *)
        DOCKERFILE=${1}
        shift
        JAAMSIM_ARGS="$*"
        break
    ;;
  esac
done
set -evxuo pipefail # error handling
echo DOCKERFILE=${DOCKERFILE}
[ -f "${DOCKERFILE}" ]

VERSION_LABEL=${VERSION_LABEL:-latest}
IMAGE_TYPE=$(echo $(basename ${DOCKERFILE}) | awk -F. '{print $2}')
IMAGE_URL=${IMAGE_URL:-${APP_NAME}-${IMAGE_TYPE}:${VERSION_LABEL}}

if [[ ! -z "${IS_PULL}" ]]; then
    docker pull ${IMAGE_URL}
fi
if [[ ! -z "${STAGE}" ]]; then
    STAGE_ARGS="-e STAGE=${STAGE}"
fi
if [[ ! -z "${ROLE}" ]]; then
    CREDS=$(aws sts assume-role --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE} --role-session-name `whoami`)
    CRED_ARGS="
    -e AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r .Credentials.SecretAccessKey)
    -e AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r .Credentials.AccessKeyId)
    -e AWS_SESSION_TOKEN=$(echo $CREDS | jq -r .Credentials.SessionToken)
    -e AWS_SESSION_EXPIRATION=$(echo $CREDS | jq -r .Credentials.Expiration)
    "
else
    CRED_ARGS="
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    "
fi
CONTAINER_HOME=/home
NET_ARGS=""
if [ ! -z "${IS_DEV}" ]; then
    MOUNT_ARGS="
        -v "$(pwd):${CONTAINER_HOME}"
    "
else
    MOUNT_ARGS=""
fi

TMPFILE=$(mktemp)
./env-stage.sh --stage ${STAGE} --stack ${STACK} > ${TMPFILE}
cp ${TMPFILE} ./data
ENVFILE=$(pwd)/data/$(basename $TMPFILE)
echo ENVFILE=${ENVFILE}

echo Role=$(script/aws-id.sh)
docker run -it \
    --network host \
    --env-file ${ENVFILE} \
    -e AWS_PROFILE=${AWS_PROFILE} \
    -v ${ENVFILE}:${CONTAINER_HOME}/.env \
    ${CRED_ARGS} \
    ${NET_ARGS} \
    ${MOUNT_ARGS} \
    ${MORE_ARGS} \
    ${IMAGE_URL}
