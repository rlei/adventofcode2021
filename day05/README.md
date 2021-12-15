## Problem 1 of Day 5

Solved with plain old C. Tested with

* Apple clang version 13.0.0 (clang-1300.0.29.3), Target: x86\_64-apple-darwin21.1.0 (Intel MBP 15" 2019)
* GCC 8.3.0, Target: aarch64-linux-gnu (Raspberry Pi 4b)

To run:

`gcc -Wall -O2 -o prob1 prob1.c` then `prob1 < path/to/input_file`

Usually this will produce slightly faster binary (x86\_64 only), unless you have some really old Intel or AMD CPU:

`gcc -Wall -msse4.2 -O2 -o prob1 prob1.c`

## Problem 2 of Day 5

C again.

To run:

`gcc -Wall -O2 -o prob2 prob2.c` then `prob2 < path/to/input_file`

(or `gcc -Wall -msse4.2 -O2 -o prob2 prob2.c` similarly for x86\_64 arch)

