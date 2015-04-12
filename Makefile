EXTRA_CFLAGS += $(USER_EXTRA_CFLAGS)
EXTRA_CFLAGS += -O1
#EXTRA_CFLAGS += -O3
#EXTRA_CFLAGS += -Wall
#EXTRA_CFLAGS += -Wextra
#EXTRA_CFLAGS += -Werror
#EXTRA_CFLAGS += -pedantic
#EXTRA_CFLAGS += -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes

EXTRA_CFLAGS += -Wno-unused-variable
EXTRA_CFLAGS += -Wno-unused-value
EXTRA_CFLAGS += -Wno-unused-label
EXTRA_CFLAGS += -Wno-unused-parameter
EXTRA_CFLAGS += -Wno-unused-function
EXTRA_CFLAGS += -Wno-unused

EXTRA_CFLAGS += -Wno-uninitialized

MACHINE=$(shell uname -m)
ifndef KERNEL_DIR
KERNEL_DIR:=/lib/modules/`uname -r`/build
endif

file_exist=$(shell test -f $(1) && echo yes || echo no)

# test for 2.6 or 2.4 kernel
ifeq ($(call file_exist,$(KERNEL_DIR)/Rules.make), yes)
PATCHLEVEL:=4
else
PATCHLEVEL:=6
endif

KERNOBJ:=am335x_bandgap.o

# Name of module
ifeq ($(PATCHLEVEL),6)
MODULE:=am335x_bandgap.ko
else
MODULE:=am335x_bandgap.o
endif

ALL_TARGETS = $(MODULE)

all: $(ALL_TARGETS)

module: $(MODULE)

# For Kernel 2.6, we now use the "recommended" way to build kernel modules
obj-m := am335x_bandgap.o
# am335x_bandgap-objs := am335x_bandgap.o

$(MODULE): am335x_bandgap.c
	@echo "Building for Kernel Patchlevel $(PATCHLEVEL)"
	$(MAKE) modules -C $(KERNEL_DIR) M=$(CURDIR)

clean:
	rm -rf $(ALL_TARGETS) *.o *.ko Module.symvers am335x_bandgap.mod.c modules.order .am335x_bandgap* .tmp*

dist: clean
	cd .. ; \
	tar -cf - am335x_bandgap/{Makefile,*.[ch],CHANGELOG,README} | \
	bzip2 -9 > $(HOME)/redhat/SOURCES/am335x_bandgap.tar.bz2
