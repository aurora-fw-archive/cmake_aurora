# ┌─┐┬ ┬┬─┐┌─┐┬─┐┌─┐  ┌─┐┬─┐┌─┐┌┬┐┌─┐┬ ┬┌─┐┬─┐┬┌─
# ├─┤│ │├┬┘│ │├┬┘├─┤  ├┤ ├┬┘├─┤│││├┤ ││││ │├┬┘├┴┐
# ┴ ┴└─┘┴└─└─┘┴└─┴ ┴  └  ┴└─┴ ┴┴ ┴└─┘└┴┘└─┘┴└─┴ ┴
# A Powerful General Purpose Framework
# More information in: https://aurora-fw.github.io/
#
# Copyright (C) 2017 Aurora Framework, All rights reserved.
#
# This file is part of the Aurora Framework. This framework is free
# software; you can redistribute it and/or modify it under the terms of
# the GNU Lesser General Public License version 3 as published by the
# Free Software Foundation and appearing in the file LICENSE included in
# the packaging of this file. Please review the following information to
# ensure the GNU Lesser General Public License version 3 requirements
# will be met: https://www.gnu.org/licenses/lgpl-3.0.html.

###############################################################################
# PCHSupport_FOUND
# AURORA_PRECOMPILE_HEADERS
# AURORA_FORCE_STDLIB
# AURORA_FORCE_NO_STDLIB
# AURORA_STDLIB_CC
# AURORA_STDLIB_CXX
# AURORA_PCH
# ADD_PRECOMPILED_HEADER()
###############################################################################

if(NOT DEFINED AURORAFWBUILD_LOADED)
set(AURORAFWBUILD_LOADED true)
set(AURORAFW_BUILDCONFIG_VERSION_MAJOR )

###############################################################################
# Greetings
###############################################################################

if(NOT AURORAFWBUILD_QUITE_GREETINGS)
	message(STATUS "Loading aurora framework build config...")
	IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
		MESSAGE("[32m┌─┐┬[36m ┬┬─[34m┐┌─┐[35m┬─┐[32m┌─┐[0m  ┌─┐┬─┐┌─┐┌┬┐┌─┐┬ ┬┌─┐┬─┐┬┌─")
		MESSAGE("[36m├─┤│[34m │├┬[35m┘│ │[32m├┬┘[36m├─┤[0m  ├┤ ├┬┘├─┤│││├┤ ││││ │├┬┘├┴┐")
		MESSAGE("[34m┴ ┴└[35m─┘┴└[32m─└─┘[36m┴└─[34m┴ ┴[0m  └  ┴└─┴ ┴┴ ┴└─┘└┴┘└─┘┴└─┴ ┴")
		MESSAGE("A Powerful General Purpose Framework")
		MESSAGE("More information in: https://aurora-fw.github.io/\n")
	ENDIF()
ENDIF()

IF(AURORAFW_IS_BUILDING)
	project(aurorafw)
	message(STATUS "Starting framework build system...")
	if (NOT CONFIGURED_ONCE)
		#Aurora specific flags
		SET(AURORAFW_ROOT_DIR ${CMAKE_SOURCE_DIR})
		#SET(AURORAFW_BUILD_DIR ${AURORAFW_ROOT_DIR}/build)
	endif()

	option(AURORA_TARGET_DOCUMENTATION "Enable documentation target" OFF)
	option(AURORA_DOCUMENTATION_AUTO "Enable automatic documentation building" ON)	
ENDIF()

###############################################################################
# Aurora build system option flags
###############################################################################

OPTION(AURORA_PRECOMPILE_HEADERS "Enable precompilation of headers" OFF)
OPTION(AURORA_FORCE_STDLIB "Force compilation with standard libraries" OFF)
OPTION(AURORA_FORCE_NO_STDLIB "Force compilation without standard libraries" OFF)
OPTION(AURORA_STDLIB_CC "Compile with C standard library" ON)
OPTION(AURORA_STDLIB_CXX "Compile with C++ standard template library" ON)
OPTION(AURORA_PCH "Enable experimental feature: Pre-compiled headers" OFF)

###############################################################################
# General Flags
###############################################################################

IF(NOT CONFIGURED_ONCE)
IF(CMAKE_GENERATOR MATCHES "Ninja")
	SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fdiagnostics-color")
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fdiagnostics-color")
ENDIF()
#Add flag for AFW_EXPORT
IF(AURORA_FORCE_STDLIB)
	add_definitions(-DAFW__FORCE_STDLIB)
ELSEIF(AURORA_FORCE_NO_STDLIB)
	add_definitions(-nostartfiles -nodefaultlibs -nostdlib -DAFW__FORCE_NO_STDLIB)
ENDIF()
IF(AURORA_STDLIB_CXX)
	add_definitions(-DAFW__FORCE_STDLIB_CXX)
else()
	SET(CMAKE_CXX_COMPILER ${CMAKE_C_COMPILER})
	add_definitions(-DAFW__FORCE_NO_STDLIB_CXX)
ENDIF()
IF(AURORA_STDLIB_CC)
	add_definitions(-DAFW__FORCE_STDLIB_CC)
else()
	add_definitions(-nostdlib -DAFW__FORCE_NO_STDLIB_CC)
ENDIF()

add_definitions(-DAFW__COMPILING)
#C++ 17 Standard Revision
set_property(GLOBAL PROPERTY CXX_STANDARD 17)
set_property(GLOBAL PROPERTY CXX_STANDARD_REQUIRED ON)
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	#Add custom flags to the CXX compiler
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Og -g3 -Wall -Wextra -Wformat -pedantic -Wdouble-promotion -std=c++17")
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -g0 -Werror -std=c++17")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	#Add custom flags to the CXX compiler
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Og -g3 -Wall -Wextra -Wformat -pedantic -Wdouble-promotion -std=c++1z")
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -g0 -Werror -std=c++1z")
ENDIF()

#Define output directory
IF(CMAKE_BUILD_TYPE MATCHES Debug)
	add_definitions(-DAFW__DEBUG)
	SET(LIBRARY_OUTPUT_PATH ${AURORAFW_ROOT_DIR}/bin/dbg)
	SET(EXECUTABLE_OUTPUT_PATH ${AURORAFW_ROOT_DIR}/bin/dbg)
else()
	SET(LIBRARY_OUTPUT_PATH ${AURORAFW_ROOT_DIR}/bin)
	SET(EXECUTABLE_OUTPUT_PATH ${AURORAFW_ROOT_DIR}/bin)
ENDIF()
ENDIF()

MACRO(AURORA_ADD_CMAKE_MODULE _name_var _type)
	string(REPLACE " " "_" ___tmp ${_name_var})
	string(TOUPPER ${___tmp} _tmp)
	string(TOLOWER ${_type} __tmp)
	unset(___tmp)
	set(_extra_args ${ARGN})
	list(LENGTH _extra_args _num_extra_args)
	if(${_num_extra_args} LESS 1)
		string(REPLACE " " "/" ____tmp ${_name_var})
		string(TOLOWER ${____tmp} ___tmp)
		unset(____tmp)
		set("AURORAFW_${_type}_${_tmp}_DIR" ${AURORAFW_ROOT_DIR}/${__tmp}s/${___tmp})
		unset(___tmp)
	else()
		list(GET _extra_args 0 _path)
		if(${_type} STREQUAL CMAKE)
			set("${_type}_MODULE_${_tmp}_DIR" ${_path})
		else()
			set("AURORAFW_${_type}_${_tmp}_DIR" ${_path})
		endif()
	endif()
	if(${_type} STREQUAL CMAKE)
		include(${${_type}_MODULE_${_tmp}_DIR}/module.cmake)
	else()
		include(${AURORAFW_${_type}_${_tmp}_DIR}/${__tmp}.cmake)
	endif()
	unset(_tmp)
	unset(__tmp)
ENDMACRO(AURORA_ADD_CMAKE_MODULE)

###############################################################################
# Precompiled Headers
###############################################################################

IF(CMAKE_COMPILER_IS_GNUCXX)
EXEC_PROGRAM(
	${CMAKE_CXX_COMPILER}
	ARGS			--version
	OUTPUT_VARIABLE _compiler_output)
STRING(REGEX REPLACE ".* ([0-9]\\.[0-9]\\.[0-9]) .*" "\\1"
	   gcc_compiler_version ${_compiler_output})
#MESSAGE("GCC Version: ${gcc_compiler_version}")
IF(gcc_compiler_version MATCHES "4\\.[0-9]\\.[0-9]")
	SET(PCHSupport_FOUND TRUE)
ELSE(gcc_compiler_version MATCHES "4\\.[0-9]\\.[0-9]")
	IF(gcc_compiler_version MATCHES "3\\.4\\.[0-9]")
		SET(PCHSupport_FOUND TRUE)
	ENDIF(gcc_compiler_version MATCHES "3\\.4\\.[0-9]")
ENDIF(gcc_compiler_version MATCHES "4\\.[0-9]\\.[0-9]")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

MACRO(ADD_PRECOMPILED_HEADER _targetName _input )

IF(NOT CMAKE_BUILD_TYPE)
	MESSAGE(FATAL_ERROR 
		"This is the ADD_PRECOMPILED_HEADER macro. "
		"You must set CMAKE_BUILD_TYPE!"
	)
ENDIF(NOT CMAKE_BUILD_TYPE)

foreach(_input_file ${_input})
GET_FILENAME_COMPONENT(_name ${_input_file} NAME)
GET_FILENAME_COMPONENT(_path ${_input_file} PATH)
get_filename_component(_result ${_path} ABSOLUTE)
string(REPLACE "${CMAKE_SOURCE_DIR}/" "" _relative_path "${_path}")
SET(_outdir "${CMAKE_SOURCE_DIR}/CMakeFiles/${_targetName}.dir/pch/${_relative_path}")
SET(_output "${_outdir}/${_name}.gch")

list(APPEND _output_list ${_output})
string(CONCAT _output_list_include "-include ${_output} ")

MAKE_DIRECTORY(${_outdir})

STRING(TOUPPER "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}" _flags_var_name)
SET(_compile_FLAGS ${${_flags_var_name}})

GET_DIRECTORY_PROPERTY(_directory_flags INCLUDE_DIRECTORIES)

SET(_CMAKE_CURRENT_BINARY_DIR_included_before_path FALSE)
FOREACH(item ${_directory_flags})
	IF(${item} STREQUAL ${_path} AND NOT _CMAKE_CURRENT_BINARY_DIR_included_before_path )
		MESSAGE(FATAL_ERROR 
			"This is the ADD_PRECOMPILED_HEADER macro. "
			"CMAKE_CURREN_BINARY_DIR has to mentioned at INCLUDE_DIRECTORIES's argument list before ${_path}, where ${_name} is located"
		)	
	ENDIF(${item} STREQUAL ${_path} AND NOT _CMAKE_CURRENT_BINARY_DIR_included_before_path )

	IF(${item} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})
		SET(_CMAKE_CURRENT_BINARY_DIR_included_before_path TRUE)
	ENDIF(${item} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})

	LIST(APPEND _compile_FLAGS "-I${item}")
ENDFOREACH(item)

GET_DIRECTORY_PROPERTY(_directory_flags DEFINITIONS)
LIST(APPEND _compile_FLAGS ${_directory_flags})

SEPARATE_ARGUMENTS(_compile_FLAGS)
#MESSAGE("_compiler_FLAGS: ${_compiler_FLAGS}")
#MESSAGE("COMMAND ${CMAKE_CXX_COMPILER}	${_compile_FLAGS} -x c++-header -o ${_output} ${_input_file}")

ADD_CUSTOM_COMMAND(
	OUTPUT ${_output}
	COMMAND ${CMAKE_CXX_COMPILER}
			${_compile_FLAGS} -DAFW__PHC
			-x c++-header
			-o ${_output}
			${_input_file}
	DEPENDS ${_input_file} ${_outdir}
)
endforeach(_input_file)

ADD_CUSTOM_TARGET(${_targetName}_gch
	DEPENDS	${_output_list}
)
ADD_DEPENDENCIES(${_targetName} ${_targetName}_gch )
SET_TARGET_PROPERTIES(${_targetName}
	PROPERTIES
		COMPILE_FLAGS "-I${CMAKE_SOURCE_DIR}/CMakeFiles/${_targetName}.dir/pch -Winvalid-pch"
)

ENDMACRO(ADD_PRECOMPILED_HEADER)

################################################################################
# Package finder
################################################################################

# Begin processing of package
MACRO(FINDPKG_BEGIN _PREFIX)
IF(NOT ${_PREFIX}_FIND_QUIETLY)
	MESSAGE(STATUS "Looking for ${_PREFIX}...")
ENDIF()
ENDMACRO(FINDPKG_BEGIN)

# Display a status message unless FIND_QUIETLY is set
macro(pkg_message PREFIX)
if (NOT ${PREFIX}_FIND_QUIETLY)
	message(STATUS ${ARGN})
endif ()
endmacro(pkg_message)

# Get environment variable, define it as ENV_$var and make sure backslashes are converted to forward slashes
macro(getenv_path VAR)
 set(ENV_${VAR} $ENV{${VAR}})
 # replace won't work if var is blank
 if (ENV_${VAR})
	 string( REGEX REPLACE "\\\\" "/" ENV_${VAR} ${ENV_${VAR}} )
 endif ()
endmacro(getenv_path)

# Construct search paths for includes and libraries from a PREFIX_PATH
macro(create_search_paths PREFIX)
foreach(dir ${${PREFIX}_PREFIX_PATH})
	set(${PREFIX}_INC_SEARCH_PATH ${${PREFIX}_INC_SEARCH_PATH}
		${dir}/include ${dir}/Include ${dir}/include/${PREFIX} ${dir}/Headers)
	set(${PREFIX}_LIB_SEARCH_PATH ${${PREFIX}_LIB_SEARCH_PATH}
		${dir}/lib ${dir}/Lib ${dir}/lib/${PREFIX} ${dir}/Libs)
	set(${PREFIX}_BIN_SEARCH_PATH ${${PREFIX}_BIN_SEARCH_PATH}
		${dir}/bin)
endforeach(dir)
if(ANDROID)
set(${PREFIX}_LIB_SEARCH_PATH ${${PREFIX}_LIB_SEARCH_PATH} lib/${ANDROID_ABI})
endif()
set(${PREFIX}_FRAMEWORK_SEARCH_PATH ${${PREFIX}_PREFIX_PATH})
endmacro(create_search_paths)

# clear cache variables if a certain variable changed
macro(clear_if_changed TESTVAR)
# test against internal check variable
# HACK: Apparently, adding a variable to the cache cleans up the list
# a bit. We need to also remove any empty strings from the list, but
# at the same time ensure that we are actually dealing with a list.
list(APPEND ${TESTVAR} "")
list(REMOVE_ITEM ${TESTVAR} "")
if (NOT "${${TESTVAR}}" STREQUAL "${${TESTVAR}_INT_CHECK}")
	message(STATUS "${TESTVAR} changed.")
	foreach(var ${ARGN})
		set(${var} "NOTFOUND" CACHE STRING "x" FORCE)
	endforeach(var)
endif ()
set(${TESTVAR}_INT_CHECK ${${TESTVAR}} CACHE INTERNAL "x" FORCE)
endmacro(clear_if_changed)

# Try to get some hints from pkg-config, if available
macro(use_pkgconfig PREFIX PKGNAME)
if(NOT ANDROID)
	find_package(PkgConfig)
	if (PKG_CONFIG_FOUND)
		pkg_check_modules(${PREFIX} ${PKGNAME})
	endif ()
endif()
endmacro (use_pkgconfig)

# Couple a set of release AND debug libraries (or frameworks)
macro(make_library_set PREFIX)
if (${PREFIX}_FWK)
	set(${PREFIX} ${${PREFIX}_FWK})
elseif (${PREFIX}_REL AND ${PREFIX}_DBG)
	set(${PREFIX} optimized ${${PREFIX}_REL} debug ${${PREFIX}_DBG})
elseif (${PREFIX}_REL)
	set(${PREFIX} ${${PREFIX}_REL})
elseif (${PREFIX}_DBG)
	set(${PREFIX} ${${PREFIX}_DBG})
endif ()
endmacro(make_library_set)

# Generate debug names from given release names
macro(get_debug_names PREFIX)
foreach(i ${${PREFIX}})
	set(${PREFIX}_DBG ${${PREFIX}_DBG} ${i}d ${i}D ${i}_d ${i}_D ${i}_debug)
endforeach(i)
endmacro(get_debug_names)

# Add the parent dir from DIR to VAR
macro(add_parent_dir VAR DIR)
get_filename_component(${DIR}_TEMP "${${DIR}}/.." ABSOLUTE)
set(${VAR} ${${VAR}} ${${DIR}_TEMP})
endmacro(add_parent_dir)

# Do the final processing for the package find.
macro(FINDPKG_FINISH PREFIX)
# skip if already processed during this run
if (NOT ${PREFIX}_FOUND)
	if (${PREFIX}_INCLUDE_DIR AND ${PREFIX}_LIBRARY)
		set(${PREFIX}_FOUND TRUE)
		set(${PREFIX}_INCLUDE_DIRS ${${PREFIX}_INCLUDE_DIR})
		set(${PREFIX}_LIBRARIES ${${PREFIX}_LIBRARY})
		if (NOT ${PREFIX}_FIND_QUIETLY)
			message(STATUS "Found ${PREFIX}: ${${PREFIX}_LIBRARIES}")
		endif ()
	else ()
		if (NOT ${PREFIX}_FIND_QUIETLY)
			message(STATUS "Could not locate ${PREFIX}")
		endif ()
		if (${PREFIX}_FIND_REQUIRED)
			message(FATAL_ERROR "Required library ${PREFIX} not found! Install the library (including dev packages) and try again. If the library is already installed, set the missing variables manually in cmake.")
		endif ()
	endif ()

	mark_as_advanced(${PREFIX}_INCLUDE_DIR ${PREFIX}_LIBRARY ${PREFIX}_LIBRARY_REL ${PREFIX}_LIBRARY_DBG ${PREFIX}_LIBRARY_FWK)
endif ()
endmacro(FINDPKG_FINISH)


# Slightly customised framework finder
macro(findpkg_framework fwk)
if(APPLE)
	set(${fwk}_FRAMEWORK_PATH
		${${fwk}_FRAMEWORK_SEARCH_PATH}
		${CMAKE_FRAMEWORK_PATH}
		~/Library/Frameworks
		/Library/Frameworks
		/System/Library/Frameworks
		/Network/Library/Frameworks
		${CMAKE_CURRENT_SOURCE_DIR}/lib/macosx/Release
		${CMAKE_CURRENT_SOURCE_DIR}/lib/macosx/Debug
	)
	# These could be arrays of paths, add each individually to the search paths
	foreach(i ${PREFIX_PATH})
		set(${fwk}_FRAMEWORK_PATH ${${fwk}_FRAMEWORK_PATH} ${i}/lib/macosx/Release ${i}/lib/macosx/Debug)
	endforeach(i)

	foreach(i ${PREFIX_BUILD})
		set(${fwk}_FRAMEWORK_PATH ${${fwk}_FRAMEWORK_PATH} ${i}/lib/macosx/Release ${i}/lib/macosx/Debug)
	endforeach(i)

	foreach(dir ${${fwk}_FRAMEWORK_PATH})
		set(fwkpath ${dir}/${fwk}.framework)
		if(EXISTS ${fwkpath})
			set(${fwk}_FRAMEWORK_INCLUDES ${${fwk}_FRAMEWORK_INCLUDES}
				${fwkpath}/Headers ${fwkpath}/PrivateHeaders)
			set(${fwk}_FRAMEWORK_PATH ${dir})
			if (NOT ${fwk}_LIBRARY_FWK)
				set(${fwk}_LIBRARY_FWK "-framework ${fwk}")
			endif ()
		endif(EXISTS ${fwkpath})
	endforeach(dir)
endif(APPLE)
endmacro(findpkg_framework)

##################################################################

# Available platform targets (AURORA_PLATFORM_TARGET):
# 	- linux
# 	- win
# 	- android
# 	- default (auto detection)

# Available compilers (AURORA_COMPILER_TARGET):
# 	- gcc
# 	- clang
# 	- mingw
# 	- default (auto detection)

IF(AURORA_PLATFORM_TARGET MATCHES "linux")
IF(AURORA_COMPILER_TARGET MATCHES "gcc")
	IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
		SET(CMAKE_C_COMPILER "/usr/bin/gcc")
		SET(CMAKE_CXX_COMPILER "/usr/bin/g++")
	ENDIF()
ELSEIF(AURORA_COMPILER_TARGET MATCHES "clang")
	IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
		SET(CMAKE_C_COMPILER "/usr/bin/clang")
		SET(CMAKE_CXX_COMPILER "/usr/bin/clang++")

		SET(CMAKE_AR "/usr/bin/llvm-ar")
		SET(CMAKE_LINKER "/usr/bin/llvm-ld")
		SET(CMAKE_NM "/usr/bin/llvm-nm")
		SET(CMAKE_OBJDUMP "/usr/bin/llvm-objdump")
		SET(CMAKE_RANLIB "/usr/bin/llvm-ranlib")

		SET(CMAKE_C_FLAGS_INIT "-Wall -std=c99")
		SET(CMAKE_C_FLAGS_DEBUG_INIT "-g")
		SET(CMAKE_C_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
		SET(CMAKE_C_FLAGS_RELEASE_INIT "-O4 -DNDEBUG")
		SET(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")
		
		SET(CMAKE_CXX_FLAGS_INIT "-Wall")
		SET(CMAKE_CXX_FLAGS_DEBUG_INIT "-g")
		SET(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
		SET(CMAKE_CXX_FLAGS_RELEASE_INIT "-O4 -DNDEBUG")
		SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")
	ENDIF()
ENDIF()
SET(AURORA_PLATFORM_PREFIX "linux")
ELSEIF(AURORA_PLATFORM_TARGET MATCHES "win" OR AURORA_PLATFORM_TARGET MATCHES "windows")
IF(AURORA_COMPILER_TARGET MATCHES "mingw")
	IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
		IF(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86_64")
			SET(CMAKE_C_COMPILER "/usr/bin/x86_64-w64-mingw32-gcc")
			SET(CMAKE_CXX_COMPILER "/usr/bin/x86_64-w64-mingw32-g++")
		ELSEIF(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i686")
			SET(CMAKE_C_COMPILER "/usr/bin/i686-w64-mingw32-gcc")
			SET(CMAKE_CXX_COMPILER "/usr/bin/i686-w64-mingw32-g++")
		ENDIF()
	ENDIF()
ENDIF()
SET(AURORA_PLATFORM_PREFIX "win")
ELSE()
SET(AURORA_PLATFORM_TARGET "default")
IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
	SET(AURORA_PLATFORM_PREFIX "linux")
ELSEIF(CMAKE_SYSTEM_NAME MATCHES "Windows")
	SET(AURORA_PLATFORM_PREFIX "win")
ELSEIF(CMAKE_SYSTEM_NAME MATCHES "Darwin")
	SET(AURORA_PLATFORM_PREFIX "darwin")
ELSE()
	SET(AURORA_PLATFORM_PREFIX "unknown")
ENDIF()
ENDIF()

# Available CPU Architecture targets (AURORA_CPUARCH_TARGET):
# 	- x86_64
# 	- x86
# 	- arm
# 	- aarch64
# 	- default (auto detection)

IF(AURORA_CPUARCH_TARGET MATCHES "x86_64")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m64")
IF(CMAKE_C_COMPILER MATCHES "/usr/bin/i686-w64-mingw32-gcc" OR CMAKE_CXX_COMPILER STREQUAL "/usr/bin/i686-w64-mingw32-g++")
	SET(CMAKE_C_COMPILER "/usr/bin/x86_64-w64-mingw32-gcc")
	SET(CMAKE_CXX_COMPILER "/usr/bin/x86_64-w64-mingw32-g++")
ENDIF()
SET(AURORA_CPUARCH_PREFIX "x86_64")
ELSEIF(AURORA_CPUARCH_TARGET MATCHES "x86")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32")
IF(CMAKE_C_COMPILER MATCHES "/usr/bin/x86_64-w64-mingw32-gcc" OR CMAKE_CXX_COMPILER STREQUAL "/usr/bin/x86_64-w64-mingw32-g++")
	SET(CMAKE_C_COMPILER "/usr/bin/i686-w64-mingw32-gcc")
	SET(CMAKE_CXX_COMPILER "/usr/bin/i686-w64-mingw32-g++")
ENDIF()
SET(AURORA_CPUARCH_PREFIX "x86")
ELSEIF(AURORA_CPUARCH_TARGET MATCHES "arm")
IF(AURORA_COMPILER_TARGET MATCHES "gcc" OR AURORA_COMPILER_TARGET MATCHES "default")
	IF(CMAKE_SYSTEM_NAME MATCHES "Linux")	
		SET(CMAKE_C_COMPILER "/usr/bin/arm-none-eabi-gcc")
		SET(CMAKE_C_COMPILER "/usr/bin/arm-none-eabi-g++")
	ENDIF()
ENDIF()
SET(AURORA_CPUARCH_PREFIX "arm")
ELSEIF(AURORA_CPUARCH_TARGET MATCHES "aarch64")
IF(AURORA_COMPILER_TARGET MATCHES "gcc" OR AURORA_COMPILER_TARGET MATCHES "default")
	IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
		SET(CMAKE_C_COMPILER "/usr/bin/aarch64-linux-gnu-gcc")
		SET(CMAKE_C_COMPILER "/usr/bin/aarch64-linux-gnu-g++")
	ENDIF()
ENDIF()
SET(AURORA_CPUARCH_PREFIX "aarch64")
ELSE()
SET(AURORA_CPUARCH_TARGET "default")
SET(AURORA_CPUARCH_PREFIX ${CMAKE_HOST_SYSTEM_PROCESSOR})
ENDIF()

endif(NOT DEFINED AURORAFWBUILD_LOADED)