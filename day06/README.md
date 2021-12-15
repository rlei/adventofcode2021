## Problem 1 of Day 6

Solved with x86\_64 assembly on Intel MBP 15" 2019, using [nasm](https://www.nasm.us/). XCode CLT is also needed.

For it to work on Linux, syscall numbers will need to be adjusted accordingly.

To build:

`nasm -f macho64 prob1.asm && ld -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -lc -o prob1 prob1.o -no_pie`

(Sorry I'm just too lazy to create a Makefile :p)

To run:

`prob1 < path/to/input_file`

## Problem 2 of Day 6

Basically replaced all 32 bit integers with 64 bit ones.

To build:

`nasm -f macho64 prob2.asm && ld -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -lc -o prob2 prob2.o -no_pie`

To run:

`prob2 < path/to/input_file`
