.set ALIGN,    1<<0             /* allinea i moduli caricati 4KB */
.set MEMINFO,  1<<1             /* abilita mapping della memoria, GRUB chiede al BIOS quali intervalli di ram sono riservati e passa questa lista al kernel per indirizzo in EBX */
.set FLAGS,    ALIGN | MEMINFO  /* flag per multiboot */
.set MAGIC,    0x1BADB002       /* numero che identifica il kernel */
.set CHECKSUM, -(MAGIC + FLAGS) /* checksum */

/* multiboot header: letto da grub */
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* bss: allocazione dello stack */
.section .bss
.align 16
stack_bottom:
.skip 16384 /* 16 KiB di stack */
stack_top:

/* text: codice eseguibile */
.section .text
.global _start
.type _start, @function
_start:
    /* registro stack pointer aggiornato e chiamata al kernel in c */
	mov $stack_top, %esp
	call kernel_main

    /* loop di sicurezza (dal kernel non dovremmo tornare mai) */
	cli
1:	hlt
	jmp 1b

.size _start, . - _start
