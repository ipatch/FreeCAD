macro(SetupPython)
# -------------------------------- Python --------------------------------

  # if(NOT DEFINED PYTHON_EXECUTABLE OR NOT DEFINED PYTHON_INCLUDE_DIRS OR NOT DEFINED PYTHON_LIBRARY)
    if(DEFINED HOMEBREW_PREFIX)
      set(PYTHON_EXECUTABLE "${HOMEBREW_PREFIX}/opt/python@3.10/bin/python3.10" CACHE STRING "Python executable")
      set(PYTHON_INCLUDE_DIRS "${HOMEBREW_PREFIX}/opt/python@3.10/Frameworks/Python.framework/Versions/3.10/include" CACHE STRING "Python include dirs")
      set(PYTHON_LIBRARY "${HOMEBREW_PREFIX}/opt/python@3.10/Frameworks/Python.framework/Versions/3.10/lib/libpython3.10.dylib" CACHE STRING "Python library")

      message("======================================== ipatch =")
      message("PYTHON_EXECUTABLE: ${PYTHON_EXECUTABLE}")
      message("PYTHON_INCLUDE_DIRS: ${PYTHON_INCLUDE_DIRS}")
      message("PYTHON_LIBRARY: ${PYTHON_LIBRARY}")
      message("======================================== ipatch =")

    else()
      # Existing find_package logic...
      find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

      # For backwards compatibility with old CMake scripts
      set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
      set(PYTHON_LIBRARIES ${Python3_LIBRARIES})
      set(PYTHON_INCLUDE_DIRS ${Python3_INCLUDE_DIRS})
      set(PYTHON_LIBRARY_DIRS ${Python3_LIBRARY_DIRS})
      set(PYTHON_VERSION_STRING ${Python3_VERSION})
      set(PYTHON_VERSION_MAJOR ${Python3_VERSION_MAJOR})
      set(PYTHON_VERSION_MINOR ${Python3_VERSION_MINOR})
      set(PYTHON_VERSION_PATCH ${Python3_VERSION_PATCH})
      set(PYTHONINTERP_FOUND ${Python3_Interpreter_FOUND})

      if (${PYTHON_VERSION_STRING} VERSION_LESS "3.8")
        message(FATAL_ERROR "To build FreeCAD you need at least Python 3.8\n")
      endif()
    endif()
  # endif()
endmacro(SetupPython)

