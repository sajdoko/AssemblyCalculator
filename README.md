# Assembly Calculator

A simple calculator written in x86 assembly with support for four main arithmetic operations:

- `Addition`
- `Subtraction`
- `Multiplication`
- `Division`

## Usage

    ./calculator <operator> <operand1> <operand2>

    ./calculator + 2 6
    8

## Operations supported

    +   -  *  /

## Compiling

First install [NASM](https://github.com/netwide-assembler/nasm "Netwide Assembler")

    sudo apt-get install nasm

Then, to compile run:

    nasm -f elf64 -o calculator.o calculator.asm
    ld -d calculator calculator.o

or

    make
