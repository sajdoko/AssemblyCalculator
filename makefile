NASM=nasm
CFLAGS=-f elf64
LINKER=ld
OBJ=calculator.o

all: calculator

%.o: %.asm
	$(NASM) $(CFLAGS) -o $@ $<

calculator: $(OBJ)
	$(LINKER) -o calculator $(OBJ)

.PHONY: clean
clean:
	rm *.o calculator
