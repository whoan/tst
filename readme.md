# tst

Test your programs using public datasets from GitHub or your local filesystem.


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

- Add `tst:<dataset>` anywhere in your program. `dataset` can be a full path to a folder in your local filesystem, or a folder in a GitHub repo.
- Prefix any command with `tst` (eg: `tst ./a.out`) and the dataset found (if so) will be the input of your program.

eg: if you want to test a process compiled from c/++, you can add the following line to the source file:

```c++
const char* tst = "tst:/home/you/datasets/knapsack";
```

### Optional Parameters

- You can provide the `-f/--force` flag to force downloading the tests regardless of it being present in the cache (*~/.cache/tst*). The cache will be updated with the new content.

### Settings

- If you want to download datasets from GitHub, please set the `base_url` in *~/.config/tst/settings.ini*

    eg: to use the datasets in https://github.com/whoan/datasets, you have to set this `base_url`:

    ```bash
    $ cat ~/.config/tst/settings.ini
    ```
    ```
    base_url=https://api.github.com/repos/whoan/datasets/contents
    ```

- Set `timeout` to N (integer) to override the default of 5 seconds. Notice that the timeout apply to each test (ie: the process has N seconds to complete each test)

## Example

See this real world example: https://github.com/whoan/challenges/blob/master/min-coin-change.cpp

## How it works?

The script is really small so I encourage you to read it. In a nutshell, this is how it works:

- The script uses [`strings`][strings] command to find the pattern **tst:<dataset>** in the executable file to test
- If a dataset is found, it retrieves the input/output files either from your local filesystem (if a full path is provided) or using [Github's API][gh-api]
- For each input file downloaded, the provided process is executed with the input file (dataset) as its input, and the result is compared to the matching output file

[strings]: https://linux.die.net/man/1/strings
[gh-api]: https://developer.github.com/v3/repos/contents/#get-contents

## TODO

- Add an option to the command to allow specifying the dataset to use, instead of "touching" the source files.

## License

[MIT](https://github.com/whoan/tst/blob/master/LICENSE)
