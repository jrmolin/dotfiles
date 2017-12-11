#!/bin/bash

set -x

SRC_PATH="${SRC_PATH:-./bin}"
STAGING_PATH="${STAGING_PATH:-./staging}"

NAME="${NAME:-name}"
ARCHIVE_NAME="${NAME}.tar.gz"
PATCH_NAME="${NAME}.patch"

ARCHIVE_PATH="${SRC_PATH}/source.orig"
PATCH_PATH="${SRC_PATH}/${PATCH_NAME}"

ORIG_PATH="${STAGING_PATH}/source.orig"
WORKING_PATH="${SRC_PATH}/source.working"
WORKING_PATCH_PATH="${STAGING_PATH}/${PATCH_NAME}"

# if the source archive hasn't been unpacked, then unpack it
if [ ! -d "${ORIG_PATH}" ]; then
   mkdir -p "${ORIG_PATH}"
   tar xzf "${ARCHIVE_PATH}" -C "${ORIG_PATH}"
fi

# if the working archive hasn't been unpacked, then unpack it
if [ ! -d "${WORKING_PATH}" ]; then
   mkdir -p "${WORKING_PATH}"
   tar xzf "${ARCHIVE_PATH}" -C "${WORKING_PATH}"

   # if there is an existing patch, apply it
   if [ -f "${PATCH_PATH}" ]; then
       patch -d "${WORKING_PATH}" -p3 < "${PATCH_PATH}"
   fi
fi

echo "Generating patch: ${WORKING_PATCH_PATH}"
diff -Nuar "${ORIG_PATH}" "${WORKING_PATH}" 1> "${WORKING_PATCH_PATH}"

