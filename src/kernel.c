/* Le seguenti librerie non sono parte della standard library ma del compilatore */ 

#include <stdbool.h>    /* Importa il tipo bool */
#include <stddef.h>     /* Importa NULL e size_t */
#include <stdint.h>     /* Importa intX_t e uintX_t */

/* Controlla di star usando cross-compiling */

#if defined(__linux__)
#error "Non stai utilizzando un cross-compiler"
#endif

/* Controlla che produca eseguibili per 32 bit */

#if !defined(__i386__)
#error "Devi utilizzare un ix86-elf compiler"
#endif

/* Costanti per i colori VGA definite dallo standard */

enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

/* 
Funzioni di utilità per la gestione del VGA 
Un entry VGA è composta da 16 bit: | colore-sfondo (4) | colore-primo-piano (4) | carattere (8) |
*/

/* Combina colore del testo e colore dello sfondo */

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg)
{
    return fg | bg << 4;
}

/* Combina colore (testo e sfondo) e carattere */

static inline uint16_t vga_entry(unsigned char uc, uint8_t color)
{
    return (uint16_t) uc | (uint16_t) color << 8;
}

/* Costanti fisiche del memory-mapping del VGA */

#define VGA_WIDTH   80
#define VGA_HEIGHT  25
#define VGA_MEMORY  0xB8000 
#define TAB_SIZE    4

/* Variabili per la gestione del terminale */

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
volatile uint16_t* terminal_buffer;

/* Inizializza la memoria in cui è mappato il VGA */

void terminal_init(void)
{
    terminal_row = 0;
    terminal_column = 0;
    terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    terminal_buffer = (uint16_t*) VGA_MEMORY;

    for (size_t row = 0; row < VGA_HEIGHT; row++) {
        for (size_t col = 0; col < VGA_WIDTH; col++) {
            size_t index = row * VGA_WIDTH + col;
            terminal_buffer[index] = vga_entry(' ', terminal_color);
        }
    }
}

/* Setta il colore del terminale */

void terminal_setcolor(uint8_t color)
{
    terminal_color = color;
}

/* Porta il cursore su una nuova riga */

void terminal_newline(void)
{
    terminal_row++;
    terminal_column = 0;
}

/* Porta il cursore al prossimo tab */

void terminal_tab(void)
{
    terminal_column = (terminal_column / TAB_SIZE) * TAB_SIZE + TAB_SIZE;
    if (terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_row = 0;
        }
    }
}

/* Scrive una entry in una data posizione */

void terminal_putentryat(char c, uint8_t color, int row, int col)
{
    size_t index = row * VGA_WIDTH + col;
    terminal_buffer[index] = vga_entry(c, color);
}

/* Scrive un carattere nella prossima posizione e aggiorna il cursore */

void terminal_putchar(char c)
{
    terminal_putentryat(c, terminal_color, terminal_row, terminal_column);

    if (++terminal_column == VGA_WIDTH) {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_row = 0;
        }
    }
}

/* Scrive una stringa leggendo un carattere per volta */

void terminal_writestring(char* data)
{
    size_t data_len = 0;

    while (data[data_len] != '\0') {
        switch (data[data_len]) {
            case '\n':
                terminal_newline();
                break;
            case '\t':
                terminal_tab();
                break;
            default:
                terminal_putchar(data[data_len]);
                break;
        }
        data_len++;
    }
}

/* Main del kernel */

void kernel_main(void)
{
    terminal_init();

    terminal_writestring("Ciao mondo\n1\t12\t123\t1234\t12345\n");
}