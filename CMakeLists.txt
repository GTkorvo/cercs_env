cmake_minimum_required(VERSION 2.8.3)
cmake_policy(VERSION 2.8.3)

project(cercs_env)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set (SRC_LIST env.c trace.c bitarray.c)

include(CheckFunctionExists)
include(CheckIncludeFiles)
include(AddLibtoolLibrary)
include(CTest)

IF( NOT CMAKE_BUILD_TYPE )
SET( CMAKE_BUILD_TYPE "RelWithDebInfo" )
ENDIF()

IF(NOT DEFINED BUILD_SHARED_STATIC)
  SET( BUILD_SHARED_STATIC "BOTH")
ENDIF(NOT DEFINED BUILD_SHARED_STATIC)

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")

set (CMAKE_MACOSX_RPATH 1)

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

ADD_LIBTOOL_LIBRARY(NAME cercs_env SRC_LIST ${SRC_LIST})

set (INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share)

CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)

CHECK_INCLUDE_FILES(stdarg.h STDC_HEADERS)

CONFIGURE_FILE( ${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h )

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

INSTALL(FILES cercs_env.h DESTINATION include)

# display status message for important variables
MESSAGE( STATUS )
MESSAGE( STATUS "-------------------------------------------------------------------------------" )
MESSAGE( STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}" )
MESSAGE( STATUS "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}" )
MESSAGE( STATUS "BUILD_SHARED_STATIC = ${BUILD_SHARED_STATIC}" )
MESSAGE( STATUS "Change a value with: cmake -D<Variable>=<Value>" )
MESSAGE( STATUS "-------------------------------------------------------------------------------" )
MESSAGE( STATUS )

ENABLE_TESTING()
