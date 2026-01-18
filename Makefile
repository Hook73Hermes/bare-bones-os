# Percorsi del Cross-Compiler
CC = $(HOME)/opt/cross/bin/i686-elf-gcc
AS = $(HOME)/opt/cross/bin/i686-elf-as

# Cartelle del progetto
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Flag di compilazione per il C
# -ffreestanding: non c'è libreria standard
# -g: Simboli di debug per GDB
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -g

# Flag per il Linker
# -nostdlib: non cerca librerie di sistema
# -lgcc: linka la libreria interna di GCC per le operazioni matematiche
LDFLAGS = -ffreestanding -O2 -nostdlib -lgcc

# Target predefinito: esegue la costruzione del file binario
all: $(BIN_DIR)/bare-bones-os.bin

# Dipende da: boot.o, kernel.o e dallo script del linker
$(BIN_DIR)/bare-bones-os.bin: $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o $(SRC_DIR)/linker.ld
	@mkdir -p $(BIN_DIR)
	@echo "Linking del Kernel..."
	$(CC) -T $(SRC_DIR)/linker.ld -o $@ $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o $(LDFLAGS)
	@echo "Fatto! Kernel generato in: $@"

# Regola per compilare i file C
$(OBJ_DIR)/kernel.o: $(SRC_DIR)/kernel.c
	@mkdir -p $(OBJ_DIR)
	@echo "Compilazione C: $<"
	$(CC) -c $< -o $@ $(CFLAGS)

# Regola per assemblare i file Assembly
$(OBJ_DIR)/boot.o: $(SRC_DIR)/boot.s
	@mkdir -p $(OBJ_DIR)
	@echo "Assemblaggio: $<"
	$(AS) $< -o $@

# Regola per verificare se è un Multiboot valido
check: $(BIN_DIR)/bare-bones-os.bin
	@if grub-file --is-x86-multiboot $(BIN_DIR)/bare-bones-os.bin; then \
		echo "Successo: Il file è Multiboot compatibile"; \
	else \
		echo "Errore: Il file NON è Multiboot compatibile"; \
	fi

# Regola di pulizia
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)