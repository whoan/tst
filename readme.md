# tst

Test your programs using public datasets form the web (currently, from [my repo of datasets in github][repo-datasets]) or your local filesystem.

[repo-datasets]: https://github.com/whoan/datasets

## Installation

### Bash

```bash
# download script and place it in your initialization file
curl --fail "https://raw.githubusercontent.com/whoan/tst/master/tst.sh" > tst.sh &&
  echo "[ -f \"$PWD/\"tst.sh ] && source \"$PWD/\"tst.sh" >> .bashrc
# start a new session to take changes
bash
```

### Dependencies

- `curl` to download datasets
- `jq` to process json responses from GitHub's API

## Usage

- Add `tst:<dataset>` anywhere in the process to test. `dataset` can be a full path to a folder in your local filesystem, or a name to look for in a specified url (see TODO).
- Prepend any command with `tst` (eg: `tst ./a.out`) and the dataset found (if so) will be downloaded and will be the input of the program.

### Optional Parameters

- You can provide the `-f/--force` flag to force downloading the tests regardless of it being present in the cache (*~/.cache/tst*). The cache will be updated with the new content.

## Example

If you want to test a process compiled from c/++, you can add the following line to the source file:

```c++
const char* unused = "tst:<dataset>";  // replace <dataset> with something else. eg: min-coin-change
```

> I will add an option to the `tst` command to allow specifying the dataset to use and avoid "touching" the source files.

## How it works?

The script is really small so I encourage you to read it. In a nutshell, this is how it works:

- The script uses [`strings`][strings] command to find the pattern **tst:<dataset>** in the executable file to test
- If a dataset is found, it uses [Github's API][gh-api] to retrieve the input/output files
- For each input file downloaded, the provided process is executed with the input file (dataset) as its input, and the result is compared to the matching output file

[strings]: https://linux.die.net/man/1/strings
[gh-api]: https://developer.github.com/v3/repos/contents/#get-contents

## TODO

- Make the url to retrieve the datasets from, configurable

## License

[MIT](https://github.com/whoan/tst/blob/master/LICENSE)
