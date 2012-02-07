cmake_minimum_required(VERSION 2.8)
project(cercs_env)
set (SRC_LIST env.c trace.c bitarray.c)

include(CheckFunctionExists)
include(CheckIncludeFiles)

if (CMAKE_COMPILER_IS_GNUCC AND ("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "i.86")) 
	set (TIMING timing_gcc_x86.c)
ENDIF (CMAKE_COMPILER_IS_GNUCC AND ("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "i.86")) 

CHECK_FUNCTION_EXISTS(hrtime HAVE_HRTIME)

IF (HAVE_HRTIME)
   set (TIMING timing_hrtime.c)
ENDIF (HAVE_HRTIME)

IF (NOT DEFINED(TIMING)) 
   set (TIMING timing_gettimeofday.c)
ENDIF (NOT DEFINED(TIMING)) 
set (SRC_LIST ${SRC_LIST} ${TIMING})
add_library(cercs_env SHARED ${SRC_LIST})
add_library(cercs_env-static STATIC ${SRC_LIST})
# The library target "cercs_env" already has a default OUTPUT_NAME of "cercs_env", so we don't need to change it.
# The library target "cercs_env-static" has a default OUTPUT_NAME of "cercs_env-static", so change it.
SET_TARGET_PROPERTIES(cercs_env-static PROPERTIES OUTPUT_NAME "cercs_env")
# Now the library target "foo-static" will be named "foo.lib" with MS tools.
# This conflicts with the "foo.lib" import library corresponding to "foo.dll",
# so we add a "lib" prefix (which is default on other platforms anyway):
SET_TARGET_PROPERTIES(cercs_env-static PROPERTIES PREFIX "lib")

set (INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share)

CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)

CHECK_INCLUDE_FILES(stdarg.h STDC_HEADERS)

CONFIGURE_FILE( ${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_SOURCE_DIR}/config.h )

INSTALL(FILES cercs_env.h DESTINATION include)
INSTALL(TARGETS cercs_env cercs_env-static
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
