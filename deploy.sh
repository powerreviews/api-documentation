#!/bin/bash

rm -r -f staging
mkdir staging

pushd staging
cp ../swagger-ui/* .
cp ../api-specs/* .

sed -i 's/..\/api-specs/http:\/\/developers.powerreviews.com/g' index.html

DATE=`date +%Y%m%d%H%M%S`

aws s3 sync . s3://developers.powerreviews.com/staging_${DATE}/ --storage-class REDUCED_REDUNDANCY --acl public-read

popd
