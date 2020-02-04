#!/bin/bash

set -o pipefail

if [ -z "${AWS_BUCKET}" ]; then
  echo "You need to set the AWS_BUCKET environment variable."
  exit 1
fi

if [ -z "${AWS_BUCKET_PREFIX}" ]; then
  echo "You need to set the AWS_BUCKET_PREFIX environment variable."
  exit 1
fi

if [ -z "${AWS_SNS_TOPIC_ARN}" ]; then
  echo "You need to set the AWS_SNS_TOPIC_ARN environment variable."
  exit 1
fi

if [ -z "${PGDATABASE}" ]; then
  echo "You need to set the PGDATABASE environment variable."
  exit 1
fi

if [ -z "${PGUSER}" ]; then
  echo "You need to set the PGUSER environment variable."
  exit 1
fi

if [ -z "${PGPASSWORD}" ]; then
  echo "You need to set the PGPASSWORD environment variable."
  exit 1
fi

if [ -z "${PGHOST}" ]; then
  echo "You need to set the PGHOST environment variable."
  exit 1
fi

echo "Starting dump of ${PGDATABASE} database(s) from ${PGHOST}..."

pg_dump $PGDUMP_OPTIONS | aws s3 cp - s3://$AWS_BUCKET/$AWS_BUCKET_PREFIX/$(date +"%F-%H-%M-%S-postgres-backup${PGDUMP_FILE_POSTFIX}.dump")
error=$?
if [[ $error != 0 ]]; then
    echo "Error in backup, will send to sns topic!"
    aws sns publish --topic-arn "${AWS_SNS_TOPIC_ARN}" --subject "Postgres Backup failure - $PGHOST" --message "Failed to dump backup to S3. Sorry."
    exit 2
fi

echo "Done!"

exit 0
