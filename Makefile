#=============================================================================
#
# Makefile
#
#-----------------------------------------------------------------------------
#
# DHBW Ravensburg - Campus Friedrichshafen
#
# Vorlesung Systemnahe Programmierung / Verteilte Systeme
#
# Author: Ralf Reutemann
#
#=============================================================================

CC          = gcc
LD          = ld
NASM        = nasm
NASMOPT64   = -g -f elf64 -F dwarf
LDOPT64     =
INCDIR      = ./

OS          := $(shell uname -s)
ARCH        := $(shell uname -m)

TARGETS     = wordcount64

# Cross-compile for x86_64 target on Apple M1
ifeq ($(OS)_$(ARCH), Darwin_arm64)
NASMOPT64   = -g -f macho64
LDOPT64     = -macos_version_min 10.15 -arch x86_64 -static
TARGETS     = toupper64
endif

.PHONY: all
all: $(TARGETS)

wordcount64: wordcount64.o uint_to_ascii64.o
	$(LD) $(LDOPT64) -o $@ $^

wordcount64.o : $(INCDIR)/syscall.inc

%64.o : %64.asm
	$(NASM) $(NASMOPT64) -I$(INCDIR) -l $(basename $<).lst -o $@ $<

%64 : %64.o
	$(LD) $(LDOPT64) -o $@ $<

.PHONY: clean
clean:
	rm -f *.o *.lst $(TARGETS)

