#!/bin/bash
set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "${SCRIPT_DIR}"

source venv/bin/activate

run_tsetup(){
    echo "Running *${1}*"
    echo
    ./tsetup.py -c config.yml -p "${1}"
    sleep 5
}

if [ "${1}" == "all" ]; then
    run_tsetup customer
    sleep 120
    run_tsetup customerPls
    run_tsetup provider
    sleep 120
    run_tsetup providerPls
    run_tsetup customer2
else
    echo "unkown command '${1}'"
    exit 1
fi