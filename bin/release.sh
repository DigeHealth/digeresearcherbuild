#!/bin/bash

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

APP_PATH=$1
APP_DIR="$(dirname "$APP_PATH")"
APP_FILE="$(basename "$APP_PATH")"
ARCHIVE_FILE=${APP_FILE//.app/.zip}
WORKING_DIR="$(pwd)"

if [[ ! "$APP_PATH" =~ \.app$ ]]; then
  echo "The path to a [DigeHealth Researcher].app file is required, $1 provided"
  exit
fi

if [ ! -d "$APP_PATH" ]; then
  echo "File $APP_PATH does not exist."
  exit
fi

# Create the archive
(cd "$APP_DIR"; zip -r --symlinks "$WORKING_DIR/$ARCHIVE_FILE" "$APP_FILE")

# sign the update
SIGN_SIGNATURE_OUTPUT=$(cd "$WORKING_DIR/../digeresearcher/macos/Pods/Sparkle/"; ./bin/sign_update "$WORKING_DIR/$ARCHIVE_FILE")
(cd "$WORKING_DIR/../digeresearcher/macos/Pods/Sparkle/"; ./bin/generate_appcast "$WORKING_DIR")

# get from the appcast.xml the version number of a correct commit message
VERSION="$(sed -n 's|<sparkle:version>\(.*\)</sparkle:version>|\1|p' appcast.xml | xargs)"
SPARKLE_SIGNATURE="$(grep "sparkle:edSignature=" appcast.xml | awk -F 'sparkle:edSignature="' '{print $2}' | awk -F '"' '{print $1}')"
SIGN_SIGNATURE="$(echo $SIGN_SIGNATURE_OUTPUT | awk -F 'sparkle:edSignature="' '{print $2}' | awk -F '"' '{print $1}')"

if [ "$SPARKLE_SIGNATURE" != "$SIGN_SIGNATURE" ]; then
  echo ""
  echo "SIGNATURE PROBLEM"
  echo ""
  echo "Sparkle Signature in appcast.xml"
  echo $SPARKLE_SIGNATURE
  echo "Sparkle Signature from CLI"
  echo $SIGN_SIGNATURE
  echo ""

  exit
fi

git add .
git commit -m "Release $VERSION"
git push origin main