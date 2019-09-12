#!/bin/bash

# Software Checker Functions ==========>

# return 1 if global command line program installed, else 0
# example
# echo "node: $(program_is_installed node)"
function program_is_installed() {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

function program_is_correct() {
  local return_=0

  if $1 --version | grep -q $2; then
    local return_=1
  fi

  echo "$return_"
}

# return 1 if local npm package is installed at ./node_modules, else 0
# example
# echo "gruntacular : $(npm_package_is_installed gruntacular)"
function npm_package_is_installed() {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  ls node_modules | grep $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

# display a message in red with a cross by it
# example
# echo echo_fail "No"98:1
function echo_fail() {
  # echo first argument in red
  printf "\e[31m${2} ${1}"
  # reset colours back to normal
  printf "\e[0m"
}

# display a message in green with a tick by it
# example
# echo echo_fail "Yes"
function echo_pass() {
  # echo first argument in green
  printf "\e[32m${2} ${1}"
  # reset colours back to normal
  printf "\e[0m"
}

# echo pass or fail
# example
# echo echo_if 1 "Passed"
# echo echo_if 0 "Failed"
function echo_if() {
  if [ $1 == 1 ]; then
    echo_pass $2
  else
    echo_fail $3
  fi
}

# <========== Software Checker Functions

if [ -z "$1" ]; then
  echo "Config filename required! Usage: ./softwareChecker.sh /path/to/file.conf"
else
  CONFIG_FILEPATH=$1
  #echo $CONFIG_FILEPATH

  die() {
    printf >&2 "%s\n" "$@"
    exit 1
  }

  appname=''
  linenb=0
  while read line; do
    ((++linenb))

    #       if [[ $line =~ ^[[:space:]]*$ ]]; then
    #          continue

    regexpAppname="^\s*([[:alnum:]]+):(.*)$"
    if [[ $line =~ $regexpAppname ]]; then
      appname=${BASH_REMATCH[1]}
      appversion=${BASH_REMATCH[2]}
      #declare -A $appname
      is_installed=$(program_is_installed $appname)

      if [ $is_installed == 1 ]; then
          echo "$appname $appversion $(echo_if $(program_is_correct $appname $appversion) 'CORRECT' 'WRONG')"
      else
          echo "$appname $(echo_if $is_installed 'INSTALLED' 'NOT_INSTALLED')"
      fi

    elif [[ $line =~ ^([^=]+)=(.*)$ ]]; then
      [[ -n $appname ]] || die "*** Error line $linenb: no array name defined"
      printf -v ${appname}["${BASH_REMATCH[1]}"] "%s" "${BASH_REMATCH[2]}"

    else
      die "*** Error line $linenb: $line"
    fi
  done <"$CONFIG_FILEPATH"
fi

# command line programs
#echo "apache2 $(echo_if $(program_is_installed apache2))"
#echo "tomita-parser $(echo_if $(program_is_installed tomita-parser))"
#echo "php $(echo_if $(program_is_installed php))"
#echo "asterisk $(echo_if $(program_is_installed asterisk))"
#echo "mysql $(echo_if $(program_is_installed mysql))"
#echo "deploid $(echo_if $(program_is_installed deploid))"
#echo "phing $(echo_if $(program_is_installed phing))"
#echo "composer $(echo_if $(program_is_installed composer))"

# local npm packages
#echo "lodash  $(echo_if $(npm_package_is_installed lodash))"
#echo "react   $(echo_if $(npm_package_is_installed react))"
#echo "angular $(echo_if $(npm_package_is_installed angular))"
