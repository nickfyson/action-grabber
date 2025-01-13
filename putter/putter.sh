set -e

# process arguments to the script, check exactly two arguments are passed
if [ $# -ne 2 ]; then
    echo "Usage: $0 <gist-url> <path-to-directory>"
    exit 1
fi

GIST_URL=$1
DIRECTORY=$2

# check that the gist exists
if [ -z "$(gh gist view $GIST_URL)" ]; then
    echo "Error: cannot view gist $GIST_URL"
    exit 1
fi

# check the argument is a directory
if [ ! -d $DIRECTORY ]; then
    echo "Error: $DIRECTORY is not a directory"
    exit 1
fi

# get the checksum of the directory
CHECKSUM=$(find $DIRECTORY -type f -exec md5sum {} \; | sort -k 2 | md5sum | cut -d ' ' -f 1)

# if $CHECKSUM.zip.base64 does not already exist then we create it
if [ -z "$(gh gist view $GIST_URL --filename $CHECKSUM.zip.base64)" ]; then
    echo "File $CHECKSUM.zip.base64 does not exist in the gist"

    ZIPFILE=$(mktemp).zip
    zip -r $ZIPFILE $DIRECTORY

    BASE64ZIPFILE=$(mktemp)
    echo $(base64 -i $ZIPFILE) > $BASE64ZIPFILE

    gh gist edit $GIST_URL $BASE64ZIPFILE --add $CHECKSUM.zip.base64
fi

if [ -n "$GITHUB_ACTIONS" ]; then
  # set an output of the action check-sum
  echo "gist-filename=$CHECKSUM.zip.base64" >> $GITHUB_OUTPUT
fi

echo "Gist with encoded zip: $GIST_URL#$CHECKSUM.zip.base64"