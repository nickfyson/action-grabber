set -e

# process arguments to the script, check only one argument is passed
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-directory>"
    exit 1
fi

# check the argument is a directory
if [ ! -d $1 ]; then
    echo "Error: $1 is not a directory"
    exit 1
fi

# get the checksum of the directory
CHECKSUM=$(find $1 -type f -exec md5sum {} \; | sort -k 2 | md5sum | cut -d ' ' -f 1)

# check that the gist exists
if [ -z $(gh gist view $GIST_URL) ]; then
    echo "Error: cannot view gist $GIST_URL"
    exit 1
fi

# if $CHECKSUM.txt does not already exist then we create it
if [ -z $(gh gist view $GIST_URL --filename $CHECKSUM.txt) ]; then
    echo "File $CHECKSUM.txt does not exist in the gist"

    ZIPFILE=$(mktemp).zip
    zip -r $ZIPFILE $1

    BASE64ZIPFILE=$(mktemp)
    echo $(base64 -i $ZIPFILE) > $BASE64ZIPFILE

    gh gist edit $GIST_URL $BASE64ZIPFILE --add $CHECKSUM.txt
fi

# set an output of the action check-sum
echo "gist-filename=$CHECKSUM.txt" >> $GITHUB_OUTPUT

echo "Gist with encoded zip: $GIST_URL#$CHECKSUM.txt"