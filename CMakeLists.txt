cmake_minimum_required(VERSION 2.8.3)
cmake_policy(VERSION 2.8.3)

execute_process(COMMAND "cercs_arch" ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE OUTPUT_VARIABLE Cercs_Arch)
message ( STATUS "CERCS ARCH is ${Cercs_Arch}")
if (NOT "${Cercs_Arch}" MATCHES "") 
   set (CMAKE_LIBRARY_ARCHITECTURE "${Cercs_Arch}")
endif()


project(cercs_env)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set (SRC_LIST env.c trace.c bitarray.c)

include(CheckFunctionExists)
include(CheckIncludeFiles)
include(CreateLibtoolFile)
include(CTest)

IF( NOT CMAKE_BUILD_TYPE )
SET( CMAKE_BUILD_TYPE "RelWithDebInfo" )
ENDIF()
option(BUILD_STATIC "enable building the static library" ON)
option(BUILD_DYNAMIC "enable building the dynamic library" ON)

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

set (INSTALL_TARGETS)
if (BUILD_DYNAMIC)
  add_library(cercs_env SHARED ${SRC_LIST})
  LIST(APPEND INSTALL_TARGETS cercs_env)
endif (BUILD_DYNAMIC)
if (BUILD_STATIC)
  add_library(cercs_env-static STATIC ${SRC_LIST})
  # The library target "cercs_env" already has a default OUTPUT_NAME of "cercs_env", so we don't need to change it.
  # The library target "cercs_env-static" has a default OUTPUT_NAME of "cercs_env-static", so change it.
  SET_TARGET_PROPERTIES(cercs_env-static PROPERTIES OUTPUT_NAME "cercs_env")
  # Now the library target "foo-static" will be named "foo.lib" with MS tools.
  # This conflicts with the "foo.lib" import library corresponding to "foo.dll",
  # so we add a "lib" prefix (which is default on other platforms anyway):
  SET_TARGET_PROPERTIES(cercs_env-static PROPERTIES PREFIX "lib")
  SET_TARGET_PROPERTIES(cercs_env PROPERTIES STATIC_LIB "libcercs_env.a")
  SET_TARGET_PROPERTIES(cercs_env PROPERTIES LT_SHOULDNOTLINK "no")
  LIST(APPEND INSTALL_TARGETS cercs_env-static)
endif (BUILD_STATIC)

set (INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share)

CREATE_LIBTOOL_FILE(cercs_env /lib)

CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)

CHECK_INCLUDE_FILES(stdarg.h STDC_HEADERS)

CONFIGURE_FILE( ${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h )

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

INSTALL(FILES cercs_env.h DESTINATION include)
INSTALL(TARGETS ${INSTALL_TARGETS}
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)


# display status message for important variables
MESSAGE( STATUS )
MESSAGE( STATUS "-------------------------------------------------------------------------------" )
MESSAGE( STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}" )
MESSAGE( STATUS "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}" )
MESSAGE( STATUS "BUILD_STATIC = ${BUILD_STATIC}" )
MESSAGE( STATUS "BUILD_DYNAMIC = ${BUILD_DYNAMIC}" )
MESSAGE( STATUS "Change a value with: cmake -D<Variable>=<Value>" )
MESSAGE( STATUS "-------------------------------------------------------------------------------" )
MESSAGE( STATUS )

ENABLE_TESTING()
