.PHONY: all clean extract

SUBDIR := STM32CubeG0

TARGETS := stm32cube.a

PREFIX := arm-none-eabi-
CC := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
AR := $(PREFIX)ar
GDB := $(PREFIX)gdb

CFLAGS := $(CFLAGS) -std=c11 -DSTM32G031xx
CFLAGS += -Wall -Wmissing-prototypes -Wstrict-prototypes -Werror=implicit-function-declaration -Werror=format -Wimplicit-fallthrough -Wshadow
CFLAGS += -Os -g3
CFLAGS += -mcpu=cortex-m0 -mthumb
CFLAGS += -I$(SUBDIR)/Drivers/CMSIS/Device/ST/STM32G0xx/Include -I$(SUBDIR)/Drivers/CMSIS/Include -I$(SUBDIR)/Drivers/CMSIS/Core/Include -I$(SUBDIR)/Drivers/STM32G0xx_HAL_Driver/Inc -I.
CFLAGS += -ffunction-sections -fdata-sections

SRCS := $(wildcard $(SUBDIR)/Drivers/STM32G0xx_HAL_Driver/Src/*.c)
OBJS := $(SRCS:%.c=%.o)

all: $(TARGETS)

clean:
	rm -f $(OBJS) $(TARGETS)
	rm -f cm0test.sym flash.bin

extract:
	-git clone https://github.com/STMicroelectronics/STM32CubeG0
	rm -f STM32CubeG0/Drivers/STM32G0xx_HAL_Driver/Src/*_template.c
	ln -s $(SUBDIR)/Drivers/CMSIS/Include cmsis
	ln -s $(SUBDIR)/Drivers/CMSIS/Device/ST/STM32G0xx/Include system
	ln -s $(SUBDIR)/Drivers/STM32G0xx_HAL_Driver/Inc include
	ln -s $(SUBDIR)/Projects/STM32G0316-DISCO/Examples/GPIO/GPIO_IOToggle/Inc/stm32g0xx_hal_conf.h .


stm32cube.a: $(OBJS)
	$(AR) cm $@ $^

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.s.o:
	$(CC) $(CFLAGS) -c -o $@ $<
