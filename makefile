# Makefile for Lab 3

# Compiler and assembler flags
ASM = nasm
CC = gcc
LD = ld
ASMFLAGS = -f elf32
CFLAGS = -m32 -Wall -ansi -c -nostdlib -fno-stack-protector
LDFLAGS = -m elf_i386

# Object files
OBJS = start.o util.o main.o

# Default target
all: task0

# Task 0
task0: $(OBJS)
	$(LD) $(LDFLAGS) start.o main.o util.o -o task0

# Assembly files
start.o: start.s
	$(ASM) $(ASMFLAGS) start.s -o start.o

# C files
util.o: util.c util.h
	$(CC) $(CFLAGS) util.c -o util.o

main.o: main.c util.h
	$(CC) $(CFLAGS) main.c -o main.o

# Clean target
clean:
	rm -f *.o task0 task0b task1 task2

# Task 0.B - hello world in assembly
task0b: task0b.o
	$(LD) $(LDFLAGS) task0b.o -o task0b

task0b.o: task0b.s
	$(ASM) $(ASMFLAGS) task0b.s -o task0b.o

# Task 1 - encoder in assembly
task1: start.o task1.o util.o
	$(LD) $(LDFLAGS) start.o task1.o util.o -o task1

task1.o: task1.s
	$(ASM) $(ASMFLAGS) task1.s -o task1.o

# Task 2 - virus
task2: start.o task2.o util.o
	$(LD) $(LDFLAGS) start.o task2.o util.o -o task2

task2.o: task2.c util.h
	$(CC) $(CFLAGS) task2.c -o task2.o

.PHONY: all clean
