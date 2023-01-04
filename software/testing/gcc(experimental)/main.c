#include <lcd.h>
#include <utils.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#define _OPEN_SYS_ITOA_EXT

void lcd_init()
{
	lcd_function_set(true, true, false);   // Set 8 bit mode, 2-line display, 5x8 font
	lcd_display_control(true, true, true); // Display on, cursor on, blink on
	lcd_entry_mode(true, false);		   // Increment and shift cursor; don't shift display
	lcd_return_home();
}

void main() // does memtest and prints out 512K
{
	lcd_init();
	uint16_t ramSize = ramtest();
	char *buffer;
	utoa(ramSize, buffer, 10);
	lcd_print_string(buffer);
	lcd_send_letter('K');
}