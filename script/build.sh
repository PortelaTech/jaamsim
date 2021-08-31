#!/bin/bash -xv
set -exvuo pipefail
IS_PUSH=""
IS_BUILD=""
TARGETS=""

for ARG in $* ; do
  case $ARG in
    --push)
      IS_PUSH=1
      shift
    ;;
    --build)
      IS_BUILD=1
      shift
    ;;
    --targets)
      TARGETS=$2
      shift 2
    ;;
    --*)
      echo Unknow arg ${ARG}  
  esac
done

echo ${APP_NAME:?is null} > /dev/null
echo ${AWS_ACCESS_KEY_ID:?is null} > /dev/null
echo ${AWS_SECRET_ACCESS_KEY:?is null} > /dev/null
echo ${AWS_REGION:?is null} > /dev/null
echo ${AWS_ACCOUNT_ID:?is null} > /dev/null
echo ${ECR_URL:?is null} > /dev/null

export VERSION_LABEL=$(git-version-label.sh)

DOCKERFILE=${1}
[ -f "${DOCKERFILE}" ]
IMAGE_TYPE=$(echo $(basename ${DOCKERFILE}) | awk -F. '{print $2}')

if [[ ! -z "${IS_BUILD}" ]] ; then
  case $IMAGE_TYPE in
    jaamsim)
    ant
    ;;
    *)
      echo No host build  
  esac
fi

if [[ ! -z "${IS_BUILD}" ]] ; then
  docker build -f ${DOCKERFILE} \
    --build-arg IMAGE_TYPE=${IMAGE_TYPE} \
    --target prod \
    -t ${APP_NAME}-${IMAGE_TYPE}:latest \
    -t ${APP_NAME}-${IMAGE_TYPE}:${VERSION_LABEL} \
    -t ${ECR_URL}/${APP_NAME}-${IMAGE_TYPE}:${VERSION_LABEL} \
    .
fi

if [[ ! -z "${IS_PUSH}" ]] ; then
  aws ecr --region ${AWS_REGION} get-login-password | 
    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
  docker push ${ECR_URL}/${APP_NAME}-${IMAGE_TYPE}:${VERSION_LABEL}
fi
