#!/bin/sh

# check presence of tooling

SHASUM=`which shasum`
CURL=`which curl`
[ -n ${SHASUM} ] && [ -n ${CURL} ] || exit 1

# get latest version 

URL="https://api.github.com/repos/minbrowser/min/releases/latest"
VERSION=`curl -sL ${URL} | grep -Po '"tag_name": "v\K.*?(?=")'`

# check if it exists for windows

TARGET="https://github.com/minbrowser/min/releases/download/v${VERSION}/Min-v${VERSION}-win32-x64.zip"

CHECKVER_CODE=`curl -X HEAD -m 3 -sfw "%{response_code}" ${TARGET}`
if [ $CHECKVER_CODE -ne 302 ]; then
	echo "Latest version ${VERSION} does not exist for windows." >&2
	exit 2
fi

echo "Latest version is v$VERSION"

echo "Fetching sha256"

SHA256SUM=$(curl -sL "${TARGET}" | sha256sum | awk '{print $1}')

cat > bucket/minbrowser.json <<MANIFEST  
{
  "homepage": "https://minbrowser.github.io/min/",
  "description": "Minbrowser",
  "version": "${VERSION}",
  "architecture": {
    "64bit": {
      "url": "${TARGET}",
      "hash": "${SHA256SUM}",
      "extract_dir": "Min-v${VERSION}"
    }
  },
  "bin": "Min.exe",
  "checkver": "github",
  "autoupdate": {
    "architecture": {
      "64bit": {
        "url": "https://github.com/minbrowser/min/releases/download/v\$version/Min-v\$version-win32-x64.zip",
        "hash": "${SHA256SUM}",
         "extract_dir": "Min-v\$version"
      }
    }
  }
}

MANIFEST

echo "Updated minbrowser.json"
