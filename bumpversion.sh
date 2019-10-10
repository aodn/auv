#!/usr/bin/env bash

set -eux

RELEASE_BRANCH=angus_test

bumpversion_build() {
  bump2version patch
}

bumpversion_release() {
  bump2version patch
  git config user.name "aodn-ci-build"
  git config user.email "a.mckeown@utas.edu.au"
  git config --list
  VERSION=$(bump2version --list --commit --allow-dirty release | grep -oP '^new_version=\K.*$')
  git tag $VERSION
  git push origin $RELEASE_BRANCH --tags

}

main() {
  local mode=$1; shift

  if [ "x${mode}" == "xbuild" ]
  then
    bumpversion_build
  elif [ "x${mode}" == "xrelease" ]
  then
    bumpversion_release
  fi

  exit 0
}

main "$@"
