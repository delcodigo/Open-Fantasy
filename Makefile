ASM = nasm
CC = gcc
LD = ld

ASMFLAGS = -f elf64 -g -F DWARF
CFLAGS = -g -c
LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS = -lglfw -lGL -lm -ldl -lc

SRC_DIR = src
BUILD_DIR = build
GLAD_SRC = dependencies/glad.c
BIN = bin/fantasy

ASM_SRCS = $(wildcard $(SRC_DIR)/*.asm)
ASM_OBJS = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SRCS))
GLAD_OBJ = $(BUILD_DIR)/glad.o
OBJS = $(ASM_OBJS) $(GLAD_OBJ)

all: $(BIN)

$(BIN): $(OBJS)
	mkdir -p bin
	$(LD) $(OBJS) -o $(BIN) $(LDFLAGS) $(LIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(GLAD_OBJ): $(GLAD_SRC)
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(GLAD_SRC) -o $(GLAD_OBJ)

run: $(BIN)
	./$(BIN)

clean:
	rm -rf build bin

.PHONY: all run clean