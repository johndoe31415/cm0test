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
#include <stm32g0xx_hal_dma.h>
#include <stm32g0xx_hal_tim.h>
#include <stm32g0xx_ll_tim.h>
#include "system.h"

void default_fault_handler(void) {
	while (true);
}

void EarlySystemInit(void) {
	/* VCO must be between 64..344 MHz, fVCO = fIN * N / M */
	/* Set PLL N = 8, M = 1, fVCO = 128 MHz */
	/* Set PLLR divider to 1/2, so that SYSCLK = 64 MHz */
	RCC->PLLCFGR = (8 << RCC_PLLCFGR_PLLN_Pos) | RCC_PLLCFGR_PLLREN | (1 << RCC_PLLCFGR_PLLR_Pos) | RCC_PLLCFGR_PLLSRC_HSI;

	/* Enable PLL */
	RCC->CR |= RCC_CR_PLLON;

	/* Wait for PLL to become ready */
	while (!(RCC->CR & RCC_CR_PLLRDY));

	/* Adjust FLASH to 2 waitstates (3 HCLK cycles), since >48 MHz */
	FLASH->ACR |= 2 << FLASH_ACR_LATENCY_Pos;

	/* Switch clock source to PLL */
	RCC->CFGR = (RCC->CFGR & ~RCC_CFGR_SW) | RCC_SYSCLKSOURCE_PLLCLK;

	/* Wait for PLL to become active */
	while ((RCC->CFGR & RCC_CFGR_SWS) != RCC_SYSCLKSOURCE_STATUS_PLLCLK);
}

static void init_gpio(void) {
	__HAL_RCC_GPIOA_CLK_ENABLE();
	{
		GPIO_InitTypeDef gpio_init_struct = {
				.Pin = GPIO_PIN_12,
				.Mode = GPIO_MODE_OUTPUT_PP,
				.Speed = GPIO_SPEED_FREQ_HIGH,
				.Pull = GPIO_PULLUP,
		};
		HAL_GPIO_Init(GPIOA, &gpio_init_struct);
	}
	{
		GPIO_InitTypeDef gpio_init_struct = {
				.Pin = GPIO_PIN_1,
				.Mode = GPIO_MODE_INPUT,
				.Speed = GPIO_SPEED_FREQ_HIGH,
				.Pull = GPIO_PULLUP,
		};
		HAL_GPIO_Init(GPIOA, &gpio_init_struct);
	}
}

void SystemInit(void) {
	init_gpio();
}
