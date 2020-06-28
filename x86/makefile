NASM_FILE = rotbmp1_32
C_FILE = main
FINAL = 32_bit

all: main rotbmp1_32
	gcc -m32 -o $(FINAL) $(C_FILE).o $(NASM_FILE).o

main:
	gcc -m32 -c -std=c99 $(C_FILE).c

rotbmp1_32:
	nasm -f elf32 $(NASM_FILE).s

clean:
	rm *.o
	rm $(FINAL)
