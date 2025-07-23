# Makefile

# Paths
ASM     := ../assemblers/ca65
LD      := ../assemblers/ld65
SRC     := ./src/main.asm
CFG     := ./src/lorom.cfg
OUTDIR  := ./out
OBJ     := $(OUTDIR)/main.o
BIN     := $(OUTDIR)/slideshow.sfc

# Default target
all: $(BIN)

# Rule to link the final binary
$(BIN): $(OBJ)
	$(LD) -C $(CFG) -o $@ $<

# Rule to assemble the source
$(OBJ): $(SRC) | $(OUTDIR)
	$(ASM) $< -o $@ -g

# Create output directory if not exists
$(OUTDIR):
	mkdir -p $@

# Clean rule
clean:
	rm -rf $(OUTDIR)

.PHONY: all clean
