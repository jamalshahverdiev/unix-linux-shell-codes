#!/bin/sh

set -x

SOURCE_URL=""
TARGET_URL=""
WORKDIR="$(mktemp -d)"

echo "Cloning from ${SOURCE_URL} into ${WORKDIR}..."

cd "${WORKDIR}"
git clone --mirror "${SOURCE_URL}" && cd uv-rune-examples && git fetch --prune
echo ""
echo "Cloned to ${WORKDIR}; pushing to ${TARGET_URL}"

git push --prune "${TARGET_URL}" +refs/remotes/origin/*:refs/heads/* +refs/tags/*:refs/tags/*

echo ""
echo "Cleaning up temporary directory ${WORKDIR}..."

rm -rf "${WORKDIR}"

echo "Done."
