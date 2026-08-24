ASM = nasm
CC = gcc
LD = ld

ASMFLAGS = -f elf64 -g -F DWARF
CFLAGS = -g -c
LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS = -lglfw -lGL -lm -ldl -lc

SRC = fantasy.asm
GLAD_SRC = dependencies/glad.c
OBJ = build/fantasy.o
GLAD_OBJ = build/glad.o
BIN = bin/fantasy

all: $(BIN)

$(BIN): $(OBJ) $(GLAD_OBJ)
	mkdir -p bin
	$(LD) $(OBJ) $(GLAD_OBJ) -o $(BIN) $(LDFLAGS) $(LIBS)

$(OBJ): $(SRC)
	mkdir -p build
	$(ASM) $(ASMFLAGS) $(SRC) -o $(OBJ)

$(GLAD_OBJ): $(GLAD_SRC)
	mkdir -p build
	$(CC) $(CFLAGS) $(GLAD_SRC) -o $(GLAD_OBJ)

run: $(BIN)
	./$(BIN)

clean:
	rm -rf build bin

.PHONY: all run clean