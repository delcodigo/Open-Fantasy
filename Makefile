ASM = nasm
LD = ld

ASMFLAGS = -f elf64 -g -F DWARF
LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2
LIBS = -lglfw -lGL

SRC_DIR = src
BUILD_DIR = build
BIN = bin/fantasy

ASM_SRCS = $(wildcard $(SRC_DIR)/*.asm)
ASM_OBJS = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SRCS))
OBJS = $(ASM_OBJS)

all: $(BIN)

$(BIN): $(OBJS)
	mkdir -p bin
	$(LD) $(OBJS) -o $(BIN) $(LDFLAGS) $(LIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

run: $(BIN)
	./$(BIN)

clean:
	rm -rf build bin

.PHONY: all run clean