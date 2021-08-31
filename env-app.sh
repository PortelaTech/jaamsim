export ADMIN_EMAIL=gavin.milbank@gmail.com
export APP_NAME=portela-jaamsim

export REPO_DIR=$(pwd)
PATH=${REPO_DIR}/bin:${REPO_DIR}/sbin:${REPO_DIR}/script:${REPO_DIR}/script/$(uname):${PATH}
PYTHONPATH=src
export AWS_PAGER PATH PYTHONPATH

# https://github.com/aws/aws-cli/issues/4787
if [[ -z "${CIRCLE_BRANCH}" ]] ; then
    echo ${AWS_PROFILE:?is null} > /dev/null
    export AWS_REGION=`aws configure get region`
    if [ `uname` = "Darwin" ] ; then
        . ./script/macos.sh
        export AWS_ACCESS_KEY_ID=`aws configure get aws_access_key_id`
        export AWS_SECRET_ACCESS_KEY=`aws configure get aws_secret_access_key`
        export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | sed -e's/"//g')
    fi
else
  if [[ ! -d ~/.aws ]]; then
    mkdir ~/.aws
  fi
  cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF

cat > ~/.aws/config << EOF
[default]
region=${AWS_REGION}
EOF

fi

echo ${AWS_REGION:?is null} > /dev/null
echo ${AWS_ACCESS_KEY_ID:?is null} > /dev/null
echo ${AWS_SECRET_ACCESS_KEY:?is null} > /dev/null
echo ${AWS_ACCOUNT_ID:?is null} > /dev/null
#echo Query secrets, hosted-zone and  certificates
export APP_SECRETS_ARN=$(
  aws secretsmanager --region ${AWS_REGION}  list-secrets |
  jq '.SecretList[] |select(.Name=="'${APP_NAME}'") | .ARN' |
  sed -e's/"//g'
)
export APP_HOSTED_ZONE=$(
  aws route53 --region ${AWS_REGION} list-hosted-zones | 
  jq '.HostedZones[] |select(.Name=="'${APP_DOMAIN}.'") | .Id' | 
  sed -e's/"//g'
)
export APP_HOSTED_ZONE_ID=$(echo ${APP_HOSTED_ZONE} | awk -F/ '{print $3}')
export APP_DOMAIN_CERT=$(
  aws acm --region ${AWS_REGION} list-certificates --certificate-statuses "ISSUED" |  
  jq '.CertificateSummaryList[] |select(.DomainName=="'${APP_DOMAIN}'") | .CertificateArn' | 
  head -1 | sed -e's/"//g'
)
# Cloudfront certs
export APP_DOMAIN_CERT_USEAST1=$(
  aws acm --region us-east-1 list-certificates --certificate-statuses "ISSUED"| 
  jq '.CertificateSummaryList[] |select(.DomainName=="'${APP_DOMAIN}'") | .CertificateArn' | 
   head -1 | sed -e's/"//g'
)
export ECR_URL=${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
