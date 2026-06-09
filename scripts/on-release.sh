#!/usr/bin/env bash

DATE=$(date)

echo RELEASE WOULD BE STARTED HERE on $DATE
echo From $0 SUPER_SECRET=\"$SUPER_SECRET\"

if [ "$SUPER_SECRET" == "FooBar" ]; then
  echo SUPER_SECRET OK!
else
  echo SUPER_SECRET Failed....
  exit 1
fi