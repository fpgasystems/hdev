#
# Shared file to be used by the different apps' makefiles.
# Implements simple rules to build bpf sources and normal sources.
#
# Directory structure:
# - ./*:      normal C sources
# - ./ebpf/*: bpf sources
#
# Variables required before inclusion:
# - CURRENT_APP: name of the app
# - BPF_SRC: array containing the names of BPF files to be compiled
# - SRC: array containing the names of C files to be compiled
#

OUTPUT := ../../.output
LIBLOG_HDR := ../../lib/liblog/src/
LIBBPF_OBJ := $(abspath $(OUTPUT)/libbpf.a)
BPFTOOL ?= $(abspath $(OUTPUT)/bpftool)/bootstrap/bpftool

# Use our own libbpf API headers and Linux UAPI headers distributed with
# libbpf to avoid dependency on system-wide headers, which could be missing or
# outdated
INCLUDES := -I$(OUTPUT) -I../../lib/libbpf/include/uapi -I$(LIBLOG_HDR)

OUT = $(OUTPUT)/$(CURRENT_APP)

.PHONY: all
all: $(OUT) $(OUT)/ebpf $(OUT)/ebpf/$(BPF_SRC:.c=.o) $(OUT)/$(SRC:.c=.o)

$(OUT) $(OUT)/ebpf:
	mkdir -p $@

# Build BPF code
$(OUT)/ebpf/%.bpf.o: ebpf/%.bpf.c $(LIBBPF_OBJ) $(wildcard %.h) $(VMLINUX)
	@echo ">>> Compiling BPF into" $@
	$(CLANG) -g -O2 -target bpf -D__TARGET_ARCH_$(ARCH) $(INCLUDES) $(CLANG_BPF_SYS_INCLUDES) -c $(filter %.c,$^) -o $@
	$(LLVM_STRIP) -g $@ # strip useless DWARF info

# Generate BPF skeletons
$(OUT)/%.skel.h: $(OUT)/ebpf/%.bpf.o | $(BPFTOOL)
	@echo ">>> Generating BPF skeleton for" $<
	$(BPFTOOL) gen skeleton $< > $@

# Build app
$(OUT)/%.o: $(OUT)/%.skel.h %.c $(wildcard %.h)
	@echo ">>> CC" $@
	$(CC) $(CFLAGS) $(INCLUDES) -I$(dir $@) -c $(filter %.c,$^) -o $@

.SECONDARY:
