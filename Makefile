# Emulatore utilizzato
QEMU = qemu-system-i386

# Percorsi del Cross-Compiler
CC = $(HOME)/opt/cross/bin/i686-elf-gcc
AS = $(HOME)/opt/cross/bin/i686-elf-as

# Cartelle del progetto
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
ISO_DIR = isodir

# File generati dalla costruzione
KERNEL_BIN = $(BIN_DIR)/bare-bones-os.bin
OS_ISO = $(BIN_DIR)/bare-bones-os.iso

# Flag di compilazione per il C
# -ffreestanding: non c'è libreria standard
# -g: Simboli di debug per GDB
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -g

# Flag per il Linker
# -nostdlib: non cerca librerie di sistema
# -lgcc: linka la libreria interna di GCC per le operazioni matematiche
LDFLAGS = -ffreestanding -O2 -nostdlib -lgcc

# Target predefinito 
all: $(OS_ISO)

# Dipende da: bare-bones-os.bin e grub.cfg
$(OS_ISO): $(KERNEL_BIN) $(SRC_DIR)/grub.cfg
	@mkdir -p $(ISO_DIR)/boot/grub
	@echo ">> Copia del kernel e configurazione..."
	@cp $(KERNEL_BIN) $(ISO_DIR)/boot/bare-bones-os.bin
	@cp $(SRC_DIR)/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	@echo ">> Generazione immagine ISO con GRUB..."
	grub-mkrescue -o $(OS_ISO) $(ISO_DIR)
	@echo ">> Fatto! ISO generata in: $(OS_ISO)"

# Dipende da: boot.o, kernel.o e dallo script del linker
$(KERNEL_BIN): $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o $(SRC_DIR)/linker.ld
	@mkdir -p $(BIN_DIR)
	@echo ">> Linking del Kernel..."
	$(CC) -T $(SRC_DIR)/linker.ld -o $@ $(OBJ_DIR)/boot.o $(OBJ_DIR)/kernel.o $(LDFLAGS)
	@echo ">> Fatto! Kernel generato in: $@"
	@if grub-file --is-x86-multiboot $(BIN_DIR)/bare-bones-os.bin; then \
		echo ">> Successo: Il file è Multiboot compatibile"; \
	else \
		echo ">> Errore: Il file NON è Multiboot compatibile"; \
	fi

# Regola per compilare i file C
$(OBJ_DIR)/kernel.o: $(SRC_DIR)/kernel.c
	@mkdir -p $(OBJ_DIR)
	@echo ">> Compilazione C: $<"
	$(CC) -c $< -o $@ $(CFLAGS)

# Regola per assemblare i file Assembly
$(OBJ_DIR)/boot.o: $(SRC_DIR)/boot.s
	@mkdir -p $(OBJ_DIR)
	@echo ">> Assemblaggio: $<"
	$(AS) $< -o $@

# Regola run per eseguire il sistema operativo tramite CD rom
run: $(OS_ISO)
	@echo ">> Avvio dell'emulazione da ISO..."
	$(QEMU) -cdrom $(OS_ISO)

# Regola di pulizia
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) $(ISO_DIR)