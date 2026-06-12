#!/usr/bin/env bash

DATE=$(date)

echo RELEASE WOULD BE STARTED HERE on $DATE
echo From $0 SUPER_SECRET=\"$SUPER_SECRET\"

NEWEST_TAG=$(git describe --tags --abbrev=0)
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$NEWEST_TAG" =~ ^v.* ]]
then
  RELEASE_NUM=${NEWEST_TAG:1}
  echo "NEWEST_TAG starts with 'v'"
else
  RELEASE_NUM=${NEWEST_TAG}
  echo "NEWEST_TAG does not start with 'v'"
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PROJECT_DIR="$SCRIPT_DIR/.."

CHANGELOG_PATH="$PROJECT_DIR/CHANGELOG.md"

verify_secret() {
  if [ "$SUPER_SECRET" == "Wumpus!" ]; then
    echo SUPER_SECRET OK!
  else
    echo SUPER_SECRET Failed....
  fi
}

verify_changelog() {

  CHANGELOG_RELEASE_HEADERS=$(sed -n '/^#.*[0-9].[0-9]*.[0-9].*/p' $CHANGELOG_PATH)

  mapfile -t HEADER_ARRAY <<< "$CHANGELOG_RELEASE_HEADERS"

  mapfile -td ' ' HEADER_LINE <<< "${HEADER_ARRAY[0]}"

  HEADER_TAG="${HEADER_LINE[1]}"
  HEADER_DATE="${HEADER_LINE[2]:1:-2}"

  if [ "$HEADER_TAG" != "$RELEASE_NUM"  ]; then
    printf "ERROR: Latest HEADER_TAG in CHANGELOG.md (%s) does not match release number (%s) from git tag (%s)\n" \
    "$HEADER_TAG" \
    "$RELEASE_NUM" \
    "$NEWEST_TAG"
    printf "Please update the latest HEADER_TAG in CHANGELOG.md\n"
    exit 1
  else
    printf "CHANGELOG.md release number check: OK\n"
  fi

  if [[ ! "$HEADER_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    printf "ERROR invalid commit date (%s) in last CHANGELOG.md entry\n" "$HEADER_DATE"
    printf "Please update the commit date in CHANGELOG.md\n"
    exit 1
  else
    printf "CHANGELOG.md release date check: OK\n"
  fi
}

update_version() {

  VERSION_FILE=${PROJECT_DIR}/version.txt

  # OLD_VERSION_STRING=$(grep "^TESTAPP_VERSION=.*" ${VERSION_FILE})
  # OLD_VERSION_VAL=$(echo "${OLD_VERSION_STRING}" | sed -e 's/TESTAPP_VERSION=//g')
  # OLD_VERSION=$(echo "${OLD_VERSION_VAL}" | sed -e 's/\"//g')

  # VERSION_PARTS=($(echo $OLD_VERSION | tr '.' '\n'))
  RELEASE_PARTS=($(echo $RELEASE_NUM | tr '.' '\n'))

# printf "DEBUG maj #%s# min #%s# incr #%s#\n" "${VERSION_PARTS[0]}" "${VERSION_PARTS[1]}" "${VERSION_PARTS[2]}"
# printf "DEBUG RELEASE_PARTS maj #%s# min #%s# incr #%s#\n" "${RELEASE_PARTS[0]}" "${RELEASE_PARTS[1]}" "${RELEASE_PARTS[2]}"

  NEW_MAJ="${RELEASE_PARTS[0]}"
  NEW_MIN=$((${RELEASE_PARTS[1]} + 1))
  NEW_INCR="0"

# printf "DEBUG NEW_MAJ %s NEW_MIN %s NEW_INCR %s\n" "${NEW_MAJ}" "${NEW_MIN}" "${NEW_INCR}"

  FUTURE_VERSION="${NEW_MAJ}.${NEW_MIN}.${NEW_INCR}"

# printf "DEBUG FUTURE_VERSION ${FUTURE_VERSION}\n"

# echo "====== DEBUG sed future version ======="

  sed -i "s/TESTAPP_VERSION=\".*\"/TESTAPP_VERSION=\"${FUTURE_VERSION}\"/g" version.txt

# echo "======== END DEBUG sed future version ======="

### UPDATE CHANGELOG

  sed -i "3i ## ${FUTURE_VERSION} [unreleased]\n" $CHANGELOG_PATH

# sed "s/^TESTAPP_VERISION=\".*/TESTAPP_VERSION=\"\""
}

# TODO
push_back_to_github() {
  printf "Here changes to local files would be pushed back to github.\n"
  printf "TODO\n"
  print "DEBUG update git config"
  git config user.email "karl.koerner@bonitoo.io"
  git config user.name "karel rehor"
  printf "DEBUG working on branch %s\n" "$CURRENT_BRANCH"
  git diff
  printf "DEBUG Check branch"
  git branch --show-current
  git commit -am "chore: prepare for next development iteration [skip ci]"
  git log
}

verify_secret

verify_changelog

update_version

push_back_to_github
