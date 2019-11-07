#!/usr/bin/env bash

__tst__is_exe_file() {
  local filename
  filename=${1:?Missing filename by param}
  [ -e "$filename" ]
}


__tst__get_base_url() {
  local config_file=~/.config/tst/settings.ini
  if [ ! -f "$config_file" ]; then
    mkdir -p "${config_file%/*}" && touch "$config_file"
  fi

  local base_url
  base_url=$(grep -Po "(?<=^base_url=).+" "$config_file")
  if [ -z "$base_url" ]; then
    echo "To download datasets from the web, you need to specify a 'base_url' in $config_file" >&2
    return 1
  fi

  echo "$base_url"
}


__tst__download_tests() {
  local base_url
  base_url=$(__tst__get_base_url)

  local force
  force="${1:?Missing force flag}"
  local dataset
  dataset="${2:?Missing dataset name}"

  local cache_dir=~/.cache/tst
  mkdir -p "$cache_dir"/

  # download list of tests
  local json_tmp
  json_tmp=$(command -p mktemp) || return 1
  curl --silent "$base_url/$dataset" -o "$json_tmp" || return 1

  # download each test
  local json_length
  json_length=$(jq 'arrays | length' < "$json_tmp")
  if [ -z "$json_length" ]; then
    echo "Dataset '$dataset' not found in: $base_url/$dataset" >&2
    return 1
  fi

  for (( i=0; i < json_length; ++i)); do
    local path
    path=$(jq --raw-output ".[$i].path" < "$json_tmp")

    if [[ $force == 1 || ! -f "$cache_dir/$path" ]]; then
      local download_url
      download_url=$(jq --raw-output ".[$i].download_url" < "$json_tmp")
      echo "Downloading dataset: $path" >&2
      mkdir -p "$cache_dir/$dataset"
      curl --silent "$download_url" -o "$cache_dir/$path"
    fi
  done
  rm "$json_tmp"
}


__tst__has_full_path() {
  local dataset
  dataset="${1:?Missing dataset name}"
  [[ $dataset =~ ^/ ]]
}


__tst__run_tests() {
  local dataset
  dataset="${1:?Missing dataset name}"
  shift

  echo "Running test '$dataset' in executable: $*" >&2

  if ! __tst__has_full_path "$dataset"; then
    dataset=~/.cache/tst/$dataset
  fi
  local output_tmp
  output_tmp=$(command -p mktemp) || return 1
  for input in "$dataset"/input-*; do
    echo -n "${input} -> " >&2
    "$@" < "$input" > "$output_tmp"
    local expected_output_file=${input//input/output}
    if ! diff -q "$output_tmp" "$expected_output_file" > /dev/null; then
      echo "FAILED" >&2
      echo "Expected output:" >&2
      cat "$expected_output_file" >&2
      echo "Current output:" >&2
      cat "$output_tmp" >&2
      echo >&2
    else
      echo "SUCCEDED" >&2
    fi
  done
  rm "$output_tmp"
}


__tst__can_run() {

  if (( ${#@} == 0 )) || [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
    cat >&2 <<EOF
Usage: tst [options] <arguments...>
Options:
  -h, --help    This help
  -f, --force   Force to download datasets (and updating) cache

Example:
  tst ./a.out
EOF
    return 1
  fi

  if ! which jq > /dev/null 2>&1; then
    echo "You need 'jq' to run this script" >&2
    return 1
  fi

  if ! which curl > /dev/null 2>&1; then
    echo "You need 'curl' to run this script" >&2
    return 1
  fi
}


tst() {
  __tst__can_run "$@" || return 1

  local force=0
  if [[ $1 == '-f' || $1 == '--force' ]]; then
    force=1
    shift
  fi

  local found_dataset
  for param in "$@"; do
    if __tst__is_exe_file "$param"; then
      found_dataset=$(strings "$param" | grep -Po "(?<=tst:).+")
      [ "$found_dataset" ] && break
    fi
  done

  if [ "$found_dataset" ]; then
    if ! __tst__has_full_path "$found_dataset"; then
      __tst__download_tests "$force" "$found_dataset" || return 1
    fi
    __tst__run_tests "$found_dataset" "$@"
  else
    echo "Running $*" >&2
    "$@"
  fi
}
