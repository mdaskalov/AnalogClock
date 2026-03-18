#!/bin/bash
PROJECT=$(basename "$(PWD)")
HOSTNAME="${1:-$TASMOTA_DEVICE}"
INSTALL_DIR="${2:-$TASMOTA_INSTALL_DIR}"
FILE="${PROJECT}.tapp"

shopt -s nullglob
rm -f ${FILE}; zip -j0 ${FILE} manifest.json src/*.be src/*.jsonl
shopt -u nullglob

# persuade server that we will upload a UFS file
curl -sSo /dev/null http://${HOSTNAME}/ufsd

# do the upload (fsz is required in many builds)
echo "Uploading to ${INSTALL_DIR} on ${HOSTNAME}..."
FSZ=$(stat -f "%z" "${FILE}")
curl -sSo /dev/null --form "ufsu=@${FILE};filename=${INSTALL_DIR}/${FILE}" "http://${HOSTNAME}/ufsu?fsz=${FSZ}"

echo "Restarting ${HOSTNAME}..."
curl -so /dev/null --max-time 1 "http://${HOSTNAME}/cm?cmnd=restart+99"
echo "done."