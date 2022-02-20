<h1>Assembly Calculator</h1>

A simple calculator written in x86 assembly with support for four main arithmetic operations:
- `Addition`
- `Subtraction`
- `Multiplication`
- `Division`

<br>

<h2>Usage</h2>

---

~$ <code>./calculator \<operator\> \<operand1\> \<operand2\></code>

    ./calculator + 2 6
    8


<h3>Operations supported</h3>

<code>+</code> <code>-</code> <code>*</code> <code>/</code> <br>

<br>
<h2>Compiling</h2>

---

First install [NASM](https://github.com/netwide-assembler/nasm "Netwide Assembler")

```bash
sudo apt-get install nasm
```
Then, to compile run:

```bash
nasm -f elf64 -o calculator.o calculator.asm
ld -d calculator calculator.o
```
or

```bash
make
```