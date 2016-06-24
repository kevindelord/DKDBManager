#!/bin/sh
VERSION=`cat VERSION`
if [ -z "$1" ]
  then
    echo "Missing tag message"
else
	git push --delete origin $VERSION
	git tag --delete $VERSION
	git tag -a $VERSION -m "$1"
	git push origin --tags
fi