-include $(topdir)/mk/config.mk

# the real guts of this file.
COMPILE = $(CC) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) \
	$(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
LTCOMPILE = $(LIBTOOL) --tag=CC --mode=compile $(CC) $(DEFS) \
	$(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) \
	$(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(LIBTOOL) --tag=CC --mode=link $(CCLD) $(AM_CFLAGS) $(CFLAGS) \
	$(AM_LDFLAGS) $(LDFLAGS) -o $@
CXXCOMPILE = $(CXX) $(DEFS) $(DEFAULT_INCLUDES) $(INCLUDES) \
	$(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CXXFLAGS) $(CXXFLAGS)
LTCXXCOMPILE = $(LIBTOOL) --tag=CXX --mode=compile $(CXX) $(DEFS) \
	$(DEFAULT_INCLUDES) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) \
	$(AM_CXXFLAGS) $(CXXFLAGS)
CXXLD = $(CXX)
CXXLINK = $(LIBTOOL) --tag=CXX --mode=link $(CXXLD) $(AM_CXXFLAGS) \
	$(CXXFLAGS) $(AM_LDFLAGS) $(LDFLAGS) -o $@

RECURSIVE_TARGETS = all-recursive check-recursive dvi-recursive \
	html-recursive info-recursive install-data-recursive \
	install-exec-recursive install-info-recursive \
	install-recursive installcheck-recursive installdirs-recursive \
	pdf-recursive ps-recursive uninstall-info-recursive \
	uninstall-recursive

all: all-recursive
install: install-recursive
clean: clean-recursive

$(RECURSIVE_TARGETS):
	@failcom='exit 1'; \
	for f in x $$MAKEFLAGS; do \
	  case $$f in \
	    *=* | --[!k]*);; \
	    *k*) failcom='fail=yes';; \
	  esac; \
	done; \
	dot_seen=no; \
	target=`echo $@ | sed s/-recursive//`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $$target in $$subdir"; \
	  if test "$$subdir" = "."; then \
	    flags="$(AM_MAKEFLAGS) mk_dir=../$(mk_dir)"; \
	    dot_seen=yes; \
	    local_target="$$target-am"; \
	  else \
	    flags="$(AM_MAKEFLAGS) mk_dir=../$(mk_dir)"; \
	    local_target="$$target"; \
	  fi; \
	  (cd $$subdir && $(MAKE) $(flags) $$local_target) \
	  || eval $$failcom; \
	done; \
	if test "$$dot_seen" = "no"; then \
	  flags="$(AM_MAKEFLAGS) mk_dir=$(mk_dir)"; \
	  $(MAKE) $(flags) "$$target-am" || exit 1; \
	fi; test -z "$$fail"

mostlyclean-recursive clean-recursive distclean-recursive \
maintainer-clean-recursive:
	@failcom='exit 1'; \
	for f in x $$MAKEFLAGS; do \
	  case $$f in \
	    *=* | --[!k]*);; \
	    *k*) failcom='fail=yes';; \
	  esac; \
	done; \
	dot_seen=no; \
	case "$@" in \
	  distclean-* | maintainer-clean-*) list='$(DIST_SUBDIRS)' ;; \
	  *) list='$(SUBDIRS)' ;; \
	esac; \
	rev=''; for subdir in $$list; do \
	  if test "$$subdir" = "."; then :; else \
	    rev="$$subdir $$rev"; \
	  fi; \
	done; \
	rev="$$rev ."; \
	target=`echo $@ | sed s/-recursive//`; \
	for subdir in $$rev; do \
	  echo "Making $$target in $$subdir"; \
	  if test "$$subdir" = "."; then \
	    local_target="$$target-am"; \
	  else \
	    local_target="$$target"; \
	  fi; \
	  (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$local_target) \
	  || eval $$failcom; \
	done && test -z "$$fail"

# these are empty, as they're filled in by the various templates below
all-am::
install-am::
clean-am::

# for the templates, the following args are passed in
# $(1) = the target name
# $(2) = the directory to install to
#
# for instance, if you had this in your Makefile:
#
# bindir=/usr/bin
# bin_PROGRAMS=foo
#
#   $(1) would be foo
#   $(2) would be /usr/bin

define __af_PROGRAM_template
$(eval $(1)_OBJECTS:=$($(1)_SOURCES:%.c=%.o))
all-am:: $(1)

install-am::

clean-am::
	rm -f $(1) $($(1)_OBJECTS)

$(1): $($(1)_SOURCES:%.c=%.o)
	$(LINK.o) -o $(1) $($(1)_OBJECTS)

endef

define __af_LIBRARY_template
all-am:: $(1)

install-am::

endef

define __af_LTLIBRARY_template
$(eval $(1)_OBJECTS:=$($(1)_SOURCES:%.c=%.lo))
all-am:: $(1)

install-am::

$(1):  $($(1)_OBJECTS)
	$(LINK) -rpath $(2) $($(1)_LDFLAGS) $($(1)_OBJECTS) $($(1)_LIBADD) $(LIBS)

endef

define __af_DATUM_template
# no all-am target, since there's nothing to compile

install-am::
	$(MKDIR) -p $(2)
	$(INSTALL) -m 0755 -c $(1) $(2)/$(1)
endef

define __af_SCRIPT_template
# no all-am target, since there's nothing to compile

install-am::
	$(MKDIR) -p $(2)
	$(INSTALL) -m 0755 -c $(1) $(2)/$(1)
endef

__af_PROGRAM_VARIABLES:=$(filter %_PROGRAMS, $(.VARIABLES))
__af_LIBRARIES_VARIABLES:=$(filter %_LIBRARIES, $(.VARIABLES))
__af_LTLIBRARIES_VARIABLES:=$(filter %_LTLIBRARIES, $(.VARIABLES))
__af_DATA_VARIABLES:=$(filter %_DATA, $(.VARIABLES))
__af_SCRIPTS_VARIABLES:=$(filter %_SCRIPTS, $(.VARIABLES))

$(foreach prog,$(__af_PROGRAM_VARIABLES),$(eval $(call __af_PROGRAM_template,$($(prog)), $($(subst _PROGRAMS,,$(prog))dir))))
$(foreach lib,$(__af_LIBRARIES_VARIABLES),$(eval $(call __af_LIBRARY_template,$($(lib)), $($(subst _LIBRARIES,,$(lib))dir))))
$(foreach ltlib,$(__af_LTLIBRARIES_VARIABLES),$(eval $(call __af_LTLIBRARY_template,$($(ltlib)), $($(subst _LTLIBRARIES,,$(ltlib))dir))))
$(foreach datum,$(__af_DATA_VARIABLES),$(eval $(call __af_DATUM_template,$($(datum)), $($(subst _DATA,,$(datum))dir))))
$(foreach script,$(__af_SCRIPTS_VARIABLES),$(eval $(call __af_SCRIPT_template,$($(script)), $($(subst _SCRIPTS,,$(script))dir))))

.PHONY: $(RECURSIVE_TARGETS) mostlyclean-recursive clean-recursive distclean-recursive \
	maintainer-clean-recursive

# suffix rules

define __af_fastdepCC_template
if $(4) -MT $(2) -MD -MP -MF "$(DEPDIR)/$(1).Tpo" -c -o $(2) $(3); \
then mv -f "$(DEPDIR)/$(1).Tpo" "$(DEPDIR)/$(1).Po"; else rm -f "$(DEPDIR)/$(1).Tpo"; exit 1; fi
endef

define __af_nofastdep_template
source='$(3)' object='$(2)' libtool=$(5) \
DEPDIR=$(DEPDIR) $(6) $(depcomp)
endef

define __af_dep_template
$(if "$am__fastdepCC",
  $(call __af_fastdep_template,   $(1), $(2), $(3), $(4), $(5), $(6)),
  $(call __af_nofastdep_template, $(1), $(2), $(3), $(4), $(5), $(6)))
endef

define __af_cc_compile
$(call __af_dep_template, $(1), $(2), $(3), $(COMPILE), no, $(CCDEPMODE))
$(COMPILE) -c $(3)
endef

define __af_ltcc_compile
$(call __af_dep_template, $(1), $(2), $(3), $(LTCOMPILE), yes, $(CCDEPMODE))
$(LTCOMPILE) -c $(3)
endef

define __af_cxx_compile
$(call __af_dep_template, $(1), $(2), $(3), $(CXXCOMPILE), no, $(CXXDEPMODE))
$(CXXCOMPILE) -c $(3)
endef

define __af_ltcxx_compile
$(call __af_dep_template, $(1), $(2), $(3), $(LTCXXCOMPILE), yes, $(CXXDEPMODE))
$(LTCXXCOMPILE) -c $(3)
endef

%.o: %.c
	$(call __af_cc_compile, $*, $@, $<)

%.lo: %.c
	$(call __af_cc_ltcompile, $*, $@, $<)

%.o: %.cpp
	$(call __af_cxx_compile, $*, $@, $<)

%.lo: %.cpp
	$(call __af_ltcxx_compile, $*, $@, $<)
