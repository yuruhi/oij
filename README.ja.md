# oij

oij is a competitive programming helper.

## インストール

### ソースから

Crystal 言語の[インストール](https://ja.crystal-lang.org/install/)が必要です。

```sh
$ cd <your favorite directory>
$ git clone https://github.com/yuruhi/oij.git && cd oij
$ shards build --release
$ cp bin/oij <your favorite bin>
```

## 使い方

```
Usage:
  oij [flags...] [arg...]

oij is a competitive programming helper

Flags:
  --help, -h            # Displays help for the current command.
  --version, -v         # Displays the version of the current application.

Subcommands:
  bundle                # Bundle given file
  compile               # Compile given file.
  dir                   # Print directory of given problem.
  dir-contest, dirc     # Print directory of given contest.
  download, d           # Download testcases of given problem.
  download-contest, dc  # Download testcases of given contest.
  edit-test, et         # Edit given testcase.
  exe                   # Execute given file.
  prepare, p            # Prepare for given problem.
  prepare-contest, pc   # Prepare for given contest.
  print-test, pt        # Print given testcase.
  run                   # Compile and execute given file.
  submit, s             # Submit bundled file.
  t                     # Compile and test given file.
  template              # Generate templates.
  test                  # Test given file.
  url                   # Print url of given problem.
  url-contest, urlc     # Print url of given contest.
```

## 設定

```yaml
compile:
    cr: "crystal build ${file} -o a.out --error-trace"
    cpp: "g++-9 -Wall -g -fsanitize=undefined,address -std=c++17 -Wfatal-errors ${file}"
    c: "gcc ${file}"
    rb: "ruby -wc ${file}"
    p6: "rakudo -c ${file}"

execute:
    cr: "./a.out"
    cpp: "./a.out"
    c: "./a.out"
    rb: "ruby ${file}"
    py: "python3 ${file}"
    p6: "rakudo ${file}"
    pl: "perl ${file}"
    sh: "bash ${file}"

path:
    atcoder: "/home/yuruhiya/programming/contest/AtCoder"
    yukicoder: "/home/yuruhiya/programming/contest/yukicoder"
    codeforces: "/home/yuruhiya/programming/contest/Codeforces"

bundler:
    cr: "cr-bundle -f"
    cpp: "oj-bundle -I /home/yuruhiya/programming/"

template:
    cr: ["/home/yuruhiya/programming/oij/config/template.cr", "a.cr"]
    cpp: ["/home/yuruhiya/programming/oij/config/template.cpp", "a.cpp"]

input_file_mapping:
    - ["^s(\\d+)$", "test/sample-\\1.in"]
    - ["^h(\\d+)$", "test/hack-\\1.in"]
    - ["^c(\\d+)$", "test/corner-\\1.in"]

testcase_mapping:
    - ["^s(\\d+)$", "sample-\\1"]
    - ["^h(\\d+)$", "hack-\\1"]
    - ["^c(\\d+)$", "corner-\\1"]

editor: "vim"
printer: "bat -P"
```

## Contributing

1. Fork it (<https://github.com/your-github-user/oij/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

-   [yuruhi](https://github.com/your-github-user) - creator and maintainer
