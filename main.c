#include <stdint.h>
#include <stdbool.h>
#include "main.h"

void default_fault_handler(void) {
	while (true);
}

void SystemInit(void) {
}

int main(void) {
	while (true) {
		volatile uint32_t *x = (volatile uint32_t*)0x12345678;
		*x = (*x) + 0xabcdef12;
	}
}
