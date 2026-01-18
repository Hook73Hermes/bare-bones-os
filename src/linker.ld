/* Ingresso per il bootloader */

ENTRY(_start)       

/* Definizione dell'ordine in cui linkare le sezioni */

SECTIONS
{
    /* Il kernel inizia dopo 2MB di ram */

    . = 2M;         

    /* La prima cosa che il bootloader leggerà è il multiboot header */

    .text BLOCK(4K) : ALIGN(4K)     
    {
        *(.multiboot)
        *(.text)
    }

    /* Spazio per le variabili read-only */

    .rodata BLOCK(4K) : ALIGN(4K)   
    {
        *(.rodata)
    }

    /* Spazio per le variabili inizializzate */

    .data BLOCK(4K) : ALIGN(4K)     
    {
        *(.data)
    }

    /* Spazio per le variabili non inizializzate, il nostro stack e variabili comuni */

    .bss BLOCK(4K) : ALIGN(4K)      
    {
        *(.COMMON)
        *(.bss)
    }
}

