#!/bin/bash
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "${SCRIPT_DIR}"

errorMsg(){
    echo "'${1}' is not installed or not in path. please install it or make it avaiaible"
    exit 1
}

checkInstalled(){
    if hash "${1}" 2>/dev/null; then
        return
    fi
    errorMsg "${1}"
}

checkInstalled python3
checkInstalled pip3
checkInstalled kubectl

python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

mkdir -p "${SCRIPT_DIR}/_output"
