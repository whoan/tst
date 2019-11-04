#!/usr/bin/env bash

__tst__is_exe_file() {
  local filename
  filename=${1:?Missing filename by param}
  [ -e "$filename" ]
}

__tst__download_and_run_tests() {
  local dataset_repo=https://api.github.com/repos/whoan/datasets/contents

  local force
  force="${1:?Missing force flag}"
  shift
  local dataset
  dataset="${1:?Missing dataset name}"
  shift

  local cache_dir=~/.cache/tst
  mkdir -p "$cache_dir"/

  # download list of tests
  local json_tmp
  json_tmp=$(command -p mktemp) || return 1
  curl --silent "$dataset_repo/$dataset" > "$json_tmp"

  # download each test
  local json_length
  json_length=$(jq 'length' < "$json_tmp")
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

  # run tests
  local output_tmp
  output_tmp=$(command -p mktemp) || return 1
  for input in "$cache_dir/$dataset"/input-*; do
    "$@" < "$input" > "$output_tmp"
    local expected_output_file=${input//input/output}
    if ! diff -q "$output_tmp" "$expected_output_file" > /dev/null; then
      echo "Test $dataset/${input##*/} failed" >&2
      echo "Expected output:" >&2
      cat "$expected_output_file" >&2
      echo "Current output:" >&2
      cat "$output_tmp" >&2
    fi
  done
}


tst() {
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

  local force=0
  if [[ $1 == '-f' || $1 == '--force' ]]; then
    force=1
    shift
  fi

  local found_test
  for param in "$@"; do
    if __tst__is_exe_file "$param"; then
      found_test=$(strings "$param" | grep -Po "(?<=test:).+")
      [ "$found_test" ] && break
    fi
  done

  if [ "$found_test" ]; then
    echo "Running test $found_test in executable: $*" >&2
    __tst__download_and_run_tests "$force" "$found_test" "$@"
  else
    "$@"
  fi
}
