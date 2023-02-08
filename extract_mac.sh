#!/bin/bash
set -e
if [ -z "${1}" ]
then
	echo "no codename specified" >&2
	echo "Usage: ${0} <CODENAME>" >&2
	exit 1
fi
cd "$(dirname "$0")"
CONFIGS=definitions
CONFIG="${CONFIGS}/${1}.txt"
if ! [ -f "${CONFIG}" ]
then
	echo "ERROR: your model has no definition file, please check!" >&2
	exit 1
fi
find components -type f -name '*.gz' -exec gzip -vd {} \;
echo "checking hash..."
if ! sha256sum --quiet --check hash.txt
then
	echo "Hash check failed, corrupted files or forgot to run 'git lfs pull'?"
	exit 1
fi
rm -rf ./output
echo "copying drivers..."
while read -r line
do
	file="${line//$'\r'/}"
	file="${file//'\'//}"
	cp -r ."${file}" output/
done<"${CONFIG}"
echo "rename drivers..."
find output -type f -name '*.inf_'|while read -r line
do mv "${line}" "${line//.inf_/.inf}"
done
find output -type f -name '*.gz' -exec rm -fv {} \;
echo "done"
