.PHONY: all clean readflash program bindump gdb gdbserver console tests
.SUFFIXES: .txt

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
	rm -f cm0test.sym

gdb:
	$(GDB) -d ext-st -d cube cm0test -ex "py import sys; sys.path.insert(0, '.'); import cm4gdb" -ex "target extended-remote :4242"

console:
	picocom --baud 115200 /dev/ttyUSB*

reset:
	$(STFLASH) reset

program: cm0test.bin
	-killall st-util
	$(STFLASH) --reset write $< $(WRITE_ADDR)

bindump: cm0test.bin
	$(OBJDUMP) -b binary -m armv3m -D $<

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
