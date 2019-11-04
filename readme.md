# tst

Test your programs using public datasets form the web (currently, from [my repo of datasets in github][repo-datasets], but I will make it configurable in the future).

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

## Usage

- Add `test:<dataset>` anywhere in the process to test
- Prepend any command with `tst` (eg: `tst ./a.out`) and the dataset found (if so) will be downloaded and will be the input of the program.

### Optional Parameters

- You can provide the `-f/--force` flag to force downloading the tests regardless of it being present in the cache (*~/.cache/tst*). The cache will be updated with the new content.

## Example

If you want to test a process compiled from c/++, you can add the following line to the source file:

```c++
const char* unused = "test:min-coin-change";
```

> I will add an option to the `tst` command to allow specifying the dataset to use and avoid "touching" the source files.

## How it works?

The script is really small so you can check it, but in a nutshell, this is how it works:

- The script uses `strings` command to find the pattern **test:<dataset>**
- If a dataset is found, it uses Github's API to retrieve teh input/output files
- For each input file downloaded, the provided process (the one to test) is executed with the input file (dataset) as its input, and the result is compared to the matching output file

## License

[MIT](https://github.com/whoan/tst/blob/master/LICENSE)