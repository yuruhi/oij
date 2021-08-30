#!/usr/bin/env bats

function teardown() {
	pwd | grep test
	(find -type f | grep -v .bats | grep -v '^.$' | xargs rm) || true
	(find -type d | grep -v '^.$' | xargs rmdir) || true
}

@test "dependencies" {
	oij -h
	oj -h
	oj-api -h
	cr-bundle -h
	vim -h
	crystal -h
	ruby -h
}

@test "-v, --version" {
	run oij -v
	[ $status -eq 0 ]
	[ $output = "1.1.0" ]

	run oij --version
	[ $status -eq 0 ]
	[ $output = "1.1.0" ]
}

@test "-h, --help" {
	oij -h
	oij --help
}

@test "compile, exe" {
	echo 'puts 1' > a.cr

	oij compile a.cr
	[ -f a ]

	run oij exe a.cr
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ ./a" ]]
	[ "${lines[1]}" = "1" ]
}
@test "compile (failed)" {
	echo ':' > a.cr

	run oij compile a.cr
	[ $status -eq 1 ]
}
@test "exe (failed)" {
	echo 'exit 42' > a.cr
	oij compile a.cr

	run oij exe a.cr
	[ $status -eq 42 ]
}
@test "compile and exe (with no argument)" {
	echo 'puts 1' > a.cr

	oij compile
	[ -f a ]

	run oij exe
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ ./a" ]]
	[ "${lines[1]}" = "1" ]
}
@test "exe (with input file)" {
	echo 'p gets.to_i * 2' > a.rb
	echo 3 > input

	run oij exe a.rb input
	[ $status -eq 0 ]
	[[ "${lines[0]}" == *"$ ruby a.rb < input" ]]
	[ "${lines[1]}" = "6" ]

	run oij exe input
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ ruby a.rb < input" ]]
	[ "${lines[1]}" = "6" ]
}

@test "run (with programfile)" {
	echo 'p 1' > a.cr

	run oij run a.cr
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
	[[ "${lines[-2]}" = *"$ ./a" ]]
	[ "${lines[-1]}" = "1" ]
}
@test "run (with no argument)" {
	echo 'p 1' > a.cr

	run oij run
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
	[[ "${lines[-2]}" = *"$ ./a" ]]
	[ "${lines[-1]}" = "1" ]
}
@test "run (with programfile and inputfile)" {
	echo 'p read_line.to_i * 2' > a.cr
	echo '3' > input

	run oij run a.cr input
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
	[[ "${lines[-2]}" = *"$ ./a < input" ]]
	[ "${lines[-1]}" = "6" ]
}
@test "run (with inputfile)" {
	echo 'p read_line.to_i * 2' > a.cr
	echo '3' > input

	run oij run input
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
	[[ "${lines[-2]}" = *"$ ./a < input" ]]
	[ "${lines[-1]}" = "6" ]
}

@test "test" {
	# AC
	echo 'p gets.to_i * 2' > a.rb
	mkdir test
	echo 2 > test/1.in
	echo 4 > test/1.out

	run oij test a.rb
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ oj test -c ruby a.rb" ]]

	# WA
	echo 'p gets.to_i * 3' > a.rb
	
	run oij test a.rb
	[ $status -eq 1 ]
	[[ "${lines[0]}" = *"$ oj test -c ruby a.rb" ]]
}
@test "test (with no arugument)" {
	# AC
	echo 'p gets.to_i * 2' > a.rb
	mkdir test
	echo 2 > test/1.in
	echo 4 > test/1.out

	run oij test
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ oj test -c ruby a.rb" ]]

	# WA
	echo 'p gets.to_i * 3' > a.rb
	
	run oij test
	[ $status -eq 1 ]
	[[ "${lines[0]}" = *"$ oj test -c ruby a.rb" ]]
}
@test "test (with oj-args)" {
	# AC
	echo 'p gets.to_i * 2' > a.rb
	mkdir test2
	echo 2 > test2/1.in
	echo 4 > test2/1.out

	run oij test -- -d=test2
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ oj test -c ruby a.rb -d=test2" ]]

	# WA
	echo 'p gets.to_i * 3' > a.rb
	
	run oij test -- -d=test2
	[ $status -eq 1 ]
	[[ "${lines[0]}" = *"$ oj test -c ruby a.rb -d=test2" ]]
}

@test "t" {
	# AC
	echo 'p read_line.to_i * 2' > a.cr
	mkdir test
	echo 2 > test/1.in
	echo 4 > test/1.out

	run oij t a.cr
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]

	# WA
	echo 'p read_line.to_i * 3' > a.cr
	
	run oij t a.cr
	[ $status -eq 1 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
}
@test "t (with no argumant)" {
	# AC
	echo 'p read_line.to_i * 2' > a.cr
	mkdir test
	echo 2 > test/1.in
	echo 4 > test/1.out

	run oij t
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]

	# WA
	echo 'p read_line.to_i * 3' > a.cr
	
	run oij t
	[ $status -eq 1 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
}
@test "t (with oj-args)" {
	# AC
	echo 'p read_line.to_i * 2' > a.cr
	mkdir test2
	echo 2 > test2/1.in
	echo 4 > test2/1.out

	run oij t -- -d=test2
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]

	# WA
	echo 'p read_line.to_i * 3' > a.cr
	
	run oij t -- -d=test2
	[ $status -eq 1 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
}

@test "edit-test" {
	echo -e ':wn\n:wq' | oij et input
	[ -f test/input.in ]
	[ -f test/input.out ]

	echo -e ':wn\n:wq' | oij et input -d test2
	[ -f test2/input.in ]
	[ -f test2/input.out ]
}

@test "print-test" {
	run oij pt input
	[ $status -eq 1 ]
	[[ "$output" = *"Not found testcase file: test/input.in" ]]

	mkdir test
	echo in > test/input.in
	echo out > test/input.out
	run oij pt input
	[ $status -eq 0 ]
	[[ "${lines[0]}" = *"test/input.in (3 byte):" ]]
	[ "${lines[1]}" = "in" ]
	[[ "${lines[2]}" = *"test/input.out (4 byte):" ]]
	[ "${lines[3]}" = "out" ]
}

@test "url" {
	run oij url -a agc001/agc001_a
	[ "$output" = "https://atcoder.jp/contests/agc001/tasks/agc001_a" ]
	run oij url -a agc001_a
	[ "$output" = "https://atcoder.jp/contests/agc001/tasks/agc001_a" ]
	run oij url -y 1
	[ "$output" = "https://yukicoder.me/problems/no/1" ]
	run oij url -c 1000/A
	[ "$output" = "https://codeforces.com/contest/1000/problem/A" ]

	mkdir -p ~/programming/contest/AtCoder/agc001/agc001_a
	cd ~/programming/contest/AtCoder/agc001/agc001_a

	run oij url -n
	[ "$output" = "https://atcoder.jp/contests/agc001/tasks/agc001_b" ]
	run oij url -ns
	[ "$output" = "https://atcoder.jp/contests/agc001/tasks/agc001_b" ]
	run oij url -ps
	[ "$status" -eq 1 ]

	cd $BATS_TEST_DIRNAME
}

@test "url-contest" {
	run oij urlc -a agc001
	[ "$output" = "https://atcoder.jp/contests/agc001" ]
	run oij urlc -c 1000
	[ "$output" = "https://codeforces.com/contest/1000" ]

	mkdir -p ~/programming/contest/AtCoder/agc001
	cd ~/programming/contest/AtCoder/agc001

	run oij urlc -n
	[ "$output" = "https://atcoder.jp/contests/agc002" ]
	run oij urlc -ps
	[ "$status" -eq 1 ]

	cd $BATS_TEST_DIRNAME
}

@test "dir" {
	run oij dir -a agc001/agc001_a
	[ "$output" = "/home/$USER/programming/contest/AtCoder/agc001/agc001_a" ]
	run oij dir -a agc001_a
	[ "$output" = "/home/$USER/programming/contest/AtCoder/agc001/agc001_a" ]
	run oij dir -y 1
	[ "$output" = "/home/$USER/programming/contest/yukicoder/1" ]
	run oij dir -c 1000/A
	[ "$output" = "/home/$USER/programming/contest/Codeforces/1000/A" ]

	mkdir -p ~/programming/contest/AtCoder/agc001/agc001_a
	cd ~/programming/contest/AtCoder/agc001/agc001_a

	run oij dir -n
	[ "$output" = "/home/$USER/programming/contest/AtCoder/agc001/agc001_b" ]
	run oij dir -ns
	[ "$output" = "/home/$USER/programming/contest/AtCoder/agc001/agc001_b" ]
	run oij dir -ps
	[ "$status" -eq 1 ]

	cd $BATS_TEST_DIRNAME
}

@test "dir-contest" {
	run oij dirc -a agc001
	[ "$output" = "/home/$USER/programming/contest/AtCoder/agc001" ]
	run oij dirc -c 1000
	[ "$output" = "/home/$USER/programming/contest/Codeforces/1000" ]

	mkdir -p ~/programming/contest/AtCoder/agc001
	cd ~/programming/contest/AtCoder/agc001

	run oij dirc -n
	[ "$output" = "/home/$USER/programming/contest/AtCoder/agc002" ]
	run oij dirc -ps
	[ "$status" -eq 1 ]

	cd $BATS_TEST_DIRNAME
}

@test "bundle" {
	mkdir -p ~/programming/contest/AtCoder/agc001/agc001_a
	cd ~/programming/contest/AtCoder/agc001/agc001_a

	echo 'def f(x); x * 2; end' > lib.cr
	echo 'require "./lib.cr"; p f(read_line)' > a.cr

	run oij bundle a.cr
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *'$ cr-bundle -f a.cr' ]]
	[ "${lines[1]}" = '# require "./lib.cr"' ]
	[ "${lines[2]}" = 'def f(x)' ]
	[ "${lines[3]}" = '  x * 2' ]
	[ "${lines[4]}" = 'end' ]
	[ "${lines[5]}" = 'p f(read_line)' ]

	run oij bundle
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *'$ cr-bundle -f a.cr' ]]
	[ "${lines[1]}" = '# require "./lib.cr"' ]
	[ "${lines[2]}" = 'def f(x)' ]
	[ "${lines[3]}" = '  x * 2' ]
	[ "${lines[4]}" = 'end' ]
	[ "${lines[5]}" = 'p f(read_line)' ]

	run oij bundle b.cr
	[ "$status" -eq 1 ]
	[[ "${lines[0]}" = *'$ cr-bundle -f b.cr' ]]	

	cd $BATS_TEST_DIRNAME
}

@test "submit" {
	mkdir -p ~/programming/contest/AtCoder/agc001/agc001_a
	cd ~/programming/contest/AtCoder/agc001/agc001_a
	url="https://atcoder.jp/contests/agc001/tasks/agc001_a"
	dir="/home/$USER/programming/contest/AtCoder/agc001/agc001_a"

	: > a.rb
	: > a.cr

	run bash -c 'echo no | oij s a.rb'
	[ "$status" -eq 1 ]
	[[ "${lines[0]}" = *"$ oj submit $url $dir/a.rb" ]]

	run bash -c 'echo no | oij s a.cr'
	[ "$status" -eq 1 ]
	[[ "${lines[0]}" = *"$ cr-bundle -f $dir/a.cr" ]]
	[[ "${lines[1]}" = *"$ oj submit $url "*".cr" ]]

	cd $BATS_TEST_DIRNAME
}

@test "download" {
	mkdir -p ~/programming/contest/AtCoder/agc001/agc001_a
	cd ~/programming/contest/AtCoder/agc001/agc001_a

	[ -d test ] && rm -r ./test
	oij d
	[ -d test ]
	[ -f test/sample-1.in ]
	[ -f test/sample-1.out ]
	[ -f test/sample-2.in ]
	[ -f test/sample-2.out ]

	[ -d ../agc001_b/test ] && rm -r ../agc001_b/test
	oij d -a agc001_b
	[ -d ../agc001_b/test ]
	[ -f ../agc001_b/test/sample-1.in ]
	[ -f ../agc001_b/test/sample-1.out ]

	cd $BATS_TEST_DIRNAME
}

@test "download-contest" {
	mkdir -p ~/programming/contest/AtCoder/agc001
	cd ~/programming/contest/AtCoder/agc001
	url="https://atcoder.jp/contests/agc001/tasks"
	dir="/home/$USER/programming/contest/AtCoder/agc001"

	run oij dc -s
	[ "$status" -eq 0 ]
	for problem in agc001_{a,b,c,d,e,f}; do
		[[ "$output" = *"Download $url/$problem in $dir/$problem"* ]]
	done

	cd $BATS_TEST_DIRNAME
}

@test "template" {
	run oij template -e cr
	[ "$status" -eq 0 ]
	[[ "$output" = *"Generate template file in "*"a.cr" ]]
	[ -f a.cr ]
	[ "`cat a.cr`" = 'require "/template"' ]

	run oij template -e cr
	[ "$status" -eq 0 ]
	[[ "$output" = *"File is already exists: "*"a.cr" ]]
}

@test "prepare" {
	mkdir -p ~/programming/contest/AtCoder/agc001/agc001_a
	cd ~/programming/contest/AtCoder/agc001/agc001_a
	url="https://atcoder.jp/contests/agc001/tasks"
	dir="/home/$USER/programming/contest/AtCoder/agc001"

	[ -d test ] && rm -r ./test
	[ -f a.cr ] && rm ./a.cr
	run oij p
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *"oj download $url/agc001_a" ]]
	[[ "${lines[1]}" = *"Generate template file in $dir/agc001_a/a.cr" ]]
	[ "${lines[2]}" = "$dir/agc001_a" ]
	[ -f a.cr ]
	[ "`cat a.cr`" = 'require "/template"' ]
	[ -d test ]
	[ -f test/sample-1.in ]
	[ -f test/sample-1.out ]
	[ -f test/sample-2.in ]
	[ -f test/sample-2.out ]

	[ -d ../agc001_b/test ] && rm -r ../agc001_b/test
	[ -f ../agc001_b/a.cr ] && rm ../agc001_b/a.cr
	run oij p -n
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *"oj download $url/agc001_b" ]]
	[[ "${lines[1]}" = *"Generate template file in $dir/agc001_b/a.cr" ]]
	[ "${lines[2]}" = "$dir/agc001_b" ]
	[ -f ../agc001_b/a.cr ]
	[ "`cat ../agc001_b/a.cr`" = 'require "/template"' ]
	[ -d ../agc001_b/test ]
	[ -f ../agc001_b/test/sample-1.in ]
	[ -f ../agc001_b/test/sample-1.out ]

	cd $BATS_TEST_DIRNAME
}

@test "prepare-contest" {
	mkdir -p ~/programming/contest/AtCoder/agc001
	cd ~/programming/contest/AtCoder/agc001
	url="https://atcoder.jp/contests/agc001/tasks"
	dir="/home/$USER/programming/contest/AtCoder/agc001"

	run oij pc
	[ "$status" -eq 0 ]
	for problem in agc001_{a,b,c,d,e,f}; do
		[[ "$output" = *"Prepare $url/$problem in $dir/$problem"* ]]
		[[ "$output" = *"oj download $url/$problem"* ]]
		[[ "$output" = *"$dir/$problem/a.cr"* ]]
	done

	cd $BATS_TEST_DIRNAME
}

@test "generate-input" {
	echo 'p 1' > gene.cr
	run oij gi gene.cr 1
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build gene.cr"* ]]
	[[ "${lines[1]}" = *"$ oj generate-input ./gene 1" ]]
	[ -f test/random-000.in ]

	echo ':' > gene.cr
	run oij gi gene.cr
	[ "$status" -eq 1 ]
}

@test "generate-output" {
	echo 'p 1' > solve.cr
	mkdir test
	: > test/1.in
	run oij go solve.cr
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build solve.cr"* ]]
	[[ "${lines[1]}" = *"$ oj generate-output -c ./solve" ]]
	[ -f test/1.out ]

	rm -r ./test
	run oij go solve.cr
	[ "$status" -eq 1 ]
	[[ "${lines[0]}" = *"$ crystal build solve.cr"* ]]
	[[ "${lines[1]}" = *"$ oj generate-output -c ./solve" ]]
}

@test "hack" {
	echo 'p read_line.to_i * 3' > a.cr
	echo 'p 2' > gene.cr
	echo 'p read_line.to_i * 2' > solve.cr
	
	run oij hack a.cr gene.cr solve.cr
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" = *"$ crystal build a.cr"* ]]
	[[ "${lines[1]}" = *"$ crystal build gene.cr"* ]]
	[[ "${lines[2]}" = *"$ crystal build solve.cr"* ]]
	[[ "${lines[3]}" = *"$ oj generate-input --hack-expected ./solve --hack ./a ./gene" ]]

	[ -d test ]
	[ -f test/hack-000.in ]
	[ "`cat test/hack-000.in`" = "2" ]
	[ -f test/hack-000.out ]
	[ "`cat test/hack-000.out`" = "4" ]
}