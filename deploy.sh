#!/bin/bash

rm -r -f staging
mkdir staging

pushd staging
cp ../swagger-ui/* .
cp ../api-specs/* .

sed -i 's/..\/api-specs/\/\/developers.powerreviews.com/g' index.html

aws s3 sync . s3://developers.powerreviews.com --storage-class REDUCED_REDUNDANCY --acl public-read --delete

# CLI cloudfront features are in preview - for now, TTL on cloudfront is set to 600 seconds.
# aws cloudfront create-invaldiation --distribution-id E2VEPY1WRUNO4

popd
