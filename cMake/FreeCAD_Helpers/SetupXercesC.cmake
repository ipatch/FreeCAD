macro(SetupXercesC)
  # -------------------------------- XercesC --------------------------------

  find_package(XercesC REQUIRED)

  if(HOMEBREW_PREFIX)
    # NOTE: ipatch, possible bug / feature fix related to cmake
    # https://issues.apache.org/jira/browse/XERCESC-2246?jql=project%20%3D%20XERCESC
    # set xcercesc include directory manually
    set(XercesC_INCLUDE_DIR ${HOMEBREW_PREFIX}/opt/xerces-c/include)
    include_directories(${XercesC_INCLUDE_DIR})

    # Display information about Xerces-C++ found by CMake
    message(STATUS "Xerces-C++ include directory: ${XercesC_INCLUDE_DIR}")
    message(STATUS "Xerces-C++ library: ${XercesC_LIBRARY}")
  endif()
  if(NOT XercesC_FOUND)
    message(FATAL_ERROR "==================\n"
      "XercesC not found.\n"
      "==================\n")
  endif(NOT XercesC_FOUND)

endmacro(SetupXercesC)
