## Problem 1 of Day 2

Solved with [sed](https://en.wikipedia.org/wiki/Sed) and [bc](https://en.wikipedia.org/wiki/Bc_%28programming_language%29),
thus no source file other than the line below):

`(sed 's/forward /forward+=/g; s/up /depth-=/g; s/down /depth+=/g;' path/to/day2_input; echo 'forward*depth' ) | bc`


## Problem 2 of Day 2

Again, solved with `sed` and `bc`:

`(sed -E 's/forward (.*)/forward+=\1; depth+=\1*aim/g; s/up /aim-=/g; s/down /aim+=/g;' path/to/day2_input; echo 'forward*depth') | bc`

