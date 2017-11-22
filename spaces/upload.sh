#! /bin/bash

cd /data

# Upload files recursively to the bucket
s3cmd sync * s3://$BUCKET_NAME/$BUCKET_FOLDER/ --recursive

# Forcefully set the ACL to either 'public' or 'private'
if [ "$BUCKET_ACL" == "public" ]; then
	if [ -n "$BUCKET_ACL_SELECTOR" ]; then
		IFS="," read -r -a BUCKET_ACL_SELECTOR_ARRAY <<< "$BUCKET_ACL_SELECTOR"
		for ext in "${BUCKET_ACL_SELECTOR_ARRAY[@]}"; do
			find . -name "*.${ext}" -type f -exec /root/acl.sh {} \;
		done
	else
		s3cmd setacl s3://$BUCKET_NAME/$BUCKET_FOLDER/ --acl-public --recursive
	fi
else
	s3cmd setacl s3://$BUCKET_NAME/$BUCKET_FOLDER/ --acl-private --recursive
fi
