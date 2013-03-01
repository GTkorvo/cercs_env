#
#  ADD_KAOS_LIBRARY -  Thu Feb 28 16:08:06 EST 2013
#
#  Use this macro like this:
# ADD_KAOS_LIBRARY(project_name 
#   LIBRARY library
#   INCLUDES header1 header2 ...
#   [REQUIRED]
#   [STATIC]
#   [DYNAMIC]
#   [USE_INSTALLED]
#   [VERBOSE]
#   [QUIET]
#   )
#  
#  the first parameter is the project name.
#  LIBRARY is the name of the library to create
#  SRC_LIST is a list of source files to include

#  REQUIRED fails the build if all not present
#  VERBOSE includes some output about the search path
#  QUIET suppresses the 'found' message
#  USE_INSTALLED avoids searching home and relative-path directories
#
#  the project name is used in directory specs for searching.
#  
#  If both the library and include file are found, then we define the
#  variables:
#  <PROJECT>_FOUND   (where <PROJECT> is the upper-case version of the
#    project argument)
# <PROJECT>_LIB_DIR (suitable for LINK_DIRECTORY calls)
# <PROJECT>_INCLUDE_DIR (suitable for INCLUDE_DIRECTORY calls)
# <PROJECT>_LIBRARIES (full path to a library file)
# HAVE_<include_file>   for each include file found (UPCASED, dot is underscore)
#
include(CMakeParseArguments)
include(CreateLibtoolFile)

FUNCTION (ADD_KAOS_LIBRARY)
  set(options NO_LIBTOOL)
  set(oneValueArgs NAME)
  set(multiValueArgs SRC_LIST DEP_LIBS)
  CMAKE_PARSE_ARGUMENTS(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  file (STRINGS "${CMAKE_SOURCE_DIR}/version.c" VERSION_TEXT REGEX "^static.*")
  if (${VERSION_TEXT} MATCHES ".*${NAME}.*") 
    STRING(REGEX REPLACE ".*Version ([0-9]+.[0-9]+.[0-9]+).*" "\\1" VERSION_TEXT "${VERSION_TEXT}")
    STRING(REGEX REPLACE "([0-9]+)[.][0-9.]*$" "\\1" MAJOR_VERSION_STRING ${VERSION_TEXT})
    STRING(REGEX REPLACE "[0-9]+[.]([0-9]+)[.][0-9.]*$" "\\1" MINOR_VERSION_STRING ${VERSION_TEXT})
    STRING(REGEX REPLACE "[0-9]+[.][0-9]+[.]([0-9]*)$" "\\1" REVISION_STRING ${VERSION_TEXT})
  else (${VERSION_TEXT} MATCHES ".*${NAME}.*") 
    set(VERSION_TEXT "")
  endif (${VERSION_TEXT} MATCHES ".*${NAME}.*") 

  message(STATUS "MAJOR version string ${MAJOR_VERSION_STRING}")
  message(STATUS "MINOR version string ${MINOR_VERSION_STRING}")
  message(STATUS "REVISION version string ${REVISION_STRING}")
  message(STATUS " version text ${VERSION_TEXT}")

  IF (NOT (DEFINED BUILD_SHARED_LIBS))
    message(STATUS "BUILD SHARED LIBS NOT DEFINED")
     set (BUILD_STATIC TRUE)
     set (BUILD_SHARED TRUE)
  else (NOT (DEFINED BUILD_SHARED_LIBS)) 
    message(STATUS "BUILD SHARED LIBS is ${BUILD_SHARED_LIBS}")
     if (${BUILD_SHARED_LIBS} STREQUAL "ON") 
       set (BUILD_STATIC FALSE)
       set (BUILD_SHARED TRUE)
     else (${BUILD_SHARED_LIBS} STREQUAL "ON") 
       set (BUILD_SHARED FALSE)
       set (BUILD_STATIC TRUE)
     endif (${BUILD_SHARED_LIBS} STREQUAL "ON") 
  endif (NOT (DEFINED BUILD_SHARED_LIBS)) 

  set (BUILD_LIBTOOL TRUE)
  if (${ARG_NO_LIBTOOL})
    set (BUILD_LIBTOOL FALSE)
  endif (${ARG_NO_LIBTOOL})
  message (STATUS "build static ${BUILD_STATIC}  build shared ${BUILD_SHARED}")
  set (STATIC_TARGET_NAME ${ARG_NAME})

  if (${BUILD_SHARED}) 
    message (STATUS "doing  build shared ${BUILD_SHARED}")
    
    add_library( ${ARG_NAME} SHARED ${ARG_SRC_LIST})
    SET_TARGET_PROPERTIES(${ARG_NAME} PROPERTIES LINKER_LANGUAGE C)
    TARGET_LINK_LIBRARIES(${ARG_NAME} ${ARG_DEP_LIBS})
    SET_TARGET_PROPERTIES(${ARG_NAME} PROPERTIES LT_SHOULDNOTLINK "no")
    if (NOT "${VERSION_TEXT}" STREQUAL "")
      message (STATUS "setting version stuff")
	set_target_properties(${ARG_NAME}  PROPERTIES VERSION "${VERSION_TEXT}" SOVERSION "${MAJOR_VERSION_STRING}")
	set_target_properties(${ARG_NAME} PROPERTIES LT_VERSION_CURRENT "${MAJOR_VERSION_STRING}")
	set_target_properties(${ARG_NAME} PROPERTIES LT_VERSION_AGE "${MINOR_VERSION_STRING}")
	set_target_properties(${ARG_NAME} PROPERTIES LT_VERSION_REVISION "${REVISION_STRING}")
    endif (NOT "${VERSION_TEXT}" STREQUAL "")
    INSTALL( TARGETS ${ARG_NAME} DESTINATION lib)
    set (STATIC_TARGET_NAME ${ARG_NAME}-static)
  endif (${BUILD_SHARED}) 

  if (${BUILD_STATIC}) 
    add_library(${STATIC_TARGET_NAME} STATIC ${ARG_SRC_LIST})
    # The library target "${ARG_NAME}-static" has a default OUTPUT_NAME of "${ARG_NAME}-static", so change it.
    if (NOT (${STATIC_TARGET_NAME} STREQUAL ${ARG_NAME})) 
      SET_TARGET_PROPERTIES(${ARG_NAME}-static PROPERTIES OUTPUT_NAME "${ARG_NAME}" )
      # Now the library target "foo-static" will be named "foo.lib" with MS tools.
      # This conflicts with the "foo.lib" import library corresponding to "foo.dll",
      # so we add a "lib" prefix (which is default on other platforms anyway):
      SET_TARGET_PROPERTIES(${ARG_NAME}-static PROPERTIES PREFIX "lib" LINKER_LANGUAGE C)
    endif (NOT (${STATIC_TARGET_NAME} STREQUAL ${ARG_NAME})) 
    SET_TARGET_PROPERTIES(${ARG_NAME} PROPERTIES STATIC_LIB "lib${ARG_NAME}.a")
    INSTALL(TARGETS ${STATIC_TARGET_NAME} DESTINATION lib)
  endif (${BUILD_STATIC}) 

  message(STATUS "buidl libtool is ${BUILD_LIBTOOL}")
  if (${BUILD_LIBTOOL})
      CREATE_LIBTOOL_FILE(${ARG_NAME} /lib)
  endif (${BUILD_LIBTOOL})

ENDFUNCTION()
