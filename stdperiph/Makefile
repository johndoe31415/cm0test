.PHONY: all clean extract

SUBDIR := STM32F0xx_StdPeriph_Lib_V1.5.0

TARGETS := stdperiph.a

PREFIX := arm-none-eabi-
CC := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
AR := $(PREFIX)ar
GDB := $(PREFIX)gdb

CFLAGS := $(CFLAGS) -std=c11
CFLAGS += -Wall -Wmissing-prototypes -Wstrict-prototypes -Werror=implicit-function-declaration -Werror=format -Wimplicit-fallthrough -Wshadow
CFLAGS += -Os -g3
CFLAGS += -mcpu=cortex-m0 -mthumb
CFLAGS += -include configuration.h
CFLAGS += -I$(SUBDIR)/Libraries/STM32F0xx_StdPeriph_Driver/inc -I$(SUBDIR)/Libraries/CMSIS/Device/ST/STM32F0xx/Include -I$(SUBDIR)/Libraries/CMSIS/Include
CFLAGS += -ffunction-sections -fdata-sections

SRCS := $(wildcard $(SUBDIR)/Libraries/STM32F0xx_StdPeriph_Driver/src/*.c)
OBJS := $(SRCS:%.c=%.o)

all: $(TARGETS)

clean:
	rm -f $(OBJS) $(TARGETS)
	rm -f cm0test.sym flash.bin

extract:
	rm -fr $(SUBDIR)
	rm -f include system cmsis
	unzip en.stm32f0_stdperiph_lib.zip
	ln -sf $(SUBDIR)/Libraries/STM32F0xx_StdPeriph_Driver/inc include
	ln -sf $(SUBDIR)/Libraries/CMSIS/Device/ST/STM32F0xx/Include system
	ln -sf $(SUBDIR)/Libraries/CMSIS/Include cmsis

stdperiph.a: $(OBJS)
	$(AR) cm $@ $^

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.s.o:
	$(CC) $(CFLAGS) -c -o $@ $<
