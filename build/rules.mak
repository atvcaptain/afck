# For tolerance we always use bash
export SHELL := /bin/bash

include build/colors.mak

# ----------- # Default target # ----------- #
.PHONY: all show-rules
all: help

# ---------- # Useful variables # ---------- #

# Translation of the line
define NL


endef
# Comma (use $(COMMA) in places where a simple comma has a special meaning)
COMMA=,
# Pacifier
EMPTY=
# The gap
SPACE=$(EMPTY) $(EMPTY)
# Text output in argument $1 on the terminal
SAY = echo -e '$(subst $(NL),\n,$(subst ','\'',$1))'
# Create a subdirectory with all intermediate subdirectories
MKDIR = mkdir -p "$(1:/=)"
# Deleting $1 file without shouting
RM = rm -f "$1"
# Recursive removal of $1 directory without questions
RMDIR = rm -rf "$1"
# Copy $1 to $2 file
CP = cp -dP --preserve=mode,links,xattr "$1" "$2"
# Navigate/move $1 to $2 file
MV = mv -f "$1" "$2"
# Creating a symbolic link
LN_S = ln -fs "$1" "$2"
# Recursive copying of $1 to $2 catalog
RCP = cp -a "$1" "$2"
# Update the time stamp of the last modification on the file
TOUCH = touch "$1"
# Write the text $2 to file $1
FWRITE = $(call SAY,$2) > "$1"
# Add text $2 to file $1
FAP = $(call SAY,$2) >> "$1"
# Copy a $1 to $2 file if they differ
UCOPY = cmp -s "$1" "$2" || cp -a "$1" "$2"
# Move the file $1 to $2 if they are different, otherwise remove $1
UMOVE = cmp -s "$1" "$2" && rm -f "$1" || mv -f "$1" "$2"
# Translation of ASCII string $1 into lower case
LOWCASE = $(shell echo '$1' | tr A-Z a-z)
# The rule for calculating the sum of two numbers
ADD = $(shell expr '$1' + '$2')
# Separator line -- $- :-)
-=------------------------------------------------------------------------
# Current date and time
DATE = $(shell date +%x)
TIME = $(shell date +%X)
# The function to compare the version number
VER_CHECK = $(shell expr $1 '>' $3 '|' '(' $1 '==' $3 '&' $2 '>=' $4 ')')

# Senior and junior MAKE version number
MAKEVER_HI := $(word 1,$(subst .,$(SPACE),$(MAKE_VERSION)))
MAKEVER_LO := $(word 2,$(subst .,$(SPACE),$(MAKE_VERSION)))
# GNU Make is required at least 3.0
ifneq ($(call VER_CHECK,$(MAKEVER_HI),$(MAKEVER_LO),3,0),1)
$(error AFCK build system requires GNU Make version 3.0 or higher)
endif

# ---------- # Catalogs and utilities # ---------- #

# Basic directory for generated files
OUT = out/$(TARGET)/
# bc-tool dir
BCT.DIR = bc-tool/
# bc-tool stamp dir
STAMPDIR = ${BCT.DIR}stamp/
# odm dir
ODM = ${BCT.DIR}odm/odm
# product dir
PRODUCT = ${BCT.DIR}product/product
# vendor dir
VENDOR = ${BCT.DIR}vendor/vendor
# system dir
SYSTEM = ${BCT.DIR}system/system
# odm contexts
O.SELINUX = $(BCT.DIR)odm/selinux
# product contexts
P.SELINUX = $(BCT.DIR)product/selinux
# vendor contexts
V.SELINUX = $(BCT.DIR)vendor/selinux
# system contexts
S.SELINUX = $(BCT.DIR)system/selinux
# Directory with files for the target platform
TARGET.DIR = build/$(TARGET)/
# Function to add a description of $2 target $1
HELPL = $(NL)$(C.BOLD) $(strip $1)$(C.RST) - $(strip $2)

ifndef HOST.OS
# Automatic detection of the operating system in which the build is performed
ifneq ($(COMSPEC)$(ComSpec),)
HOST.OS = windows
else
HOST.OS = $(call LOWCASE,$(shell uname -s))
endif
endif
# Directory with utilities for the current operating system
TOOLS.DIR = tools/$(HOST.OS)/

# System-dependent utilities
include build/rules-$(HOST.OS).mak
# Just useful features
include build/utility.mak

# Check condition $1, print error $2 if condition is not empty
ASSERT = $(if $(strip $1),,$(error $(C.ERR)$2$(C.RST)))

# General rules
include build/common.mak

# Rules for the target platform
$(call ASSERT.FILE,$(TARGET.DIR)rules.mak)
include $(TARGET.DIR)rules.mak

