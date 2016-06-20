# docker-s3-sync

A small docker image that will (periodically) sync an S3-bucket to a local directory.

This can for instance be used as a sidekick-container with a shared filesystem to sync keys or configs.

The syncer can be configured with environment variables:
* `AWS_REGION` the region of the s3-bucket
* `S3_BUCKET` the source bucket
* `S3_KEY` the key in the bucket that will be synced. Must be a folder
* `DESTINATION` the local file path where the files will be stored
* `IAM_ASSUME_ROLE_ARN` optional IAM-role arn to assume before syncing the files
* `MODE` optional file mode for the synced files
* `OWNER_UID` optional owner uid for the synced files
* `OWNER_GID` optional owner gid for the synced files

