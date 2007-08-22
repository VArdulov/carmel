#you provide:  
# (the variables below)
# ARCH (if macosx, static builds are blocked)
#PROGS=a b
#build boost yourself and ensure that you have -Lwhatever -Iwhatever for it in CPPFLAGS
#a_OBJ=a.o ... a_SLIB=lib.o lib.a (static libraries e.g. a_LIB=$(BOOST_OPTIONS_LIB))
#a_NOSTATIC=1 a_NOTEST=1 ...
#NOSTATIC=1 (global setting)
# CXXFLAGS CXXFLAGS_DEBUG CXXFLAGS_TEST
# LIB = math thread ...
# INC = . 
###WARNING: don't set BASEOBJ BASESHAREDOBJ or BASEBIN to directories including other important stuff or they will be nuked by make allclean

#include $(SHARED)/debugger.mk
#$(__BREAKPOINT)

ifndef BUILD_BASE
BUILD_BASE:=.
endif
LIB += z
CXXFLAGS += $(CMDCXXFLAGS)
ifndef ARCH
UNAME=$(shell uname)
ARCH=cygwin
ifeq ($(UNAME),Linux)
 ARCH=linux
endif
ifeq ($(UNAME),SunOS)
 ARCH=solaris
endif
ifeq ($(UNAME),Darwin)
 ARCH=macosx
endif
endif

ifndef ARCH_FLAGS
ifeq ($(ARCH),linux64)
ARCH_FLAGS = -march=athlon64
else
 ifeq ($(ARCH),linux)
#  ARCH_FLAGS = -m32 -march=pentium4
 endif
endif
endif

ifndef INSTALL_PREFIX
ifdef HOSTBASE
INSTALL_PREFIX=$(HOSTBASE)
else
ifdef ARCHBASE
INSTALL_PREFIX=$(ARCHBASE)
else
INSTALL_PREFIX=$(HOME)
endif
endif
endif
ifndef BIN_PREFIX
BIN_PREFIX=$(INSTALL_PREFIX)/bin
endif

ifndef TRUNK
TRUNK=../..
endif

ifndef SHARED
SHARED=../shared
endif
ifndef BOOST_DIR
# note: BOOST_DIR not used for anything now, we assume boost somewhere in std include
#BOOST_DIR:=../boost
BOOST_DIR=~/isd/$(HOST)/include
endif
ifndef BASEOBJ
BASEOBJ=$(BUILD_BASE)/obj
endif
ifndef BASEBIN
BASEBIN=bin
endif
ifndef BASESHAREDOBJ
BASESHAREDOBJ=$(SHARED)/obj
endif

.SUFFIXES:
.PHONY = distclean all clean depend default

ifndef ARCH
  ARCH := $(shell print_arch)
  export ARCH
endif

ifndef BUILDSUB
  ifdef HOST
   BUILDSUB=$(HOST)
  else
   BUILDSUB=$(ARCH)
  endif
endif
DEPSPRE:= $(BUILD_BASE)/deps/$(BUILDSUB)/

# workaround for eval line length limit: immediate substitution shorter?
OBJ:= $(BASEOBJ)/$(BUILDSUB)
OBJT:= $(OBJ)/test
ifndef OBJB
OBJB:= $(BASESHAREDOBJ)/$(BUILDSUB)
endif
OBJD:= $(OBJ)/debug
BIN:= $(BASEBIN)/$(BUILDSUB)
ALL_DIRS:= $(BASEOBJ) $(OBJ) $(BASEBIN) $(BIN) $(OBJD) $(OBJT) $(BASESHAREDOBJ) $(OBJB) $(DEPSPRE)
Dummy1783uio42:=$(shell for f in $(ALL_DIRS); do [ -d $$f ] || mkdir -p $$f ; done)

BOOST_SERIALIZATION_SRC_DIR = $(BOOST_DIR)/libs/serialization/src
BOOST_TEST_SRC_DIR = $(BOOST_DIR)/libs/test/src
BOOST_OPTIONS_SRC_DIR = $(BOOST_DIR)/libs/program_options/src
BOOST_FILESYSTEM_SRC_DIR = $(BOOST_DIR)/libs/filesystem/src

#wide char archive streams not supported on cygwin so remove *_w*.cpp
BOOST_SERIALIZATION_SRCS:=$(filter-out utf8_codecvt_facet.cpp,$(notdir $(filter-out $(wildcard $(BOOST_SERIALIZATION_SRC_DIR)/*_w*),$(wildcard $(BOOST_SERIALIZATION_SRC_DIR)/*.cpp))))

#BOOST_SERIALIZATION_SRCS:=$(notdir $(filter-out $(wildcard $(BOOST_SERIALIZATION_SRC_DIR)/*_w*),$(wildcard $(BOOST_SERIALIZATION_SRC_DIR)/*.cpp)))

BOOST_TEST_SRCS=$(filter-out cpp_main.cpp,$(notdir $(wildcard $(BOOST_TEST_SRC_DIR)/*.cpp)))
BOOST_OPTIONS_SRCS=$(filter-out utf8_codecvt_facet.cpp winmain.cpp,$(notdir $(wildcard $(BOOST_OPTIONS_SRC_DIR)/*.cpp)))
BOOST_FILESYSTEM_SRCS=$(notdir $(wildcard $(BOOST_FILESYSTEM_SRC_DIR)/*.cpp))

BOOST_SERIALIZATION_OBJS=$(addprefix $(OBJB)/,$(addsuffix .o,$(BOOST_SERIALIZATION_SRCS)))
BOOST_TEST_OBJS=$(addprefix $(OBJB)/,$(addsuffix .o,$(BOOST_TEST_SRCS)))
BOOST_OPTIONS_OBJS=$(addprefix $(OBJB)/,$(addsuffix .o,$(BOOST_OPTIONS_SRCS)))
BOOST_FILESYSTEM_OBJS=$(addprefix $(OBJB)/,$(addsuffix .o,$(BOOST_FILESYSTEM_SRCS)))

ifndef BOOST_SUFFIX_BASE
BOOST_SUFFIX_BASE=gcc
endif
ifdef BOOST_DEBUG
ifndef BOOST_DEBUG_SUFFIX
BOOST_DEBUG_SUFFIX=-d
endif
endif
ifndef NO_THREADS
BOOST_SUFFIX=$(BOOST_SUFFIX_BASE)-mt$(BOOST_DEBUG_SUFFIX)
else
BOOST_SUFFIX=$(BOOST_SUFFIX_BASE)$(BOOST_DEBUG_SUFFIX)
CPPFLAGS +=  -DBOOST_DISABLE_THREADS -DBOOST_NO_MT
endif

ifdef BUILD_OWN_BOOST_LIBS
BOOST_SERIALIZATION_LIB=$(OBJB)/libserialization.a
BOOST_TEST_LIB=$(OBJB)/libtest.a
BOOST_OPTIONS_LIB=$(OBJB)/libprogram_options.a
BOOST_FILESYSTEM_LIB=$(OBJB)/libfilesystem.a
libs: $(BOOST_SERIALIZATION_LIB) $(BOOST_TEST_LIB) $(BOOST_OPTIONS_LIB) $(BOOST_FILESYSTEM_LIB)
else
BOOST_SERIALIZATION_LIB=-lboost_serialization-$(BOOST_SUFFIX)
BOOST_TEST_LIB=-lboost_unit_test_framework-$(BOOST_SUFFIX)
BOOST_OPTIONS_LIB=-lboost_program_options-$(BOOST_SUFFIX)
BOOST_SERIALIZATION_LIB=-lboost_serialization-$(BOOST_SUFFIX)
libs:
endif


list_src: $(BOOST_SERIALIZATION_SRCS)
	echo $(BOOST_SERIALIZATION_SRCS)


CXXFLAGS_COMMON += $(ARCH_FLAGS)
#CPPNOWIDECHAR = $(addprefix -D,BOOST_NO_CWCHAR BOOST_NO_CWCTYPE BOOST_NO_STD_WSTRING BOOST_NO_STD_WSTREAMBUF)

LARGEFILEFLAGS = -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 
CPPFLAGS += $(CPPNOWIDECHAR) $(LARGEFILEFLAGS)
LDFLAGS += $(addprefix -l,$(LIB)) -L$(OBJB) $(ARCH_FLAGS) $(addprefix -L,$(LIBDIR))
#-lpthread
LDFLAGS_TEST = $(LDFLAGS)  -ltest
INC += $(TRUNK)
CPPFLAGS += $(addprefix -I,$(INC)) 

ifdef PEDANTIC
CPPFLAGS +=  -pedantic
endif
CPPFLAGS_TEST += $(CPPFLAGS) -ggdb
CPPFLAGS_DEBUG += $(CPPFLAGS) -fno-inline-functions -ggdb
CPPFLAGS_OPT += $(CPPFLAGS) -ggdb
#-DNDEBUG

#-fno-var-tracking
# somehow that is getting automatically set by boost now for gcc 3.4.1 (detecting that -lthread is not used? dunno)


ifeq ($(ARCH),solaris)
  CPPFLAGS += -DSOLARIS -DUSE_STD_RAND
#  DBOOST_PLATFORM_CONFIG=<boost/config/solaris.hpp>
endif

ifeq ($(ARCH),linux)
 CPPFLAGS += -DLINUX_BACKTRACE -DLINUX  -rdynamic
#-rdynamic: forces global symbol table (could remove for optimized build)
endif

ifeq ($(ARCH),cygwin)
NOSTATIC=1
CPPFLAGS += -DBOOST_POSIX -DCYGWIN
#CPPFLAGS += -DBOOST_NO_STD_WSTRING
#CPPNOWIDECHAR = $(addprefix -D,BOOST_NO_CWCHAR BOOST_NO_CWCTYPE BOOST_NO_STD_WSTRING BOOST_NO_STD_WSTREAMBUF)
# somehow that is getting automatically set by boost now (for Boost CVS)
endif


define PROG_template

.PHONY += $(1)

ifndef $(1)_SRC_TEST
$(1)_SRC_TEST=$$($(1)_SRC)
else
ALL_SRCS_REL+=$$($(1)_SRC_TEST)
endif
ALL_SRCS_REL += $$($(1)_SRC)

$(1)_OBJ=$$(addsuffix .o,$$($(1)_SRC))
$(1)_OBJ_TEST=$$(addsuffix .o,$$($(1)_SRC_TEST))

ifndef $(1)_NOOPT
$$(BIN)/$(1)$(PROGSUFFIX):\
 $$(addprefix $$(OBJ)/,$$($(1)_OBJ))\
 $$($(1)_SLIB)
	@echo
	@echo LINK\(optimized\) $$@ - from $$^
	$$(CXX) $$^ -o $$@ $$(LDFLAGS) $$($(1)_LIB) $$($(1)_BOOSTLIB)
ALL_OBJS   += $$(addprefix $$(OBJ)/,$$($(1)_OBJ))
OPT_PROGS += $$(BIN)/$(1)$(PROGSUFFIX)
$(1): $$(BIN)/$(1)
endif

ifneq (${ARCH},macosx)
ifndef NOSTATIC
ifndef $(1)_NOSTATIC
$$(BIN)/$(1)$(PROGSUFFIX).static: $$(addprefix $$(OBJ)/,$$($(1)_OBJ)) $$($(1)_SLIB)
	@echo
	@echo LINK\(static\) $$@ - from $$^
	$$(CXX) $$^ -o $$@ $$(LDFLAGS) $$($(1)_LIB) $$($(1)_BOOSTLIB) --static 
ALL_OBJS   += $$(addprefix $$(OBJ)/,$$($(1)_OBJ))
STATIC_PROGS += $$(BIN)/$(1)$(PROGSUFFIX).static
$(1): $$(BIN)/$(1).static
endif
endif
endif

ifndef $(1)_NODEBUG
$$(BIN)/$(1)$(PROGSUFFIX).debug:\
 $$(addprefix $$(OBJD)/,$$($(1)_OBJ)) $$($(1)_SLIB)
	@echo
	@echo LINK\(debug\) $$@ - from $$^
	$$(CXX) $$^ -o $$@ $$(LDFLAGS) $$($(1)_LIB) $$(addsuffix -d,$$($(1)_BOOSTLIB))
ALL_OBJS +=  $$(addprefix $$(OBJD)/,$$($(1)_OBJ)) 
DEBUG_PROGS += $$(BIN)/$(1)$(PROGSUFFIX).debug
$(1): $$(BIN)/$(1).debug
endif

ifndef $(1)_NOTEST
#$$(BOOST_TEST_LIB)
$$(BIN)/$(1)$(PROGSUFFIX).test: $$(addprefix $$(OBJT)/,$$($(1)_OBJ_TEST))  $$($(1)_SLIB)
	@echo
	@echo LINK\(test\) $$@ - from $$^
	$$(CXX) $$^ -o $$@ $$(LDFLAGS) $$($(1)_LIB) $$(BOOST_TEST_LIB)
#	$$@ --catch_system_errors=no
ALL_OBJS += $$(addprefix $$(OBJT)/,$$($(1)_OBJ_TEST))
ALL_TESTS += $$(BIN)/$(1)$(PROGSUFFIX).test
TEST_PROGS += $$(BIN)/$(1)$(PROGSUFFIX).test
$(1): $$(BIN)/$(1).test
endif

#$(1): $(addprefix $$(BIN)/, $(1) $(1).debug $(1).test)

endef

.PRECIOUS: %/.
%/.:
	mkdir -p $@

$(foreach prog,$(PROGS),$(eval $(call PROG_template,$(prog))))


ALL_PROGS=$(OPT_PROGS) $(DEBUG_PROGS) $(TEST_PROGS) $(STATIC_PROGS)

all: $(ALL_DEPENDS) $(ALL_PROGS)

opt: $(OPT_PROGS)

debug: $(DEBUG_PROGS)

ALL_DEPENDS=$(addprefix $(DEPSPRE),$(addsuffix .d,$(ALL_SRCS_REL)))

redepend:
	rm -f $(ALL_DEPENDS)
	make depend

depend: $(ALL_DEPENDS)

ifeq ($(ARCH),cygwin)
CYGEXE=.exe
else
CYGEXE=
endif

install: $(OPT_PROGS) $(STATIC_PROGS) $(DEBUG_PROGS)
	mkdir -p $(BIN_PREFIX) ; cp $(STATIC_PROGS) $(DEBUG_PROGS) $(addsuffix $(CYGEXE), $(OPT_PROGS)) $(BIN_PREFIX)

check:	test


test: $(ALL_TESTS)
	for test in $(ALL_TESTS) ; do echo Running test: $$test; $$test --catch_system_errors=no ; done
#	$(foreach test,$(ALL_TESTS),$(shell $(test) --catch_system_errors=no))


ifdef BUILD_OWN_BOOST_LIBS
$(BOOST_FILESYSTEM_LIB): $(BOOST_FILESYSTEM_OBJS)
	@echo
	@echo creating Boost Filesystem lib
	$(AR) -rc $@ $^
#	$(RANLIB) $@

$(BOOST_TEST_LIB): $(BOOST_TEST_OBJS)
	@echo
	@echo creating Boost Test lib
	$(AR) -rc $@ $^
#	$(RANLIB) $@

$(BOOST_OPTIONS_LIB): $(BOOST_OPTIONS_OBJS)
	@echo
	@echo creating Boost Program Options lib
	$(AR) -rc $@ $^
#	$(RANLIB) $@

$(BOOST_SERIALIZATION_LIB): $(BOOST_SERIALIZATION_OBJS)
	@echo
	@echo creating Boost Program Serialization lib
	$(AR) -rc $@ $^
#	$(RANLIB) $@
endif

#vpath %.cpp $(BOOST_SERIALIZATION_SRC_DIR) $(BOOST_TEST_SRC_DIR) $(BOOST_OPTIONS_SRC_DIR) $(BOOST_FILESYSTEM_SRC_DIR)
vpath %.d $(DEPSPRE)
#vpath %.hpp $(BOOST_DIR)

#:$(SHARED):.
.PRECIOUS: $(OBJB)/%.o
$(OBJB)/%.o: %
	@echo
	@echo COMPILE\(boost\) $< into $@
	$(CXX) -c $(CXXFLAGS_COMMON) $(CXXFLAGS) $(CPPFLAGS) $< -o $@

.PRECIOUS: $(OBJT)/%.o
$(OBJT)/%.o: % %.d
	@echo
	@echo COMPILE\(test\) $< into $@
	$(CXX) -c $(CXXFLAGS_COMMON) $(CXXFLAGS_TEST) $(CPPFLAGS_TEST) $< -o $@

.PRECIOUS: $(OBJ)/%.o
$(OBJ)/%.o: % %.d
	@echo
	@echo COMPILE\(optimized\) $< into $@
	$(CXX) -c $(CXXFLAGS_COMMON) $(CXXFLAGS) $(CPPFLAGS_OPT) $< -o $@

.PRECIOUS: $(OBJD)/%.o
$(OBJD)/%.o: % %.d
	@echo
	@echo COMPILE\(debug\) $< into $@
	$(CXX) -c $(CXXFLAGS_COMMON) $(CXXFLAGS_DEBUG) $(CPPFLAGS_DEBUG) $< -o $@

#dirs:
# $(addsuffix /.,$(ALL_DIRS))
#	echo dirs: $^

clean:
	-rm -rf -- $(ALL_OBJS) $(ALL_CLEAN) *.core *.stackdump

distclean: clean
	-rm -rf -- $(ALL_DEPENDS) $(BOOST_TEST_OBJS) $(BOOST_OPTIONS_OBJS) msvc++/Debug msvc++/Release

allclean: distclean
	-rm -rf -- $(BASEOBJ)* $(BASEBIN) $(BASESHAREDOBJ)

ifeq ($(MAKECMDGOALS),depend)
DEPEND=1
endif


#                 sed 's/\($*\)\.o[ :]*/$@ : /g' $@.raw > $@ && sed 's/\($*\)\.o[ :]*/\n\%\/\1.o : /g' $@.raw >> $@ \
#sed 's/\($*\)\.o[ :]*/DEPS_$@ := /g' $@.raw > $@ && echo $(basename $<).o : \\\$DEPS_$(basename $<) >> $@ \

#phony: -MP 
$(DEPSPRE)%.d: %
	@set -e; \
	if [ x$(DEPEND) != x -o ! -f $@ ] ; then \
 ( \
echo CREATE DEPENDENCIES for $< \(object=$(*F).o\) && \
		$(CXX) -c -MP -MM -MG $(CPPFLAGS_DEBUG) $< -MF $@.raw && \
		[ -s $@.raw ] && \
                 perl -pe 's|([^:]*)\.o[ :]*|$@ : |g' $@.raw > $@ && \
echo >> $@ && \
perl -pe 's|([^:]*)\.o[ :]*|$(OBJ)/$(*F).o : |g' $@.raw >>$@  && \
echo >> $@ && \
perl -pe 's|([^:]*)\.o[ :]*|$(OBJD)/$(*F).o : |g' $@.raw >> $@ && \
echo >> $@ && \
perl -pe 's|([^:]*)\.o[ :]*|$(OBJT)/$(*F).o : |g' $@.raw >> $@  \
 || rm -f $@ ); rm -f $@.raw ; fi
#; else touch $@ 

ifneq ($(MAKECMDGOALS),depend)
ifneq ($(MAKECMDGOALS),distclean)
ifneq ($(MAKECMDGOALS),clean)
include $(ALL_DEPENDS)
endif
endif
endif
