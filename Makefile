# Copyright 1996 Acorn Computers Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Makefile for Kernel
#

COMPONENT       = Kernel

include StdTools

ifeq (${MAKECMDGOALS},install)
EXP_HDR         = ${INSTDIR}${SEP}Hdr${SEP}Interface
C_EXP_HDR       = ${INSTDIR}${SEP}C${SEP}Global
else
CEXPORTDIR     ?= <cexport$dir>
C_EXP_HDR       = ${CEXPORTDIR}${SEP}Global
endif
ifeq (,${MAKE_VERSION})
C_EXP_HDR      := ${C_EXP_HDR}.h
endif

# Keep SyncLib out of the kernel for now:
# 1. We don't have a way of unlocking mutexes/spinlocks when recovering from
#    aborts
USE_SYNCLIB    ?= FALSE

ifneq (${STARTUP_MODULE},)
ASFLAGS        += -PD "StartupModule SETS \"${STARTUP_MODULE}\""
endif

TOKHELPSRC      = ${TOKENSOURCE}
HELPSRC         = HelpStrs
OBJS            = GetAll
KERNEL_MODULE   = bin${SEP}${COMPONENT}
ASFLAGS        += -PD "FreezeDevRel SETL {${FREEZE_DEV_REL}}" -PD "USE_SYNCLIB SETL {${USE_SYNCLIB}}" -PD "RISCOS_KERNEL SETL {TRUE}"
CFLAGS         += -ff -APCS 3/32bit/nofp/noswst -DRISCOS_KERNEL
CUSTOMROM       = custom
CUSTOMSA        = custom
ifeq (${USE_SYNCLIB},TRUE)
CFLAGS	       += -DUSE_SYNCLIB
LIBS            = ${SYNCLIB}k
endif

#
# AbortTrap:
#
VPATH += aborttrap
OBJS += aborttrap atarm atcontext atinstr aterrors atmem

DECGEN = <Tools$Dir>.Misc.decgen.decgen

# Work out which instructions to include support for; this is just to reduce
# code size, and doesn't affect the handling of the instructions
# Note that FPA is only included in IOMD builds
ABORTTRAP_ACTIONS_ARM = ARMv3 ARMv4 ARMv5TE ARMv6 ARMv6K ARMv6T2 ARMv8 VFP ASIMD

TOOLSDIR ?= <Tool$Dir>

ABORTTRAP_ENCODINGS_ARM = ${TOOLSDIR}${SEP}decgen${SEP}encodings${SEP}ARMv7 \
                          ${TOOLSDIR}${SEP}decgen${SEP}encodings${SEP}ARMv7_ASIMD \
                          ${TOOLSDIR}${SEP}decgen${SEP}encodings${SEP}ARMv7_VFP \
                          ${TOOLSDIR}${SEP}decgen${SEP}encodings${SEP}ARMv8_AArch32 \
                          ${TOOLSDIR}${SEP}decgen${SEP}encodings${SEP}FPA

ifneq (,$(findstring $(MACHINE),IOMD))
ABORTTRAP_ACTIONS_ARM = ARMv3 ARMv4 FPA
endif
ifneq (,$(findstring $(MACHINE),Tungsten))
ABORTTRAP_ACTIONS_ARM = ARMv3 ARMv4 ARMv5TE
endif
ifneq (,$(findstring $(MACHINE),ARM11ZF))
ABORTTRAP_ACTIONS_ARM = ARMv3 ARMv4 ARMv5TE ARMv6 ARMv6K VFP
endif
ifneq (,$(findstring $(MACHINE),CortexA7 CortexA8 CortexA9))
ABORTTRAP_ACTIONS_ARM = ARMv3 ARMv4 ARMv5TE ARMv6 ARMv6K ARMv6T2 VFP ASIMD
endif

ABORTTRAP_ACTIONS = ${ABORTTRAP_ACTIONS_ARM}

# Have decgen use a pre-warmed cache file to speed up decoder generation. Please
# remember to submit the files if they change!
ABORTTRAP_CACHE = $(subst $(subst x,,x x),_,$(strip ${ABORTTRAP_ACTIONS_ARM}))

CFLAGS += $(addprefix -DABORTTRAP_,${ABORTTRAP_ACTIONS})

HEADER1         = DBellDevice
HEADER2         = EnvNumbers
HEADER3         = HALDevice
HEADER4         = HALEntries
HEADER5         = ModHand
HEADER6         = OSEntries
HEADER7         = OSMem
HEADER8         = OSMisc
HEADER9         = OSRSI6
HEADER10        = PL310
HEADER11        = PublicWS
HEADER12        = RISCOS
HEADER13        = Variables
HEADER14        = VduExt
HEADER15        = VIDCList
HEADER16        = VideoDevice

ASMCHEADER1     = HALEntries
ASMCHEADER2     = ModHand
ASMCHEADER3     = OSMem
ASMCHEADER4     = OSMisc
ASMCHEADER5     = OSRSI6
ASMCHEADER6     = RISCOS
ASMCHEADER7     = Variables
ASMCHEADER8     = VduExt

EXPORTS =                                        \
    ${EXP_HDR}${SEP}AMBControl                   \
    ${C_EXP_HDR}${SEP}HALDevice${SUFFIX_HEADER}  \
    ${C_EXP_HDR}${SEP}HALEntries${SUFFIX_HEADER} \
    ${C_EXP_HDR}${SEP}ModHand${SUFFIX_HEADER}    \
    ${C_EXP_HDR}${SEP}OSEntries${SUFFIX_HEADER}  \
    ${C_EXP_HDR}${SEP}OSMem${SUFFIX_HEADER}      \
    ${C_EXP_HDR}${SEP}OSMisc${SUFFIX_HEADER}     \
    ${C_EXP_HDR}${SEP}OSRSI6${SUFFIX_HEADER}     \
    ${C_EXP_HDR}${SEP}RISCOS${SUFFIX_HEADER}     \
    ${C_EXP_HDR}${SEP}Variables${SUFFIX_HEADER}  \
    ${C_EXP_HDR}${SEP}VduExt${SUFFIX_HEADER}     \
    ${C_EXP_HDR}${SEP}VIDCList${SUFFIX_HEADER}   \

SOURCES_TO_SYMLINK = $(wildcard s/AMBControl/*) $(wildcard s/PMF/*) $(wildcard s/vdu/*)
SYMLINK_EXT_FIRST = yes

include AAsmModule
include StdRules
ifeq (${USE_SYNCLIB},TRUE)
include AppLibs
endif

# Override this to "TRUE" in the components file if
# you want an odd-numbered (development) build to be
# a 'freezable' build - e.g. with no ROM debug output
FREEZE_DEV_REL ?= FALSE

ROM_OBJECTS = $(addsuffix .o,${OBJS})

#
# AbortTrap:
#

clean ::
	@IfThere aborttrap.c.atarm     Then delete aborttrap.c.atarm

ABORTTRAP_ARM_DEPS = $(addprefix aborttrap.actions.,${ABORTTRAP_ACTIONS_ARM})

aborttrap.c.atarm: $(ABORTTRAP_ARM_DEPS) aborttrap.c.atpre $(ABORTTRAP_ENCODINGS_ARM)
	$(DECGEN) -bits=32 -e "-DCDP={ne(coproc,1)}" "-DLDC_STC={ne(coproc,1)}{ne(coproc,2)}" "-DMRC_MCR={ne(coproc,1)}" -DVFP1=(cond:4) "-DVFP2={ne(cond,15)}" -DAS1(X)=1111001[X] -DAS2=11110100 -DAS3=(cond:4)1110 "-DAS4={ne(cond,15)}" "-DCC={ne(cond,15)}" $(ABORTTRAP_ENCODINGS_ARM) -valid -a $(addprefix aborttrap/actions/,${ABORTTRAP_ACTIONS_ARM}) -default=DEFAULT -o aborttrap/atarm.c -name=aborttrap_arm -pre aborttrap/atpre.c -updatecache aborttrap/cache/${ABORTTRAP_CACHE}

o.atarm: aborttrap.c.atarm
	${CC} ${CFLAGS} -o $@ aborttrap.c.atarm

od.atarm: aborttrap.c.atarm
	${CC} $(filter-out ${C_NO_FNAMES},${CFLAGS}) ${CDFLAGS} -o $@ aborttrap.c.atarm

#
# Custom ROM:
#
rom: ${KERNEL_MODULE}
	@${ECHO} ${COMPONENT}: rom module built

install_rom: ${KERNEL_MODULE}
	${CP} ${KERNEL_MODULE} ${INSTDIR}${SEP}${TARGET} ${CPFLAGS}
	${CP} ${KERNEL_MODULE}_gpa ${INSTDIR}${SEP}${TARGET}_gpa ${CPFLAGS}
	@${ECHO} ${COMPONENT}: rom module installed

inst_dirs:
	${MKDIR} ${EXP_HDR}
	${MKDIR} ${C_EXP_HDR}

install: ${EXPORTS} inst_dirs
	@${ECHO} ${COMPONENT}: header files installed

${KERNEL_MODULE}: ${ROM_OBJECTS} ${DIRS} ${LIBS} kstrip
	${MKDIR} bin
	SetEval KernelBase "4" + STR ( 227858432 + ( HALSize LEFT ( LEN HALSize - 1 ) ) * 1024 )
	Do ${LD} -aif -base <KernelBase> -RW-base 0xff000000 -bin -d -o ${KERNEL_MODULE}_aif ${ROM_OBJECTS} ${LIBS}
	Do kstrip ${KERNEL_MODULE}_aif ${KERNEL_MODULE}
	${TOGPA} -s ${KERNEL_MODULE}_aif ${KERNEL_MODULE}_gpa

GetAll.o: ${TOKHELPSRC}

#
# Custom exports:
#
ifeq (,${MAKE_VERSION})

# RISC OS / amu case

${EXP_HDR}.AMBControl: hdr.AMBControl
	${CP} hdr.AMBControl $@ ${CPFLAGS}

${C_EXP_HDR}.HALDevice: Global.h.HALDevice h.HALDevice
	${FAPPEND} $@ h.HALDevice Global.h.HALDevice

${C_EXP_HDR}.OSEntries: Global.h.OSEntries h.OSEntries
	${FAPPEND} $@ h.OSEntries Global.h.OSEntries

${C_EXP_HDR}.VIDCList: Global.h.VIDCList h.VIDCList
	${FAPPEND} $@ h.VIDCList Global.h.VIDCList

Global.h.HALDevice: hdr.HALDevice
	${MKDIR} Global.h
	${HDR2H} hdr.HALDevice $@

Global.h.OSEntries: hdr.OSEntries
	${MKDIR} Global.h
	${HDR2H} hdr.OSEntries $@

Global.h.VIDCList: hdr.VIDCList
	${MKDIR} Global.h
	${HDR2H} hdr.VIDCList $@

else

# Posix / gmake case

${EXP_HDR}/AMBControl: AMBControl.hdr
	${CP} AMBControl.hdr $@

${C_EXP_HDR}/HALDevice.h: Global/HALDevice.h HALDevice.h
	${FAPPEND} $@ HALDevice.h Global/HALDevice.h

${C_EXP_HDR}/OSEntries.h: Global/OSEntries.h OSEntries.h
	${FAPPEND} $@ OSEntries.h Global/OSEntries.h

${C_EXP_HDR}/VIDCList.h: Global/VIDCList.h VIDCList.h
	${FAPPEND} $@ VIDCList.h Global/VIDCList.h

Global/HALDevice.h: HALDevice.hdr
	${MKDIR} Global
	${HDR2H} $^ $@

Global/OSEntries.h: OSEntries.hdr
	${MKDIR} Global
	${HDR2H} $^ $@

Global/VIDCList.h: VIDCList.hdr
	${MKDIR} Global
	${HDR2H} $^ $@

endif

clean::
	${XWIPE} Global ${WFLAGS}
	${XWIPE} bin    ${WFLAGS}
	${RM} kstrip

kstrip: kstrip.c
	${MAKE} -f kstrip/mk COMPONENT=kstrip THROWBACK=${THROWBACK}

# Dynamic dependencies:
