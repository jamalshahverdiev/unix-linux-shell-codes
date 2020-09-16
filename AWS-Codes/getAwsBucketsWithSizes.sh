#!/usr/bin/env bash
Buckets=$(aws s3api list-buckets --output text | awk '{ print $3 }' | grep -v '^$')

for bucket in $Buckets
do
   echo "Bucket name: $bucket"
   aws s3 ls s3://$bucket --recursive --human-readable --summarize | tail -n1
   echo
done
