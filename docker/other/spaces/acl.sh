#! /bin/bash

selected=$1
s3cmd setacl "s3://${BUCKET_NAME}/${BUCKET_FOLDER}/${selected:2}" --acl-public
