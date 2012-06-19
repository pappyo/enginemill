#!/bin/bash
bindir="$(cd `dirname "$0"` && pwd)"
enginemill_repo="$( dirname "$bindir" )"

# key file path
if [ -f "$1" ]; then
    keyfile="$1"
else
    keyfile=''
fi

# remote address
remote=$2

# abspath to local repository *without* trailing slash
local_repo="$3"

# the name of the appliacation
appname="$4"

# remote directory is named by the appname
target="/home/ubuntu/platform.x_webapps/$appname"

remote_script="/home/ubuntu/tmp-webserver/bin/mkappdir.sh"

if [ ! -z "$keyfile" ]; then
    ssh -i "$keyfile" ubuntu@$remote "$remote_script $appname"
else
    ssh ubuntu@$remote "$remote_script $appname"
fi

opts="\
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
    "

if [ ! -z "$keyfile" ]; then
    opts="$opts -e ssh -i "$keyfile""
fi

rsync $opts "$local_repo/" "ubuntu@$remote:$target/webapp"
rsync $opts "$enginemill_repo/" "ubuntu@$remote:$target/enginemill"

exit $?
