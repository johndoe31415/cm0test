.PHONY: all clean openocd ocdconsole gdb reset bindump program 

TARGETS := cm0test cm0test.bin

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
#CFLAGS += -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb
CFLAGS += -ffunction-sections -fdata-sections
LDFLAGS := -Tstm32f030.ld
WRITE_ADDR := 0x08000000
LDFLAGS += -Wl,--gc-sections
STATICLIBS := 

OBJS := main.o ivt.o

all: $(TARGETS)

clean:
	rm -f $(OBJS) $(TARGETS)
	rm -f cm0test.sym flash.bin

openocd:
	openocd -f interface/jlink.cfg -c 'transport select swd' -f target/stm32f0x.cfg

ocdconsole:
	telnet 127.0.0.1 4444

gdb:
	$(GDB) -ex "target extended-remote :3333"

reset:
	echo "halt; reset" | nc -N 127.0.0.1 4444

bindump:
	echo "halt; dump_image flash.bin 0x8000000 0x8000" | nc -N 127.0.0.1 4444

program: cm0test.bin
	echo "halt; program cm0test.bin 0x8000000 reset" | nc -N 127.0.0.1 4444

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
