/**
 *	cm0test - Hello world program for Cortex-M0.
 *	Copyright (C) 2019-2019 Johannes Bauer
 *
 *	This file is part of cm0test.
 *
 *	cm0test is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation; this program is ONLY licensed under
 *	version 3 of the License, later versions are explicitly excluded.
 *
 *	cm0test is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with cm0test; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *	Johannes Bauer <JohannesBauer@gmx.de>
**/

#include <stdbool.h>
#include <stm32g0xx_hal_rcc.h>
#include <stm32g0xx_hal_gpio.h>
#include "system.h"

void default_fault_handler(void) {
	while (true);
}

static void clock_switch_hsi_pll(void) {
#if 0
	/* Set PLL multipler to x6 (8 MHz HSI * 6 = 48 MHz) */
	RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_PLLMUL) | RCC_CFGR_PLLMUL6;

	/* Enable PLL */
	RCC->CR |= RCC_CR_PLLON;

	/* Wait for PLL to become ready */
	while (!(RCC->CR & RCC_CR_PLLRDY));

	/* Switch clock source to PLL */
	RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_SW) | RCC_CFGR_SW_PLL;

	/* Wait for PLL to become active */
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_PLL);
#endif
}

void EarlySystemInit(void) {
	clock_switch_hsi_pll();
}

static void init_gpio(void) {
//	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);
	GPIO_InitTypeDef gpio_init_struct = {
			.Pin = GPIO_PIN_12,
			.Mode = GPIO_MODE_OUTPUT_PP,
			.Speed = GPIO_SPEED_FREQ_HIGH,
			.Pull = GPIO_PULLUP,
	};
	HAL_GPIO_Init(GPIOA, &gpio_init_struct);
}

void SystemInit(void) {
	init_gpio();
}
