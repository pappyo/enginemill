#!/bin/bash

# key file path
keyfile="$1"
# remote address
remote=$2

# abspath to local repository *without* trailing slash
local_repo="$3"

# remote directory is named by the appname
target="/home/ubuntu/platform.x_webapps/$4"

rsync -e "ssh -i $keyfile" \
    --recursive \
    --compress \
    --links \
    --perms \
    --chmod=Fu-x,Fg-x,g-w,o-w,o-r \
    --times \
    --omit-dir-times \
    --progress \
    --human-readable \
    --exclude='*.~' \
    --exclude='*.swp' \
    --exclude='*.swo' \
    --exclude='*.localized' \
    --exclude='*.DS_Store' \
    --exclude='.git**' \
    "$local_repo/" "ubuntu@$remote:$target"

exit $?
