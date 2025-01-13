set -e

# process arguments to the script, check exactly two arguments are passed
if [ $# -ne 3 ]; then
    echo "Usage: $0 <gist-url> <gist-filename> <write-path>"
    exit 1
fi

GIST_URL=$1
GIST_FILENAME=$2
DIRECTORY=$3

# ensure directory exists
mkdir -p $DIRECTORY

# generate path for temp file
ZIPBASE64=$(mktemp)

echo "ZIPBASE64: $ZIPBASE64"

gh gist view $GIST_URL --filename $GIST_FILENAME > $ZIPBASE64

ZIP=$(mktemp)
echo "ZIP: $ZIP"

# decode the base64 encoded file
base64 -d $ZIPBASE64 > $ZIP

# extract the zip file
unzip $ZIP -d $DIRECTORY

# list content of the directory recursively
ls -R $DIRECTORY
