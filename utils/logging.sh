#!/bin/bash

MYTAB='  '
function log() {
  echo "${MYTAB}DEBUG: $1"
  echo "${MYTAB}"$'\e[1;33m'${2:-STEP}:$'\e[0m' $'\e[1;32m'$1$'\e[0m' >&3
}
function logerror() {
  echo "${MYTAB}DEBUG: $1"
  echo "${MYTAB}"$'\e[1;31m'ERROR:$'\e[0m' $'\e[1;1m'$1$'\e[0m' >&3
}
function exiterror() {
  logerror "$(cat $1 | tail -1)"
  logerror "See ${1} for more details" "INFO"
  exit 1
}
