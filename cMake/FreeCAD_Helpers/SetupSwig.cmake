macro(SetupSwig)

#-------------------------------- Swig ----------------------------------

# force cmake to re-search for SWIG when CMAKE_PREFIX_PATH changes
unset(SWIG_EXECUTABLE CACHE)
unset(SWIG_DIR CACHE)
unset(SWIG_VERSION CACHE)
unset(SWIG_FOUND CACHE)

if(BUILD_SKETCHER)
    # SWIG is required for sketcher WB (use QUIET to provide custom error message)
    find_package(SWIG QUIET)

    if(NOT SWIG_FOUND)
        message(FATAL_ERROR
                "-----------------------------------------------------\n"
                "SWIG not found, swig & pivy required for sketcher WB.\n"
                "-----------------------------------------------------\n")
        # do not continue with check if swig not found
        return()
    endif()

    # check swig/pivy runtime compatibility
    message(STATUS "checking SWIG/Pivy runtime compatibility...")

    # get SWIG's runtime version using -external-runtime flag
    execute_process(
        COMMAND ${SWIG_EXECUTABLE} -python -external-runtime "${CMAKE_BINARY_DIR}/swig_runtime_check.h"
        ERROR_QUIET
    )

    if(EXISTS "${CMAKE_BINARY_DIR}/swig_runtime_check.h")
        file(STRINGS "${CMAKE_BINARY_DIR}/swig_runtime_check.h"
            SWIG_RUNTIME_VERSION_LINE
            REGEX "^#define SWIG_RUNTIME_VERSION")

        if(SWIG_RUNTIME_VERSION_LINE)
            # extract the version number (it's in quotes: "5")
            string(REGEX MATCH "\"([0-9]+)\"" _ "${SWIG_RUNTIME_VERSION_LINE}")
            set(SWIG_RUNTIME_VERSION "${CMAKE_MATCH_1}")
        endif()

        file(REMOVE "${CMAKE_BINARY_DIR}/swig_runtime_check.h")
    endif()

    # extract pivy's SWIG runtime version from the compiled module
    # NOTE: python code can not be indented
    set(PYTHON_CHECK_PIVY_RUNTIME [=[
import sys
import os

try:
    import pivy
    pivy_dir = os.path.dirname(pivy.__file__)
    pivy_path = None

    # look for _coin module with any extension (.so on unix, .pyd on windows)
    for f in os.listdir(pivy_dir):
        if f.startswith('_coin') and (f.endswith('.so') or f.endswith('.pyd')):
            pivy_path = os.path.join(pivy_dir, f)
            break

    if pivy_path and os.path.exists(pivy_path):
        if sys.platform == 'win32':
            # windows: read binary file directly (no `strings` command)
            with open(pivy_path, 'rb') as f:
                content = f.read().decode('latin-1', errors='ignore')
        else:
            # unix: use `strings` command
            import subprocess
            result = subprocess.run(['strings', pivy_path],
                    capture_output=True, text=True, check=True)
            content = result.stdout

        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('swig_runtime_data') and len(line) > 17:
                suffix = line[17:]
                if suffix.isdigit():
                    print(suffix)
                    break
except ImportError:
    print('ERROR_IMPORT')
except Exception:
    pass
]=])

    execute_process(
        COMMAND ${Python3_EXECUTABLE} -c "${PYTHON_CHECK_PIVY_RUNTIME}"
        OUTPUT_VARIABLE PIVY_RUNTIME_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        TIMEOUT 10
    )

    # Handle errors and compare versions
    if(PIVY_RUNTIME_VERSION STREQUAL "ERROR_IMPORT")
        message(WARNING
            "Could not import pivy to check SWIG compatibility.\n"
            "Proceeding without SWIG version check."
        )
    elseif(SWIG_RUNTIME_VERSION AND PIVY_RUNTIME_VERSION)
        if(NOT SWIG_RUNTIME_VERSION STREQUAL PIVY_RUNTIME_VERSION)
            message(FATAL_ERROR
" --------------------------------------------------------
 SWIG / PIVY RUNTIME VERSION MISMATCH DETECTED!
 
 SWIG runtime version: ${SWIG_RUNTIME_VERSION}
 Pivy runtime version: ${PIVY_RUNTIME_VERSION}
  
 These must match for compatibility.
 This will cause runtime errors: 'No SWIG wrapped library loaded'
  
 swig v4.4.x is not compatible with pivy built with swig v4.3.x and below
  
 FIX: Install a SWIG version that uses runtime ${PIVY_RUNTIME_VERSION}, ie. swig v4.4.x
 or rebuild Pivy with your current SWIG ${SWIG_VERSION}.
--------------------------------------------------------"
            )
        else()
            message(STATUS "SWIG/Pivy runtime compatibility: PASSED (version ${SWIG_RUNTIME_VERSION})")
            message(STATUS "  SWIG: ${SWIG_VERSION}")
        endif()
    else()
        if(NOT SWIG_RUNTIME_VERSION)
            message(WARNING "Could not determine SWIG runtime version")
        endif()
        if(NOT PIVY_RUNTIME_VERSION)
            message(WARNING "Could not determine Pivy runtime version")
        endif()
        message(WARNING "Proceeding without SWIG/Pivy compatibility check.")
    endif()
endif()

endmacro()
