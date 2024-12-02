# SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)
include lib/vars.mk

OUTPUT := .output

LIBBPF_SRC := $(abspath ./lib/libbpf/src)
LIBBPF_OBJ := $(abspath $(OUTPUT)/libbpf.a)
LIBBPF_PKGCONFIG := $(abspath $(OUTPUT)/pkgconfig)

BPFTOOL_SRC := $(abspath ./lib/bpftool/src)
BPFTOOL_OUTPUT ?= $(abspath $(OUTPUT)/bpftool)
BPFTOOL ?= $(BPFTOOL_OUTPUT)/bootstrap/bpftool

LIBLOG_OBJ := $(abspath $(OUTPUT)/liblog.o)
LIBLOG_SRC := $(abspath ./lib/liblog/src/log.c)
LIBLOG_HDR := $(abspath ./lib/liblog/src/)

# Use our own libbpf API headers and Linux UAPI headers distributed with
# libbpf to avoid dependency on system-wide headers, which could be missing or
# outdated
INCLUDES := -I$(OUTPUT) -I./lib/libbpf/include/uapi -I$(LIBLOG_HDR)

APPS := simple drop pass_drop

.PHONY: all
all: $(LIBLOG_OBJ) $(LIBBPF_OBJ) $(BPFTOOL) $(APPS)

.PHONY: clean clean-apps
clean clean-apps:
	rm -f $(APPS) || true
	rm -rf $(patsubst %,$(OUTPUT)/%,$(APPS)) || true

.PHONY: clean-all
clean-all: clean
	rm -rf $(OUTPUT) || true


define allow-override
  $(if $(or $(findstring environment,$(origin $(1))),\
            $(findstring command line,$(origin $(1)))),,\
    $(eval $(1) = $(2)))
endef

$(call allow-override,CC,$(CROSS_COMPILE)cc)
$(call allow-override,LD,$(CROSS_COMPILE)ld)

$(OUTPUT) $(patsubst %,$(OUTPUT)/%,$(APPS)) $(OUTPUT)/libbpf $(BPFTOOL_OUTPUT):
	mkdir -p $@

# Build libbpf
$(LIBBPF_OBJ): $(wildcard $(LIBBPF_SRC)/*.[ch] $(LIBBPF_SRC)/Makefile) | $(OUTPUT)/libbpf
	@echo "=== Building libbpf"
	$(MAKE) -C $(LIBBPF_SRC) BUILD_STATIC_ONLY=1    \
		    OBJDIR=$(dir $@)/libbpf DESTDIR=$(dir $@)	\
		    INCLUDEDIR= LIBDIR= UAPIDIR=              \
		    install

# Build bpftool
$(BPFTOOL): | $(BPFTOOL_OUTPUT)
	@echo "=== Building bpftool"
	$(MAKE) ARCH= CROSS_COMPILE= OUTPUT=$(BPFTOOL_OUTPUT)/ -C $(BPFTOOL_SRC) bootstrap

# Build liblog
$(LIBLOG_OBJ): | $(OUTPUT)
	@echo "=== Building liblog"
	$(CC) $(CFLAGS) $(INCLUDES) -c $(LIBLOG_SRC) -o $@

define app_template =
$$(OUTPUT)/$(1)/$(1).o: $$(wildcard src/$(1)/*.c) $$(wildcard src/$(1)/ebpf/*.bpf.c) | $$(LIBBPF_OBJ) $$(LIBLOG_OBJ) $$(BPFTOOL)
	make -C src/$(1) all

$(1): $$(OUTPUT)/$(1)/$(1).o $$(LIBBPF_OBJ) $$(LIBLOG_OBJ) | $$(OUTPUT)/$(1)
	@echo ">>> Compiling app" $$@
	$$(CC) $(CFLAGS) $$^ $$(ALL_LDFLAGS) -lelf -lz -o $$@
endef
$(foreach f,$(APPS),$(eval $(call app_template,$(f))))

# keep intermediate (.skel.h, .bpf.o, etc) targets
.SECONDARY:
