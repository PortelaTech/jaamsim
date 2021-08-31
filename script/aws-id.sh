#!/bin/sh

aws sts get-caller-identity | jq .Arn | tr '"' ' ' | awk -F/ '{print $2}'
