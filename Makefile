THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
$(info THIS_MAKEFILE is $(THIS_MAKEFILE))
GRAMMAR_TOPLEVEL ?= toplevel
GRAMMAR_OPTIONS ?= output=AST
GRAMMAR_PATH ?= .

include config.mk

M4NTLR_PATH ?= $(dir $(THIS_MAKEFILE))/contrib/m4ntlr
ANTLR ?= java -classpath .:$(ANTLR3_JAR):$(CLASSPATH) org.antlr.Tool
export CLASSPATH ANTLR M4NTLR_PATH GRAMMAR_TOPLEVEL GRAMMAR_OPTIONS GRAMMAR_PATH

ifeq ($(ANTLR3_JAR),)
$(error Please set ANTLR3_JAR to the path of a usable ANTLR 3.x JAR)
endif

CFLAGS += -fPIC -g
CFLAGS += -I$(GRAMMAR_PATH)/include
LDLIBS += -lantlr3c

.PHONY: default
default: all

# SPECIAL HACK: bogus Python code is generated (antlr version problem?): 'el\nif'
# so sed the newline out
hdlPyParser.py hdlPyLexer.py \
: sources
	sed -i '/^[[:blank:]]*el$$/ {N; s/\n[[:blank:]]*//}' $@

hdlCParser.c hdlCLexer.c: sources

# We have to ask the Makerules to build both the sources *and*
# the test parser (since it links in the lexer and parser .o files).
export CFLAGS
sources:
	$(MAKE) -f $(M4NTLR_PATH)/Makerules GRAMMAR_BASENAME=hdl \
	    hdlPyLexer.py hdlPyParser.py

hdl_test_parser: hdlCParser.c hdlCLexer.c hdl_test_parser.c
	$(MAKE) -f $(M4NTLR_PATH)/Makerules LDFLAGS=-static CFLAGS=-save-temps \
            GRAMMAR_BASENAME=hdl \
	    hdl_test_parser

all: sources hdlPyParser.py hdlPyLexer.py

clean::
	$(MAKE) -f $(M4NTLR_PATH)/Makerules GRAMMAR_BASENAME=hdl \
	      clean
