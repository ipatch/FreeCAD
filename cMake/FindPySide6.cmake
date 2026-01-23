# The Qt for Python project officially recommends using pip to install PySide,
# so we expect to find PySide in the site-packages directory.
# The library will be called "PySide6.abi3.*", and there will
# be an "include" directory inside the site-packages/PySide6.
# Over time some distros may provide custom versions, so we also support
# using a more normal cMake find_package() call

include(FindPackageHandleStandardArgs)

find_package(PySide6 CONFIG QUIET)

if(NOT PySide6_FOUND)
    find_pip_package(PySide6)
endif()

if(PySide6_FOUND)
    # Verify the PySide6 Python imports matches the Qt version CMake found
    if(Python3_EXECUTABLE AND Qt6_VERSION)
        execute_process(
            COMMAND "${Python3_EXECUTABLE}" "-c"
            "from PySide6.QtCore import qVersion; print(qVersion())"
            RESULT_VARIABLE _PYSIDE6_QT_RESULT
            OUTPUT_VARIABLE _PYSIDE6_QT_VERSION
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(_PYSIDE6_QT_RESULT EQUAL 0)
            string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" _qt6_major_minor "${Qt6_VERSION}")
            string(REGEX MATCH "^([0-9]+)\\.([0-9]+)" _pyside6_qt_major_minor "${_PYSIDE6_QT_VERSION}")

            if(NOT _qt6_major_minor STREQUAL _pyside6_qt_major_minor)
                message(FATAL_ERROR
                "Qt/PySide6 version mismatch!\n"
                "  CMake found Qt: ${Qt6_VERSION}\n"
                "  PySide6 (Python) built against Qt: ${_PYSIDE6_QT_VERSION}\n"
                "Major.minor versions must match to avoid runtime errors.\n"
                "Ensure CMAKE_PREFIX_PATH points to matching Qt and PySide6 installations."
                )
            endif()

            message(STATUS "PySide6 Qt version check passed (${_PYSIDE6_QT_VERSION})")
        endif()
    endif()

    if(NOT PySide6_INCLUDE_DIRS AND TARGET PySide6::pyside6)
        get_property(PySide6_INCLUDE_DIRS TARGET PySide6::pyside6 PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    endif()

    # Also provide the old-style variables so we don't have to update everything yet
    set(PYSIDE_INCLUDE_DIR ${PySide6_INCLUDE_DIRS})
    set(PYSIDE_LIBRARY ${PySide6_LIBRARIES})
    set(PYSIDE_FOUND TRUE)
    set(PYSIDE_MAJOR_VERSION 6)
endif()
