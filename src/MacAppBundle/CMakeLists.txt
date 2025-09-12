
#
# Build and install QuickLook for FCStd files (org.freecad.fcstd)
# This is used by Homebrew and Conda/Mamba scripts alike.
#
if(FREECAD_CREATE_MAC_APP OR (APPLE AND BUILD_WITH_CONDA))
    add_subdirectory(QuickLook)
    install(
        DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/QuickLook/QuicklookFCStd.qlgenerator"
        DESTINATION "${CMAKE_INSTALL_PREFIX}/Library/QuickLook"
    )
    install(
        PROGRAMS "${PROJECT_BINARY_DIR}/src/MacAppBundle/QuickLook/QuicklookFCStd.framework/Versions/A/QuicklookFCStd"
        DESTINATION "${CMAKE_INSTALL_PREFIX}/Library/QuickLook/QuicklookFCStd.qlgenerator/Contents/MacOS/"
    )
endif()


#
# Build a Bundle in Homebrew.
# This is ignored by Conda/Mamba build scripts.
#
if(FREECAD_CREATE_MAC_APP)

set(PYTHON_DIR_BASENAME python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})

message(STATUS "--------------------------------------------------------------ipatch--")
message(STATUS "PYTHON_VERSION_MAJOR = ${PYTHON_VERSION_MAJOR} , PYTHON_VERSION_MINOR = ${PYTHON_VERSION_MINOR}")

execute_process(
  COMMAND "${Python3_EXECUTABLE}" -c
          "import sysconfig; print(sysconfig.get_paths()['purelib'])"
  OUTPUT_VARIABLE PYTHON_SITE_PACKAGES
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "ipatch: site-packages = ${PYTHON_SITE_PACKAGES}")

if(PYTHON_LIBRARY MATCHES "(.*Python\\.framework).*")
  #framework
  set(PYTHON_DIR "${PYTHON_SITE_PACKAGES}")
  message(STATUS "--------------------------------------------------------------ipatch--")
  message(STATUS "ipatch: PYTHON_DIR = ${PYTHON_DIR}")
else()
  #unix
  get_filename_component(PYTHON_DIR ${PYTHON_LIBRARY} PATH)
  set(PYTHON_DIR ${PYTHON_DIR}/${PYTHON_DIR_BASENAME})
endif()

install(CODE "execute_process(COMMAND
${CMAKE_COMMAND} -E copy_directory ${PYTHON_DIR} ${CMAKE_INSTALL_LIBDIR}/${PYTHON_DIR_BASENAME}
)")

if(HOMEBREW_PREFIX)
    #Homebrew installs python dependencies to a site dir in prefix/libexec
    #and installs a .pth file containing its path to the HOMEBREW_PREFIX site dir.
    message(STATUS "--------------------------------------------------------------ipatch--")

    file(GLOB HOMEBREW_PTH_FILES "${PYTHON_DIR}/freecad-py-modules.pth")

    message(STATUS "ipatch: HOMEBREW_PTH_FILES = ${HOMEBREW_PTH_FILES}")
    message(STATUS "--------------------------------------------------------------ipatch--")

    message(STATUS "ipatch: PYTHON_DIR = ${PYTHON_DIR}")
    message(STATUS "--------------------------------------------------------------ipatch--")

    foreach(PTH_FILE ${HOMEBREW_PTH_FILES})
      file(READ ${PTH_FILE} PTH_CONTENT)

      # Split file content into a list of lines
      string(REGEX REPLACE "\r?\n" ";" PTH_LINES "${PTH_CONTENT}")

      # set(REWRITTEN_LINES "")
      # Start with a single import site
      set(REWRITTEN_LINES "import site")
      message(STATUS "--------------------------------------------------------------ipatch--")
      message(STATUS "REWRITTEN_LINES = ${REWRITTEN_LINES}")

      foreach(LINE ${PTH_LINES})
        string(STRIP "${LINE}" LINE)
        # if(LINE STREQUAL "")
        if(LINE STREQUAL "" OR LINE STREQUAL "import site")
          continue()
        endif()

        # # Case 1: line is literally "import site"
        # if(LINE STREQUAL "import site")
        #     list(APPEND REWRITTEN_LINES "import site")
        #     continue()
        # endif()

        # Case 2: line starts with "import site; site.addsitedir('...')"
        # Extract path from site.addsitedir or bare path
        string(REGEX MATCH "'(/usr/local/Cellar/[^']+)'" MATCHED_PATH "${LINE}")
        if(MATCHED_PATH STREQUAL "")
            string(REGEX MATCH "^(/usr/local/Cellar/[^;]+)" MATCHED_PATH "${LINE}")
        endif()

        if(MATCHED_PATH STREQUAL "")
          message(WARNING "Could not extract path from line: ${LINE}")
          continue()
        endif()

        # Remove quotes if present
        string(REGEX REPLACE "'" "" ORIGINAL_DIR "${MATCHED_PATH}")

        # Extract Homebrew keg name
        string(REGEX REPLACE "^${HOMEBREW_PREFIX}/Cellar/([A-Za-z0-9_.@-]+)/.*" "\\1" LIB_NAME "${ORIGINAL_DIR}")

        # Map to bundle-relative path
        set(BUNDLE_DIR "libexec/${LIB_NAME}/lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages")

        message(STATUS "ipatch: ORIGINAL_DIR = ${ORIGINAL_DIR}")
        message(STATUS "ipatch: BUNDLE_DIR = ${BUNDLE_DIR}")

        # Copy the directory into the bundle
        install(DIRECTORY "${ORIGINAL_DIR}" DESTINATION "${CMAKE_INSTALL_PREFIX}/${BUNDLE_DIR}")

        list(APPEND REWRITTEN_LINES "site.addsitedir('../../../${BUNDLE_DIR}')")
      endforeach()

      # Write the rewritten .pth file into the bundle
      # get_filename_component(PTH_FILENAME ${PTH_FILE} NAME)
      set(REWRITTEN_CONTENT "")
      foreach(L ${REWRITTEN_LINES})
        string(STRIP "${L}" L)
        set(REWRITTEN_CONTENT "${REWRITTEN_CONTENT}${L}\n")
      endforeach()

      message(STATUS "--------------------------------------------------------------ipatch--")
      message(STATUS "--ipatch REWRITTEN_CONTENT = ${REWRITTEN_CONTENT}")

      message(STATUS "--------------------------------------------------------------ipatch--")
      message(STATUS "ipatch: PTH_FILENAME = ${PTH_FILENAME}")
      message(STATUS "ipatch: PTH_PATH     = ${PTH_PATH}")
      message(STATUS "--------------------------------------------------------------ipatch--")
      
      # Path to the generated .pth file in the build tree
      set(PTH_PATH "${CMAKE_CURRENT_BINARY_DIR}/${PTH_FILENAME}")

      # Write the rewritten content into the file at build time
      file(WRITE "${PTH_PATH}" "${REWRITTEN_CONTENT}")

      # Install the generated .pth file into the app bundle site-packages dir
      install(FILES "${PTH_PATH}"
        DESTINATION Resources/lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages
      )
      # install(CODE
      #   "file(MAKE_DIRECTORY
      #   ${CMAKE_INSTALL_PREFIX}/Resources/lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages
      # )
      # file(WRITE
      #   ${CMAKE_INSTALL_PREFIX}/Resources/lib/python${Python3_VERSION_MAJOR}.${Python3_VERSION_MINOR}/site-packages/${PTH_FILENAME}
      #   \"${REWRITTEN_CONTENT}\"
      #   )"
      # )
    endforeach()
endif()

# TODO: ipatch handle multiple qt versions, ie. qt5 and qt6
set(QT_PLUGINS_DIR "${Qt5Core_DIR}/../../../plugins")

execute_process(COMMAND "xcode-select" "--print-path"
    OUTPUT_VARIABLE XCODE_PATH
    ERROR_QUIET
    )
string(STRIP ${XCODE_PATH} XCODE_PATH)

set(XCTEST_PATH "${XCODE_PATH}/Platforms/MacOSX.platform/Developer/Library/Frameworks/XCTest.framework/Versions/Current")

# TODO: ipatch handle multiple qt versions, ie. qt5 and qt6
# add qt assistant to bundle
install(PROGRAMS "${Qt5Core_DIR}/../../../libexec/Assistant.app/Contents/MacOS/Assistant" DESTINATION ${CMAKE_INSTALL_PREFIX}/MacOS)

# Ensure the actual plugin files are installed instead of symlinks.
file(GLOB _subdirs RELATIVE "${QT_PLUGINS_DIR}" "${QT_PLUGINS_DIR}/*")

foreach(_subdir ${_subdirs})
    if(IS_DIRECTORY "${QT_PLUGINS_DIR}/${_subdir}")
        set(_resolved_files "")
        file(GLOB _plugin_files RELATIVE "${QT_PLUGINS_DIR}/${_subdir}" "${QT_PLUGINS_DIR}/${_subdir}/*")

        foreach(_plugin_file ${_plugin_files})
            get_filename_component(_resolved_file "${QT_PLUGINS_DIR}/${_subdir}/${_plugin_file}" REALPATH)
            list(APPEND _resolved_files ${_resolved_file})
        endforeach()

        install(FILES ${_resolved_files} DESTINATION "${CMAKE_INSTALL_LIBDIR}/qtplugins/${_subdir}")
    endif()
endforeach()

#files installed by homebrew do not have write permission for regular user
install(CODE "execute_process(COMMAND chmod -R a+w ${CMAKE_INSTALL_LIBDIR})")

get_filename_component(APP_PATH ${CMAKE_INSTALL_PREFIX} PATH)

install(CODE
    "message(STATUS \"Making bundle relocatable...\")
    # The top-level CMakeLists.txt should prevent multiple package manager
    # prefixes from being set, so the lib path will resolve correctly...
    execute_process(
        COMMAND python3
        ${CMAKE_SOURCE_DIR}/src/Tools/MakeMacBundleRelocatable.py
        ${APP_PATH} ${HOMEBREW_PREFIX}/opt ${Qt5Core_DIR}/../../.. ${XCTEST_PATH}
    )"
)

endif(FREECAD_CREATE_MAC_APP)
