## Process this file with automake to produce Makefile.in

AUTOMAKE_OPTIONS = no-dependencies foreign

lib_LTLIBRARIES = libcercs_env.la

noinst_HEADERS = 

EXTRA_libcercs_env_la_SOURCES = timing_hrtime.c timing_gettimeofday.c

libcercs_env_la_SOURCES = env.c $(TIMING_C)
libcercs_env_la_LIBADD =  $(TIMING_O)
libcercs_env_la_LDFLAGS = -no-undefined
libcercs_env_la_DEPENDENCIES = $(TIMING_O)

include_HEADERS = cercs_env.h


bin_PROGRAMS = 

LIBS = @LIBS@
