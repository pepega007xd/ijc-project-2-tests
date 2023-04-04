echo "testing tail..." >&2

assert_tail_error() {
    stdin="$1"
    args="$2"

    echo "$stdin" | "./tail" $args 2> /dev/null && echo \
"TESTING FAIL: Expected return code != 0" >&2
}
assert_tail() {
    stdin="$1"
    args="$2"

    system_tail="$(echo "$stdin" | tail "$args")"
    testing_tail="$(echo "$stdin" | "./tail" $args 2> /dev/null)"

    [ "$system_tail" = "$testing_tail" ] || echo \
"TESTING FAIL: 
Expected: $system_tail
Got: $testing_tail" >&2
}

assert_tail_noeq() {
    stdin="$1"
    args="$2"

    system_tail="$(echo "$stdin" | tail "$args")"
    testing_tail="$(echo "$stdin" | "./tail" $args)"

    [ "$system_tail" != "$testing_tail" ] || echo \
"TESTING FAIL: got identical outputs:
$testing_tail" >&2
}

assert_tail "kentus
blentus
mentus" "-n 2"

assert_tail "" "-n 1"

echo "test 2..."
assert_tail "apple
banana
cherry
date
elderberry" "-n 3"

echo "test 3..."
assert_tail "one
two
three" "-n 5"

echo "test 4..."
assert_tail "1
2
3
4
5" "-n 0"

echo "test 5..."
assert_tail_error "1
2
3" "-n -5"

echo "test 6..."
assert_tail 'Hello world! This is a test.
Line 3
Line 4
Line 5
Line 6
' '-n 3'

echo "test 7..."
assert_tail 'Testing special characters: àçèéêë
This line has no special characters.
Another line with special characters: 🗿 # ! & $ % ^
' '-n 2'

echo "test 8..."
long_line='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget nisl a lacus varius pretium. Etiam porta turpis eu massa aliquam, eget faucibus elit porttitor. Pellentesque vitae nunc eget lectus sollicitudin euismod eget vel urna. Nam sit amet risus ut ipsum faucibus suscipit. Nullam nec quam ut nisl malesuada venenatis nec quis risus. Morbi tristique, enim id consequat bibendum, sapien tortor pharetra enim, a finibus nisi ex at odio. Nunc vel volutpat sapien. Fusce et justo nibh. Quisque ultricies lectus vitae ullamcorper interdum. Sed efficitur urna a venenatis malesuada. Donec sed arcu a ipsum ultricies bibendum. Suspendisse et risus in libero consectetur hendrerit. Nam pulvinar eros vel nibh pharetra, sed ultricies urna auctor. Vivamus at fermentum metus.'
assert_tail "$long_line" "-n 1"

# this should pass
echo "test 9..."
long_input=""
for i in {1..4094}; do long_input+="a"; done
long_input+=$'\n'
assert_tail "$long_input" "-n 5"

# this should pass, but throw an error
echo "test 10..."
long_input=""
for i in {1..4095}; do long_input+="a"; done
long_input+=$'\n'
assert_tail "$long_input" "-n 5"

# this should fail
echo "test 11..."
long_input=""
for i in {1..4096}; do long_input+="a"; done
long_input+=$'\n'
assert_tail_noeq "$long_input" "-n 5" 2> /dev/null

# for manual control
echo "ATTENTION: test 12... you should see just one error below, not five"
long_input=""
for i in {1..10000}; do long_input+="a"; done
long_input="$long_input
$long_input
$long_input
$long_input
$long_input"
echo "$long_input" | "./tail" > /dev/null

###################
# hashtable testing
###################

echo "testing hashtable..." >&2
./test

###################
# wordcount testing
###################

assert_wc() {
    stdin="$1"

    wc_cc="$(echo "$stdin" | "./wordcount-cc" | sort)"
    testing_wc="$(echo "$stdin" | "./wordcount" | sort)"
    testing_wc_dyn="$(echo "$stdin" | LD_LIBRARY_PATH="." "./wordcount-dynamic" | sort)"

    [ "$testing_wc_dyn" = "$testing_wc" ] || echo \
"TESTING FAIL: Dynamic version differs: 
Expected: $wc_cc
Got: $testing_wc" >&2

    [ "$wc_cc" = "$testing_wc" ] || echo \
"TESTING FAIL: 
Expected: $wc_cc
Got: $testing_wc" >&2
}

assert_wc_noeq() {
    stdin="$1"

    wc_cc="$(echo "$stdin" | "./wordcount-cc" | sort)"
    testing_wc="$(echo "$stdin" | "./wordcount" | sort)"
    testing_wc_dyn="$(echo "$stdin" | LD_LIBRARY_PATH="." "./wordcount-dynamic" | sort)"

    [ "$testing_wc_dyn" = "$testing_wc" ] || echo \
"TESTING FAIL: Dynamic version differs: 
Expected: $wc_cc
Got: $testing_wc" >&2

    [ "$wc_cc" != "$testing_wc" ] || echo \
"TESTING FAIL: got identical outputs:
$testing_wc" >&2
}

echo "testing wordcount..." >&2

assert_wc "aaa bbbb eee eee bbbb bbbb bbbb e"

assert_wc "

word1 word3  
word1
   word2
 word1    word3
          
  "

assert_wc "apple banana cherry" 
assert_wc "hello
world" 
assert_wc "    leading whitespace  " 
assert_wc "multiple multiple" 
assert_wc "one two three four five six seven eight nine ten" 
assert_wc "" 
assert_wc "   " 
assert_wc "word with numbers 1234 5678" 
assert_wc "word with special characters !@#$%^&*()_+-=[]{};:'\"\\|,./<>?"
assert_wc "multiple
lines
to
count" 
assert_wc "    multiple
  leading
whitespace
" 
assert_wc "tëst wôrds 🖖" 
assert_wc "word with tab	character" 

long_word="$(printf "%0.sx" {1..255})"
assert_wc "$long_word $long_word $long_word $long_word $long_word"

long_word="$(printf "%0.sx" {1..256})"
assert_wc_noeq "$long_word $long_word $long_word $long_word $long_word" 2> /dev/null

many_words="$(printf "%0.sword " {1..100000})"
assert_wc "$many_words"

# for manual control
echo "ATTENTION: you should see just one error below, not five"
long_word="$(printf "%0.sx" {1..1000})"
long_words="$long_word
$long_word
$long_word
$long_word
$long_word"

echo "$long_words" | "./wordcount" > /dev/null
