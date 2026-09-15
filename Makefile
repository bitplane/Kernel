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

ifeq (GNU,${TOOLCHAIN})
TOKENSOURCE     = s/TokHelpSrc
endif
TOKHELPSRC      = ${TOKENSOURCE}
HELPSRC         = HelpStrs
OBJS            = GetAll
KERNEL_MODULE   = bin${SEP}${COMPONENT}
ASFLAGS        += -PD "FreezeDevRel SETL {${FREEZE_DEV_REL}}" -PD "USE_SYNCLIB SETL {${USE_SYNCLIB}}" -PD "RISCOS_KERNEL SETL {TRUE}"
ifeq (GNU,${TOOLCHAIN})
CFLAGS         += -DRISCOS_KERNEL -mno-apcs-stack-check
else
CFLAGS         += -ff -APCS 3/32bit/nofp/noswst -DRISCOS_KERNEL
endif
CUSTOMROM       = custom
CUSTOMSA        = custom
ifeq (${USE_SYNCLIB},TRUE)
CFLAGS	       += -DUSE_SYNCLIB
LIBS            = ${SYNCLIB}k
endif

#
# AbortTrap:
#
ifeq (GNU,${TOOLCHAIN})
VPATH += aborttrap/c aborttrap/s aborttrap
CINCLUDES += -Iaborttrap/h
else
VPATH += aborttrap
endif
OBJS += aborttrap atarm atcontext atinstr aterrors atmem

ifeq (GNU,${TOOLCHAIN})
DECGEN = decgen
else
DECGEN = <Tools$Dir>.Misc.decgen.decgen
endif

# Work out which instructions to include support for; this is just to reduce
# code size, and doesn't affect the handling of the instructions
# Note that FPA is only included in IOMD builds
ABORTTRAP_ACTIONS_ARM = ARMv3 ARMv4 ARMv5TE ARMv6 ARMv6K ARMv6T2 ARMv8 VFP ASIMD

TOOLSDIR ?= <Tool$Dir>

ifeq (GNU,${TOOLCHAIN})
DECGEN_DATA = ${TOOLSDIR}${SEP}Misc${SEP}decgen
else
DECGEN_DATA = ${TOOLSDIR}${SEP}decgen
endif

ABORTTRAP_ENCODINGS_ARM = ${DECGEN_DATA}${SEP}encodings${SEP}ARMv7 \
                          ${DECGEN_DATA}${SEP}encodings${SEP}ARMv7_ASIMD \
                          ${DECGEN_DATA}${SEP}encodings${SEP}ARMv7_VFP \
                          ${DECGEN_DATA}${SEP}encodings${SEP}ARMv8_AArch32 \
                          ${DECGEN_DATA}${SEP}encodings${SEP}FPA

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

ifeq (GNU,${TOOLCHAIN})
SOURCES_TO_SYMLINK = HelpStrs Version
GNU_ABORTTRAP_C = aborttrap aterrors atinstr atmem
GNU_ABORTTRAP_H = aborttrap atcontext aterrors atinstr atsupport
SYMLINK_DEPEND += objs/s objs/hdr objs/h \
                  $(addprefix objs/aborttrap/c/,$(addsuffix .c,${GNU_ABORTTRAP_C})) \
                  $(addprefix objs/aborttrap/h/,$(addsuffix .h,${GNU_ABORTTRAP_H})) \
                  objs/aborttrap/psr.h objs/aborttrap/kerneliface.h \
                  objs/aborttrap/s/atcontext.s objs/aborttrap/c/atarm.c
else
SOURCES_TO_SYMLINK = HelpStrs Version $(wildcard s/AMBControl/*) $(wildcard s/PMF/*) $(wildcard s/vdu/*)
SYMLINK_EXT_FIRST = yes
endif

include AAsmModule
include StdRules
ifeq (${USE_SYNCLIB},TRUE)
include AppLibs
endif

ifeq (GNU,${TOOLCHAIN})
$(addprefix objs/aborttrap/c/,$(addsuffix .c,${GNU_ABORTTRAP_C})):
	${MKDIR} objs/aborttrap/c
	ln -s "${CURDIR}/aborttrap/c/$(basename $(notdir $@))" $@

$(addprefix objs/aborttrap/h/,$(addsuffix .h,${GNU_ABORTTRAP_H})):
	${MKDIR} objs/aborttrap/h
	ln -s "${CURDIR}/aborttrap/h/$(basename $(notdir $@))" $@

objs/aborttrap/psr.h objs/aborttrap/kerneliface.h:
	${MKDIR} objs/aborttrap
	ln -s "${CURDIR}/h/$(basename $(notdir $@))" $@

objs/aborttrap/s/atcontext.s:
	${MKDIR} objs/aborttrap/s
	ln -s "${CURDIR}/aborttrap/s/atcontext" $@

objs/s objs/hdr objs/h:
	${MKDIR} $@
	cp -as "${CURDIR}/$(notdir $@)/." $@/
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

ifeq (GNU,${TOOLCHAIN})
ABORTTRAP_ARM_DEPS = $(addprefix aborttrap/actions/,${ABORTTRAP_ACTIONS_ARM})

objs/aborttrap/c/atarm.c: ${ABORTTRAP_ARM_DEPS} aborttrap/c/atpre ${ABORTTRAP_ENCODINGS_ARM}
	${MKDIR} objs/aborttrap/c
	${DECGEN} -bits=32 -e "-DCDP={ne(coproc,1)}" "-DLDC_STC={ne(coproc,1)}{ne(coproc,2)}" "-DMRC_MCR={ne(coproc,1)}" "-DVFP1=(cond:4)" "-DVFP2={ne(cond,15)}" "-DAS1(X)=1111001[X]" -DAS2=11110100 "-DAS3=(cond:4)1110" "-DAS4={ne(cond,15)}" "-DCC={ne(cond,15)}" ${ABORTTRAP_ENCODINGS_ARM} -valid -a ${ABORTTRAP_ARM_DEPS} -default=DEFAULT -o $@ -name=aborttrap_arm -pre aborttrap/c/atpre -updatecache aborttrap/cache/${ABORTTRAP_CACHE}
else
ABORTTRAP_ARM_DEPS = $(addprefix aborttrap.actions.,${ABORTTRAP_ACTIONS_ARM})
endif

aborttrap.c.atarm: $(ABORTTRAP_ARM_DEPS) aborttrap.c.atpre $(ABORTTRAP_ENCODINGS_ARM)
	$(DECGEN) -bits=32 -e "-DCDP={ne(coproc,1)}" "-DLDC_STC={ne(coproc,1)}{ne(coproc,2)}" "-DMRC_MCR={ne(coproc,1)}" -DVFP1=(cond:4) "-DVFP2={ne(cond,15)}" -DAS1(X)=1111001[X] -DAS2=11110100 -DAS3=(cond:4)1110 "-DAS4={ne(cond,15)}" "-DCC={ne(cond,15)}" $(ABORTTRAP_ENCODINGS_ARM) -valid -a $(addprefix aborttrap/actions/,${ABORTTRAP_ACTIONS_ARM}) -default=DEFAULT -o aborttrap/atarm.c -name=aborttrap_arm -pre aborttrap/atpre.c -updatecache aborttrap/cache/${ABORTTRAP_CACHE}

o.atarm: aborttrap.c.atarm
	${CC} ${CFLAGS} -o $@ aborttrap.c.atarm

od.atarm: aborttrap.c.atarm
	${CC} $(filter-out ${C_NO_FNAMES},${CFLAGS}) ${CDFLAGS} -o $@ aborttrap.c.atarm

#
# Custom ROM:
#
ifneq (objs,$(notdir ${CURDIR}))

rom install_rom: links

else

rom: ${KERNEL_MODULE}
	@${ECHO} ${COMPONENT}: rom module built

install_rom: ${KERNEL_MODULE}
	${CP} ${KERNEL_MODULE} ${INSTDIR}${SEP}${TARGET} ${CPFLAGS}
ifneq (GNU,${TOOLCHAIN})
	${CP} ${KERNEL_MODULE}_gpa ${INSTDIR}${SEP}${TARGET}_gpa ${CPFLAGS}
endif
	@${ECHO} ${COMPONENT}: rom module installed

ifeq (GNU,${TOOLCHAIN})
rom_custom install_rom_custom: ${KERNEL_MODULE}
endif

inst_dirs:
	${MKDIR} ${EXP_HDR}
	${MKDIR} ${C_EXP_HDR}

install: ${EXPORTS} inst_dirs
	@${ECHO} ${COMPONENT}: header files installed

ifeq (GNU,${TOOLCHAIN})
${KERNEL_MODULE}: ${ROM_OBJECTS} ${DIRS} ${LIBS}
	${MKDIR} bin
	${GNUTOOLPREFIX}ld --defsym=KERNEL_ADDRESS=${KERNEL_ADDRESS} -T ../kernel.ld -o ${KERNEL_MODULE}.elf ${ROM_OBJECTS} ${LIBS}
	${LDBIN} ${KERNEL_MODULE} ${KERNEL_MODULE}.elf
else
${KERNEL_MODULE}: ${ROM_OBJECTS} ${DIRS} ${LIBS} kstrip
	${MKDIR} bin
	SetEval KernelBase "4" + STR ( 227858432 + ( HALSize LEFT ( LEN HALSize - 1 ) ) * 1024 )
	Do ${LD} -aif -base <KernelBase> -RW-base 0xff000000 -bin -d -o ${KERNEL_MODULE}_aif ${ROM_OBJECTS} ${LIBS}
	Do kstrip ${KERNEL_MODULE}_aif ${KERNEL_MODULE}
	${TOGPA} -s ${KERNEL_MODULE}_aif ${KERNEL_MODULE}_gpa
endif

GetAll.o: ${TOKHELPSRC}

ifeq (GNU,${TOOLCHAIN})
${TOKENSOURCE}: ${HELPSRC}
	${CP} $< $@
endif

endif

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
