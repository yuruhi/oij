# oij

`oij` は [online-judge-tools](https://github.com/online-judge-tools/oj) を URL の指定なしで使えるようにしたコマンドです。

内部で [online-judge-tools](https://github.com/online-judge-tools/oj) と [online-judge-api-client](https://github.com/online-judge-tools/api-client) を使用しています。

## インストール

### ソースから

[online-judge-tools](https://github.com/online-judge-tools/oj/blob/master/docs/getting-started.ja.md) と [Crystal](https://ja.crystal-lang.org/install/) のインストールが必要です。

```sh
$ cd <your favorite directory>
$ git clone https://github.com/yuruhi/oij.git && cd oij
$ shards build --release
$ cp bin/oij <your favorite bin>
```

## 使い方

### コマンド一覧

-   `compile`: 与えられたファイルをコンパイルします。
-   `exe`: 与えられたファイルを実行します。
-   `run`: `compile` と `exe` を実行します。
-   `test`: 与えられたファイルをテストします。
-   `t`: 与えられたファイルをコンパイルしてからテストします。
-   `edit-test`, `et`: 与えられたテストケースを作成してエディターで開きます。
-   `print-test`, `pt`: 与えられたテストケースの内容を表示します。
-   `url`: 与えられた問題の URL を表示します。
-   `url-contest`, `urlc`: 与えられたコンテストの URL を表示します。
-   `dir`: 与えられた問題のディレクトリ名を表示します。
-   `dir-contest`, `dirc`: 与えられたコンテストのディレクトリ名を表示します。
-   `bundle`: 与えられたファイルを設定されたコマンドを使って展開します。
-   `submit`, `s`: 与えられたファイルを現在のディレクトリに対応する問題に提出します。
-   `download`, `d`: 与えられた問題の入出力例をその問題に対応するディレクトリにダウンロードします。
-   `download-contest`, `dc`: 与えられたコンテストの各問題の入出力例をその問題に対応するディレクトリにダウンロードします。
-   `template`: 与えられた拡張子（与えられなかった場合は全て）のテンプレートを生成します。
-   `prepare`, `p`: `download` と `tecmplate` を実行します。
-   `prepare-contest`, `pc`: 与えられたコンテストの各問題について `prepare` を実行します。

`oij` の設定は `~/.config/oij/config.yml` で行えます。

### `compile`, `exe`, `run`

与えられたファイルを `compile` はコンパイル、`exe` は実行、`run` はコンパイルして実行します。

`exe`, `run` は第二引数に入力ファイルを指定できます。

`config.yml` では、コンパイルするコマンド、実行するコマンドを拡張子別に設定します。
`${file}` は与えられたファイル名に置き換えられます。
一つの言語で複数のコンパイルするコマンドを使う場合は `--option`, `-o` で切り替えられます。

```yaml
# config.yml
compile:
    cr:
        default: "crystal build ${file} -o a.out"
        release: "crystal build ${file} -o a.out --release"
    cpp:
        debug: "g++ -g -fsanitize=undefined,address ${file}"
        fast: "g++ -O3 ${file}"
    rb: "ruby -wc ${file}"

execute:
    cr: "./a.out"
    cpp: "./a.out"
    rb: "ruby ${file}"
```

```crystal
# a.cr
puts read_line.to_i * 2
```

```sh
$ oij compile a.cr # same to `oij compile a.cr -o default`
[INFO] $ crystal build a.cr -o a.out

$ oij compile a.cr -o release
[INFO] $ crystal build a.cr -o a.out --release

$ cat input
3

$ oij exe a.cr
[INFO] $ ./a.out
5  # input
10 # output

$ oij exe a.cr input
[INFO] $ ./a.out < input
6

$ oij run a.cr input
[INFO] $ crystal build a.cr -o a.out
[INFO] $ ./a.out < input
6
```

### `test`, `t`

`test` は与えられたファイルをテスト、`t` は与えられたファイルをコンパイルしてからテストします。

`--` の後のオプションはそのまま `oj` に渡されます。

```sh
$ oij compile a.cr
[INFO] $ crystal build a.cr -o a.out

$ oij test a.cr
[INFO] $ oj test -c './a.out'
...

$ oij t a.cr
[INFO] $ crystal build a.cr -o a.out
[INFO] $ oj test -c './a.out'
...

$ oij test a.cr -- -e=1e-5
[INFO] $ oj test -c './a.out' -e=1e-5
...
```

### `edit-test`, `et`

与えられたテストケースをエディターで開きます。

-   `--dir`, `-d` : テストケースが入ったディレクトリを指定する (default: `test`)

使用するエディターは `editor` で指定します。指定されていない場合は環境変数 `EDITOR` を使います。

```yaml
# config.yml
editor: "vim"
```

```sh
$ et sample-1
[INFO] $ vim test/sample-1.in test/sample-1.out

$ et sample-1 -d sample
[INFO] $ vim sample/sample-1.in sample/sample-1.out
```

### `print-test`, `pt`

与えられたテストケースを表示します。

-   `--dir`, `-d` : テストケースが入ったディレクトリを指定する (default: `test`)

表示に使用するコマンドを `printer` で指定することもできます。

```sh
$ pt sample-1
[INFO] test/sample-1.in (2 byte):
3

[INFO] test/sample-1.out (2 byte):
6

# printer: "cat"
$ pt sample-1
[INFO] $ cat test/sample-1.in test/sample-1.out
3
6
```

### `url`, `url-contest`, `urlc`

与えられた問題、コンテストの URL を表示します。（[問題の指定](#問題の指定)、[コンテストの指定](#コンテストの指定)ができます）

```sh
$ oij url --atcoder agc001_a
https://atcoder.jp/contests/agc001/tasks/agc001_a

$ oij url-contest --atcoder agc001
https://atcoder.jp/contests/agc001
```

### `dir`, `dir-contest`, `dirc`

与えられた問題、コンテストに対応するディレクトリを表示します。（[問題の指定](#問題の指定)、[コンテストの指定](#コンテストの指定)ができます）

`config.yml` に `path` に各サービスに対応するディレクトリを絶対パスで指定します。

| 問題の URL                                                   | 対応するディレクトリ                    |
| ------------------------------------------------------------ | --------------------------------------- |
| `https://atcoder.jp/contests/{contest}/tasks/{problem}`      | `path[atcoder]/{contest}/{problem}/`    |
| `https://yukicoder.me/problems/no/{number}`                  | `path[yukicoder]/{number}/`             |
| `https://codeforces.com/contest/{contest}/problem/{problem}` | `path[codeforces]/{contest}/{problem}/` |

```yaml
# config.yml
path:
    atcoder: "/home/yuruhiya/contest/AtCoder"
    yukicoder: "/home/yuruhiya/contest/yukicoder"
    codeforces: "/home/yuruhiya/contest/Codeforces"
```

```sh
$ oij dir --atcoder agc001_a
/home/yuruhiya/contest/AtCoder/agc001/agc001_a

$ oij dir-contest --atcoder agc001_a
/home/yuruhiya/contest/AtCoder/agc001
```

### `bundle`

設定されたコマンドに、与えられたファイルを渡して実行します。

ファイル分割されたプログラムを一つのファイルに展開するコマンド（C++ の場合は [oj-bundle](https://github.com/online-judge-tools/verification-helper/blob/master/README.ja.md#include-の自動展開) など）を指定することが想定されています。

`${file}` は与えられたファイル名に置き換えられます。

```yaml
bundler:
    cr: "cr-bundle ${file}"
    cpp: "oj-bundle -I path/to/your/library ${file}"
```

### `submit`, `s`

与えられたファイルを現在のディレクトリに対応する問題に提出します。`bundler` が設定されている場合はそのコマンドが出力した内容が提出されます。

```sh
~/contest/AtCoder/agc001/agc001_a$ oij s a.rb
[INFO] $ oj s https://atcoder.jp/contests/abc213/tasks/abc213_a a.rb
...

~/contest/AtCoder/agc001/agc001_a$ oij s a.cr
[INFO] $ cr-bundle a.cr
[INFO] $ oj s https://atcoder.jp/contests/abc213/tasks/abc213_a /tmp/bundled.e3lK5W.cr
...
```

### `download`, `d`

与えられた問題の入出力例をその問題に対応するディレクトリにダウンロードします。（[問題の指定](#問題の指定)ができます）

`--` の後のオプションはそのまま `oj` に渡されます。

```sh
~/contest/AtCoder/agc001/agc001_a$ oij d
[INFO] $ oj d https://atcoder.jp/contests/agc001/tasks/agc001_a

~/contest/AtCoder/agc001/agc001_a$ oij d --atcoder agc001_b
[INFO] $ oj d https://atcoder.jp/contests/abc213/tasks/abc213_b # at ~/contest/AtCoder/agc001/agc001_b
```

### `download-contest`, `dc`

与えられたコンテストの各問題の入出力例をその問題に対応するディレクトリにダウンロードします。（[コンテストの指定](#コンテストの指定)ができます）

-   `--silent`, `-s` : `oj d` の出力を表示させない

`--` の後のオプションはそのまま `oj` に渡されます。

```
$ oij dc --atcoder abc005 -s
[INFO] Download https://atcoder.jp/contests/abc005/tasks/abc005_1 in ~/programming/contest/AtCoder/abc005/abc005_1
[INFO] Make directory: /home/yuruhiya/programming/contest/AtCoder/abc005/abc005_1
[INFO] $ oj d https://atcoder.jp/contests/abc005/tasks/abc005_1  > /dev/null

[INFO] Download https://atcoder.jp/contests/abc005/tasks/abc005_2 in ~/programming/contest/AtCoder/abc005/abc005_2
[INFO] Make directory: /home/yuruhiya/programming/contest/AtCoder/abc005/abc005_2
[INFO] $ oj d https://atcoder.jp/contests/abc005/tasks/abc005_2  > /dev/null

[INFO] Download https://atcoder.jp/contests/abc005/tasks/abc005_3 in ~/programming/contest/AtCoder/abc005/abc005_3
[INFO] Make directory: /home/yuruhiya/programming/contest/AtCoder/abc005/abc005_3
[INFO] $ oj d https://atcoder.jp/contests/abc005/tasks/abc005_3  > /dev/null

[INFO] Download https://atcoder.jp/contests/abc005/tasks/abc005_4 in ~/programming/contest/AtCoder/abc005/abc005_4
[INFO] Make directory: /home/yuruhiya/programming/contest/AtCoder/abc005/abc005_4
[INFO] $ oj d https://atcoder.jp/contests/abc005/tasks/abc005_4  > /dev/null
```

### `template`

与えられた拡張子（与えられなかった場合は全て）のテンプレートを生成します。

-   `--ext`, `-e` : 拡張子を指定

`config.yml` にテンプレートファイル（絶対パス）とファイル名を拡張子ごとに指定します。テンプレートファイルが、指定されたファイル名にそのままコピーされます。

```yaml
template:
    cr: ["/home/yuruhiya/.config/oij/template.cr", "a.cr"]
    cr: ["/home/yuruhiya/.config/oij/template.cpp", "a.cpp"]
```

```crystal
# /home/yuruhiya/.config/oij/template.cr
require "/template"
```

```sh
$ oij template -e cr
[INFO] Generate template file in {current path}/a.cr  # a.cr is same to template.cr

$ oij template # same to oij `template -e cr -e cpp`
[INFO] Generate template file in {current path}/a.cr  # a.cr  is same to template.cr
[INFO] Generate template file in {current path}/a.cpp # a.cpp is same to template.cpp
```

### `prepare`, `p`

`download` と `template` を実行して、最後に問題の URL を出力します。（[問題の指定](#問題の指定)ができます）

`--` の後のオプションはそのまま `oj d` に渡されます。

```sh
~/contest/AtCoder/abc213$ oij p --atcoder abc213_a
[INFO] $ oj d https://atcoder.jp/contests/abc213/tasks/abc213_a  > /dev/null
[INFO] Generate template file in ~/programming/contest/AtCoder/abc213/abc213_a/a.cr
/home/yuruhiya/programming/contest/AtCoder/abc213/abc213_a

~/contest/AtCoder/abc213$ cd `oij p --atcoder abc213_a`
[INFO] $ oj d https://atcoder.jp/contests/abc213/tasks/abc213_a  > /dev/null
[INFO] Generate template file in ~/programming/contest/AtCoder/abc213/abc213_a/a.cr

~/contest/AtCoder/abc213/abc213_a$ ls
a.cr test
```

### `prepare-contest`, `pc`

与えられたコンテストの各問題について `prepare` を実行します。（[コンテストの指定](#コンテストの指定)ができます）

`--` の後のオプションはそのまま `oj d` に渡されます。

```
$ oij pc --atcoder abc006
[INFO] Prepare https://atcoder.jp/contests/abc006/tasks/abc006_1 in ~/programming/contest/AtCoder/abc006/abc006_1
[INFO] Make directory: ~/programming/contest/AtCoder/abc006/abc006_1
[INFO] $ oj d https://atcoder.jp/contests/abc006/tasks/abc006_1  > /dev/null
[INFO] Generate template file in ~/programming/contest/AtCoder/abc006/abc006_1/a.cr

[INFO] Prepare https://atcoder.jp/contests/abc006/tasks/abc006_2 in ~/programming/contest/AtCoder/abc006/abc006_2
[INFO] Make directory: ~/programming/contest/AtCoder/abc006/abc006_2
[INFO] $ oj d https://atcoder.jp/contests/abc006/tasks/abc006_2  > /dev/null
[INFO] Generate template file in ~/programming/contest/AtCoder/abc006/abc006_2/a.cr

[INFO] Prepare https://atcoder.jp/contests/abc006/tasks/abc006_3 in ~/programming/contest/AtCoder/abc006/abc006_3
[INFO] Make directory: ~/programming/contest/AtCoder/abc006/abc006_3
[INFO] $ oj d https://atcoder.jp/contests/abc006/tasks/abc006_3  > /dev/null
[INFO] Generate template file in ~/programming/contest/AtCoder/abc006/abc006_3/a.cr

[INFO] Prepare https://atcoder.jp/contests/abc006/tasks/abc006_4 in ~/programming/contest/AtCoder/abc006/abc006_4
[INFO] Make directory: ~/programming/contest/AtCoder/abc006/abc006_4
[INFO] $ oj d https://atcoder.jp/contests/abc006/tasks/abc006_4  > /dev/null
[INFO] Generate template file in ~/programming/contest/AtCoder/abc006/abc006_4/a.cr
```

### 問題の指定

オプションがない場合は現在のディレクトリに対応する問題が指定されたとみなされます。

-   `--url` : URL を指定
-   `--atcoder`, `-a` : [AtCoder](https://atcoder.jp) の問題を指定
-   `--yukicoder`, `-y` : [yukicoder](https://yukicoder.me) の問題を指定
-   `--codeforces`, `-c` : [Codeforces](https://codeforces.com) の問題を指定
-   `--next`, `-n` : 現在のディレクトリに対応する問題の次の問題を指定
-   `--prev`, `-p` : 現在のディレクトリに対応する問題の前の問題を指定
-   `--strict`, `-s` : `--next`, `--prev` に対して、厳密に決める

| オプション                                   | 問題                                                              |
| -------------------------------------------- | ----------------------------------------------------------------- |
| `--atcoder agc001/agc001_a`                  | https://atcoder.jp/contests/agc001/tasks/agc001_a                 |
| `--atcoder agc001_a`                         | https://atcoder.jp/contests/agc001/tasks/agc001_a                 |
| `--yukicoder 1`                              | https://yukicoder.me/problems/no/1                                |
| `--codeforces 1000/A`                        | https://codeforces.com/contest/1000/problem/A                     |
| `--next` (at agc001/agc001_a)                | https://atcoder.jp/contests/agc001/tasks/agc001_b                 |
| `--prev` (at agc001/agc001_a)                | https://atcoder.jp/contests/agc001/tasks/agc001_\` (invalid)      |
| `--prev --strict` (at agc001/agc001_a)       | error                                                             |
| `--next` (at typical90/typical90_z)          | https://atcoder.jp/contests/typical90/tasks/typical90_{ (invalid) |
| `--next --strict` (at typical90/typical90_z) | https://atcoder.jp/contests/typical90/tasks/typical90_aa          |

### コンテストの指定

オプションがない場合は現在のディレクトリに対応するコンテストが指定されたとみなされます。

-   `--url` : URL を指定
-   `--atcoder`, `-a` : [AtCoder](https://atcoder.jp) のコンテストを指定
-   `--codeforces`, `-c` : [Codeforces](https://codeforces.com) のコンテストを指定
-   `--next`, `-n` : 現在のディレクトリに対応するコンテストの次のコンテストを指定
-   `--prev`, `-p` : 現在のディレクトリに対応するコンテストの前のコンテストを指定
-   `--strict`, `-s` : `--next`, `--prev` に対して、厳密に決める

| オプション                        | 問題                                            |
| --------------------------------- | ----------------------------------------------- |
| `--atcoder agc001`                | https://atcoder.jp/contests/agc001              |
| `--codeforces 1000`               | https://codeforces.com/contest/1000             |
| `--next` (at agc001/)             | https://atcoder.jp/contests/agc002              |
| `--prev` (at agc001/)             | https://atcoder.jp/contests/agc000 (invalid)    |
| `--prev --strict` (at agc001/)    | error                                           |
| `--next` (at typical90/)          | https://atcoder.jp/contests/typical91 (invalid) |
| `--next --strict` (at typical90/) | error                                           |

## Contributing

1. Fork it (<https://github.com/your-github-user/oij/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

-   [yuruhi](https://github.com/your-github-user) - creator and maintainer
