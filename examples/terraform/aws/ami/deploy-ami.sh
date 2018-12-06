#!/bin/bash

ami_name=${1}
source_region="eu-central-1"
target_regions="us-east-1 eu-west-1"

source_ami_id=$(aws ec2 describe-images --region ${source_region} --filters "Name=name,Values=${ami_name}" --query 'Images[*].{ID:ImageId}' --output text)

if [[ ! -z ${source_ami_id} ]]; then
  echo "Deploying AMI: ${ami_name} (AMI id: ${source_ami_id})"
  for i in ${target_regions}
  do
    echo "Copying the AMI from ${source_region} to ${i}..."
    aws ec2 copy-image --source-region "${source_region}" --region "${i}" --source-image-id "${source_ami_id}" --name "${ami_name}"
  done
else
  echo "Source AMI ${ami_name} doesn't exist in the region ${source_region}. Exiting..."
  exit
fi
