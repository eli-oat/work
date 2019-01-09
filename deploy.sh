#!/usr/bin/env bash
set -o nounset
set -o errexit

# Externalize Server Info and Credentials
source deploy.config || exit 1

# Relative path from this script to local distribution bundle
DISTRIBUTION_DIRECTORY="_site"

TARGET_PRODUCTION="production"
TARGET_STAGING="staging"

if [[ $# < 1 ]]; then
    printf "Must specify a target (staging or production)\n"
    exit 1
fi

TARGET=$1
export NODE_ENV=${TARGET}
DEPLOY_PARENT=${DEPLOY_DIRECTORY_STAGING}
if [ "$TARGET" == "production" ]; then
    DEPLOY_PARENT=${DEPLOY_DIRECTORY_PRODUCTION}
fi
if [ "$TARGET" == "staging" ]; then
    DEPLOY_PARENT=${DEPLOY_DIRECTORY_STAGING}
fi

printf "================\n$(date)\ndeploying to $TARGET\n"
printf "    server: $SERVER\n"
printf "    path:   $DEPLOY_PARENT\n"

printf "syncing new bundle with server\n"
rsync -vzcrSLh -e "ssh -i $IDENTITY_PATH" --delete $DISTRIBUTION_DIRECTORY/* $SSH_USER@$SERVER:$DEPLOY_PARENT

printf "deployed to $TARGET\n$(date)\n================\n"

# rsync options:
# v - verbose
# z - compress data
# c - checksum, use checksum to find file differences
# r - recursive
# S - handle sparse files efficiently
# L - follow links to copy actual files
# h - show numbers in human-readable format
# p - keep local file permissions (not necessarily recommended)
# --exclude - Exclude files from being uploaded
# --delete - Delete old files not in the new bundle
