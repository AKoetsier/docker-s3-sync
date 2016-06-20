#!/bin/bash -e
if [ -z "$S3_BUCKET" ] || [ -z "$S3_KEY" ] || [ -z "$DESTINATION" ] || [ -z "$AWS_REGION" ]; then
  echo "Must set AWS_REGION, S3_BUCKET, S3_KEY, and DESTINATION env vars" 1>&2
  exit 1
fi

# OWNER_GID default to OWNER_UID
if [ -z "$OWNER_GID" ]; then
  OWNER_GID=$OWNER_UID
fi

##
# Fetch file for S3, move it in place atomically
do_sync () {
  echo "Syncing files from s3://$S3_BUCKET/$S3_KEY to $DESTINATION"
  if [ ! -z "$IAM_ASSUME_ROLE_ARN" ]; then
    echo "Assuming role: $IAM_ASSUME_ROLE_ARN"
    sts_assume=`aws sts assume-role --role-arn $IAM_ASSUME_ROLE_ARN --role-session-name s3sync`
    unset AWS_PROFILE
    export AWS_ACCESS_KEY_ID=$(echo $sts_assume | jq .Credentials.AccessKeyId -r)
    export AWS_SECRET_ACCESS_KEY=$(echo $sts_assume | jq .Credentials.SecretAccessKey -r)
    export AWS_SESSION_TOKEN=$(echo $sts_assume | jq .Credentials.SessionToken -r)
  fi

  aws s3 sync s3://$S3_BUCKET/$S3_KEY $DESTINATION $SYNC_CMD_SUFFIX

  # Optionally set file permissions
  if [ -n "$MODE" ]; then
    chmod "$MODE" $DESTINATION/* -R
  fi

  if [ -n "$OWNER_UID" ]; then
    chown $OWNER_UID:$OWNER_GID $DESTINATION/* -R
  fi
}

if [ -z "$INTERVAL" ]; then
  # Run once
  do_sync
else
  # Loop every $INTERVAL seconds
  while true; do
    s=`date +'%s'`

    do_sync

    sleep $(( $INTERVAL - (`date +'%s'` - $s) ))
  done
fi
