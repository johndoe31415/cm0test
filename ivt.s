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

.syntax unified
.cpu cortex-m0
.fpu softvfp
.thumb

.macro _asm_memset
	# r0: destination
	# r1: pattern
	# r2: size in bytes, must be >= 0 and divisible by 4
	#ands r2, #~0x03
	#cbz r2, _asm_memset_end_\@
	cmp r2, #0
	beq _asm_memset_end_\@
	subs r2, #4

	_asm_memset_loop_\@:
		str r1, [r0, r2]
		#cbz r2, _asm_memset_end_\@
		cmp r2, #0
		beq _asm_memset_end_\@
		subs r2, #4
	b _asm_memset_loop_\@
	_asm_memset_end_\@:
.endm

.macro _asm_memcpy
	# r0: destination address
	# r1: source address
	# r2: size in bytes, must be >= 0 and divisible by 4
	#ands r2, #~0x03
	#cbz r2, _asm_memcpy_end_\@
	cmp r2, #0
	beq _asm_memcpy_end_\@
	subs r2, #4

	_asm_memcpy_loop_\@:
		ldr r3, [r1, r2]
		str r3, [r0, r2]
		#cbz r2, _asm_memcpy_end_\@
		cmp r2, #0
		beq _asm_memcpy_end_\@
		subs r2, #4
	b _asm_memcpy_loop_\@
	_asm_memcpy_end_\@:
.endm

.macro _semihosting_exit
	ldr r0, =0x18
	ldr r1, =0x20026
	bkpt #0xab
.endm

.section .text
.type Reset_Handler, %function
Reset_Handler:
	bl EarlySystemInit

	# Painting of all RAM
	ldr r0, =_sram
	ldr r1, =0xdeadbeef
	ldr r2, =_eram
	subs r2, r0
	_asm_memset

	# Load .data section
	ldr r0, =_sdata
	ldr r1, =_sidata
	ldr r2, =_edata
	subs r2, r0
	_asm_memcpy

	# Zero .bss section
	ldr r0, =_sbss
	ldr r1, =0
	ldr r2, =_ebss
	subs r2, r0
	_asm_memset

#	_semihosting_exit

	ldr r0, =0x57a0057a
	mov lr, r0
	bl SystemInit
	bl main

	_exit_loop:
	b _exit_loop
.size Reset_Handler, .-Reset_Handler
.global Reset_Handler

.section .text, "ax", %progbits
Default_Handler:
       b default_fault_handler
.size Default_Handler, .-Default_Handler
.global Default_Handler


.section .vectors, "a", %progbits
.type vectors, %object
vectors:
	.word	_eram
	.word	Reset_Handler		// 0x4
	.word	NMI_Handler		// 0x8
	.word	HardFault_Handler		// 0xc
	.word	0		// 0x10: Reserved
	.word	0		// 0x14: Reserved
	.word	0		// 0x18: Reserved
	.word	0		// 0x1c: Reserved
	.word	0		// 0x20: Reserved
	.word	0		// 0x24: Reserved
	.word	0		// 0x28: Reserved
	.word	SVCall_Handler		// 0x2c
	.word	0		// 0x30: Reserved
	.word	0		// 0x34: Reserved
	.word	PendSV_Handler		// 0x38
	.word	SysTick_Handler		// 0x3c
	.word	WWDG_Handler		// 0x40
	.word	PVD_Handler		// 0x44
	.word	RTC_TAMP_Handler		// 0x48
	.word	FLASH_Handler		// 0x4c
	.word	RCC_CRS_Handler		// 0x50
	.word	EXTI0_1_Handler		// 0x54
	.word	EXTI2_3_Handler		// 0x58
	.word	EXTI4_15_Handler		// 0x5c
	.word	UCPDF1_UCPD2_USB_Handler		// 0x60
	.word	DMA1_CH1_Handler		// 0x64
	.word	DMA1_CH2_3_Handler		// 0x68
	.word	DMA1_CH4_5_DMAMUX_DMA2_CH1_2_3_4_5_Handler		// 0x6c
	.word	ADC_COMP_Handler		// 0x70
	.word	TIM1_BRK_UP_TRG_COM_Handler		// 0x74
	.word	TIM1_CC_Handler		// 0x78
	.word	TIM2_Handler		// 0x7c
	.word	TIM3_TIM4_Handler		// 0x80
	.word	TIM6_DAC_LPTIM1_Handler		// 0x84
	.word	TIM7_LPTIM2_Handler		// 0x88
	.word	TIM14_Handler		// 0x8c
	.word	TIM15_Handler		// 0x90
	.word	TIM16_FDCAN_IT0_Handler		// 0x94
	.word	TIM17_FDCAN_IT1_Handler		// 0x98
	.word	I2C1_Handler		// 0x9c
	.word	I2C2_I2C3_Handler		// 0xa0
	.word	SPI1_Handler		// 0xa4
	.word	SPI2_SPI3_Handler		// 0xa8
	.word	USART1_Handler		// 0xac
	.word	USART2_LPUART2_Handler		// 0xb0
	.word	USART3_4_5_6_LPUART1_Handler		// 0xb4
	.word	CEC_Handler		// 0xb8
	.word	AES_RNG_Handler		// 0xbc

	.weak	NMI_Handler
	.thumb_set	NMI_Handler, Default_Handler
	.weak	HardFault_Handler
	.thumb_set	HardFault_Handler, Default_Handler
	.weak	SVCall_Handler
	.thumb_set	SVCall_Handler, Default_Handler
	.weak	PendSV_Handler
	.thumb_set	PendSV_Handler, Default_Handler
	.weak	SysTick_Handler
	.thumb_set	SysTick_Handler, Default_Handler
	.weak	WWDG_Handler
	.thumb_set	WWDG_Handler, Default_Handler
	.weak	PVD_Handler
	.thumb_set	PVD_Handler, Default_Handler
	.weak	RTC_TAMP_Handler
	.thumb_set	RTC_TAMP_Handler, Default_Handler
	.weak	FLASH_Handler
	.thumb_set	FLASH_Handler, Default_Handler
	.weak	RCC_CRS_Handler
	.thumb_set	RCC_CRS_Handler, Default_Handler
	.weak	EXTI0_1_Handler
	.thumb_set	EXTI0_1_Handler, Default_Handler
	.weak	EXTI2_3_Handler
	.thumb_set	EXTI2_3_Handler, Default_Handler
	.weak	EXTI4_15_Handler
	.thumb_set	EXTI4_15_Handler, Default_Handler
	.weak	UCPDF1_UCPD2_USB_Handler
	.thumb_set	UCPDF1_UCPD2_USB_Handler, Default_Handler
	.weak	DMA1_CH1_Handler
	.thumb_set	DMA1_CH1_Handler, Default_Handler
	.weak	DMA1_CH2_3_Handler
	.thumb_set	DMA1_CH2_3_Handler, Default_Handler
	.weak	DMA1_CH4_5_DMAMUX_DMA2_CH1_2_3_4_5_Handler
	.thumb_set	DMA1_CH4_5_DMAMUX_DMA2_CH1_2_3_4_5_Handler, Default_Handler
	.weak	ADC_COMP_Handler
	.thumb_set	ADC_COMP_Handler, Default_Handler
	.weak	TIM1_BRK_UP_TRG_COM_Handler
	.thumb_set	TIM1_BRK_UP_TRG_COM_Handler, Default_Handler
	.weak	TIM1_CC_Handler
	.thumb_set	TIM1_CC_Handler, Default_Handler
	.weak	TIM2_Handler
	.thumb_set	TIM2_Handler, Default_Handler
	.weak	TIM3_TIM4_Handler
	.thumb_set	TIM3_TIM4_Handler, Default_Handler
	.weak	TIM6_DAC_LPTIM1_Handler
	.thumb_set	TIM6_DAC_LPTIM1_Handler, Default_Handler
	.weak	TIM7_LPTIM2_Handler
	.thumb_set	TIM7_LPTIM2_Handler, Default_Handler
	.weak	TIM14_Handler
	.thumb_set	TIM14_Handler, Default_Handler
	.weak	TIM15_Handler
	.thumb_set	TIM15_Handler, Default_Handler
	.weak	TIM16_FDCAN_IT0_Handler
	.thumb_set	TIM16_FDCAN_IT0_Handler, Default_Handler
	.weak	TIM17_FDCAN_IT1_Handler
	.thumb_set	TIM17_FDCAN_IT1_Handler, Default_Handler
	.weak	I2C1_Handler
	.thumb_set	I2C1_Handler, Default_Handler
	.weak	I2C2_I2C3_Handler
	.thumb_set	I2C2_I2C3_Handler, Default_Handler
	.weak	SPI1_Handler
	.thumb_set	SPI1_Handler, Default_Handler
	.weak	SPI2_SPI3_Handler
	.thumb_set	SPI2_SPI3_Handler, Default_Handler
	.weak	USART1_Handler
	.thumb_set	USART1_Handler, Default_Handler
	.weak	USART2_LPUART2_Handler
	.thumb_set	USART2_LPUART2_Handler, Default_Handler
	.weak	USART3_4_5_6_LPUART1_Handler
	.thumb_set	USART3_4_5_6_LPUART1_Handler, Default_Handler
	.weak	CEC_Handler
	.thumb_set	CEC_Handler, Default_Handler
	.weak	AES_RNG_Handler
	.thumb_set	AES_RNG_Handler, Default_Handler

.size vectors, .-vectors
.global vectors
