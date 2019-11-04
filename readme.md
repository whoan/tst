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

- Add `test:<dataset>` anywhere in the command to test (eg: in a c/cpp file: `const char* unused = "test:min-coin-change"`).
- Prepend any command with `tst` (eg: `tst ./a.out`) and the dataset found (if so) will be downloaded and will be the input of the program.

### Optional Parameters

- You can provide the `-f/--force` flag to force downloading the tests regardless of it being present in the cache (*~/.cache/tst*). The cache will be updated with the new content.

## License

[MIT](https://github.com/whoan/tst/blob/master/LICENSE)
