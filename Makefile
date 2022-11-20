.PHONY: all clean build_spl openocd ocdconsole gdb reset flashdump program stlink-read stlink-pgm

TARGETS := cm0test cm0test.bin

PREFIX := arm-none-eabi-
CC := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
AR := $(PREFIX)ar
GDB := $(PREFIX)gdb

#LDSCRIPT := stm32f030.ld
#STATICLIBS := stdperiph/stdperiph.a

LDSCRIPT := stm32g031j6m6.ld
STATICLIBS := cube/stm32cube.a

CFLAGS := $(CFLAGS) -std=c11
CFLAGS += -Wall -Wmissing-prototypes -Wstrict-prototypes -Werror=implicit-function-declaration -Werror=format -Wimplicit-fallthrough -Wshadow
CFLAGS += -Os -g3
CFLAGS += -mcpu=cortex-m0 -mthumb
CFLAGS += -ffunction-sections -fdata-sections
#CFLAGS += -include stdperiph/configuration.h -Istdperiph/include -Istdperiph/system -Istdperiph/cmsis
CFLAGS += -DSTM32G031xx -I cube/include -Icube/system -Icube/cmsis -Icube
LDFLAGS := -T$(LDSCRIPT)
WRITE_ADDR := 0x08000000
LDFLAGS += -Wl,--gc-sections

OBJS := main.o system.o ivt.o

all: $(TARGETS)

clean:
	rm -f $(OBJS) $(TARGETS)
	rm -f cm0test.sym flash.bin

stdperiph:
	make -C stdperiph

openocd:
	openocd -f interface/jlink.cfg -c 'transport select swd' -f target/stm32f0x.cfg

stlink-read:
	st-flash read flash.bin 0x8000000 32k

stlink-pgm: cm0test.bin
	st-flash write cm0test.bin 0x8000000

stlink-pgm-res: cm0test.bin
	st-flash --connect-under-reset write cm0test.bin 0x8000000

ocdconsole:
	telnet 127.0.0.1 4444

gdb:
	$(GDB) -ex "target extended-remote :3333" cm0test

reset:
	echo "reset halt; reset run" | nc -N 127.0.0.1 4444

flashdump:
	echo "reset halt; dump_image flash.bin 0x8000000 0x8000" | nc -N 127.0.0.1 4444

program: cm0test.bin
	echo "reset halt; program cm0test.bin 0x8000000 reset" | nc -N 127.0.0.1 4444

cm0test: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) $(STATICLIBS)

cm0test.bin: cm0test
	$(OBJCOPY) -O binary $< $@

cm0test.sym: cm0test.c
	$(CC) $(CFLAGS) -E -dM -o $@ $<

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.s.o:
	$(CC) $(CFLAGS) -c -o $@ $<
