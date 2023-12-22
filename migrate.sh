#!/bin/bash

set -o pipefail

sleep 10

export TERM=ansi
_GREEN=$(tput setaf 2)
_BLUE=$(tput setaf 4)
_MAGENTA=$(tput setaf 5)
_CYAN=$(tput setaf 6)
_RED=$(tput setaf 1)
_YELLOW=$(tput setaf 3)
_RESET=$(tput sgr0)
_BOLD=$(tput bold)

# Function to print error messages and exit
error_exit() {
    printf "[ ${_RED}ERROR${_RESET} ] ${_RED}$1${_RESET}\n" >&2
    exit 1
}

section() {
  printf "${_RESET}\n"
  echo "${_BOLD}${_BLUE}==== $1 ====${_RESET}"
}

write_ok() {
  echo "[$_GREEN OK $_RESET] $1"
}

write_warn() {
  echo "[$_YELLOW WARN $_RESET] $1"
}

trap 'echo "An error occurred. Exiting..."; exit 1;' ERR

printf "${_BOLD}${_MAGENTA}"
echo "+-------------------------------------+"
echo "|                                     |"
echo "|  Postgres pg_basebackup dump script |"
echo "|                                     |"
echo "+-------------------------------------+"
printf "${_RESET}\n"

section "Validating environment variables"

if [ -z "$PGPASSWORD" ]; then
    error_exit "PGPASSWORD environment variable is not set."
fi
if [ -z "$PG_HOST" ]; then
    error_exit "PG_HOST environment variable is not set."
fi
if [ -z "$PG_PORT" ]; then
    error_exit "PG_PORT environment variable is not set."
fi
if [ -z "$PG_USER" ]; then
    error_exit "PG_USER environment variable is not set."
fi
if [ -z "$VOLUME_PATH" ]; then
    error_exit "VOLUME_PATH environment variable is not set."
fi

write_ok "Env correctly set"

write_ok "Target location contents:"

find $VOLUME_PATH

if [[ ! -d $VOLUME_PATH ]]; then
  error_exit "$VOLUME_PATH is not a directory"
fi

section "Dumping database from $PG_HOST to $VOLUME_PATH"

pg_basebackup -h $PG_HOST -p $PG_PORT -U $PG_USER -D $VOLUME_PATH -Xs -P

write_ok "Successfully saved dump to $VOLUME_PATH"

printf "${_RESET}\n"
