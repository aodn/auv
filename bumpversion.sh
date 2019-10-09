#!/usr/bin/env bash

set -eux

RELEASE_BRANCH=angus_test

bumpversion_build() {
  bump2version patch
}

bumpversion_release() {
  bump2version patch
  git config --global user.name "bumpversion-ci"
  git config --global user.email "a.mckeown@utas.edu.au"
  VERSION=$(bump2version --list --tag --commit --allow-dirty release | grep -oP '^new_version=\K.*$')
  git push origin $RELEASE_BRANCH
  git push origin tag $VERSION

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
