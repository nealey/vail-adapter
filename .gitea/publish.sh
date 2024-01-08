#! /bin/sh

set -e

PACKAGE=${GITHUB_REPOSITORY#*/}
VERSION=$GITHUB_REF_NAME

BASE=$GITHUB_SERVER_URL/api/packages/$GITHUB_ACTOR/generic/$PACKAGE/$VERSION

echo "=== Delete $VERSION"
curl \
  --user "$GITHUB_ACTOR:$PACKAGE_API_TOKEN" \
  --request DELETE \
  $BASE
echo

for path in "$@"; do
  fn=$(basename "$path")
  echo "=== Upload $VERSION/$fn"

  curl \
    --fail \
    --user "$GITHUB_ACTOR:$PACKAGE_API_TOKEN" \
    --upload-file "$path" \
    $BASE/$fn
  echo
done
