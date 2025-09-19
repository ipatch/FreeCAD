
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

if(PYTHON_LIBRARY MATCHES "(.*Python\\.framework).*")
    #framework
    set(PYTHON_DIR ${CMAKE_MATCH_1}/Versions/${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/lib/${PYTHON_DIR_BASENAME})
else()
    #unix
    get_filename_component(PYTHON_DIR ${PYTHON_LIBRARY} PATH)
    set(PYTHON_DIR ${PYTHON_DIR}/${PYTHON_DIR_BASENAME})
endif()

message(" PYTHON_DIR is ${PYTHON_DIR} --------------------ipatch--")
message(" PYTHON_DIR_BASENAME is ${PYTHON_DIR_BASENAME} --------------------ipatch--")

install(CODE "execute_process(COMMAND
${CMAKE_COMMAND} -E copy_directory ${PYTHON_DIR} ${CMAKE_INSTALL_LIBDIR}/${PYTHON_DIR_BASENAME}
)")

if(HOMEBREW_PREFIX)

  set(MACOS_BUNDLE_CONTENTS_DIR "Contents")
  set(MACOS_BUNDLE_RESOURCES_DIR "${MACOS_BUNDLE_CONTENTS_DIR}/Resources")
  set(MACOS_BUNDLE_EXECUTABLES_DIR "${MACOS_BUNDLE_CONTENTS_DIR}/MacOS")
  set(MACOS_BUNDLE_FRAMEWORKS_DIR "${MACOS_BUNDLE_CONTENTS_DIR}/Frameworks")
  set(MACOS_BUNDLE_LIB_DIR "${MACOS_BUNDLE_CONTENTS_DIR}/lib")

  message(" PYTHON_DIR is ${PYTHON_DIR} --------------------ipatch--")

  # NOTE: ipatch, original line
  # file(GLOB HOMEBREW_PTH_FILES "${PYTHON_DIR}/site-packages/homebrew*.pth")
  file(GLOB HOMEBREW_PTH_FILES "${PYTHON_DIR}/site-packages/freecad*.pth")

  message(STATUS "HOMEBREW_PTH_FILES are ${HOMEBREW_PTH_FILES} -----------------------ipatch--")

  # process each .pth file found
  foreach(PTH_FILE ${HOMEBREW_PTH_FILES})
    # orig
    # file(READ ${PTH_FILE} ADDITIONAL_DIR)
    # read the .pth file into a single string
    file(READ ${PTH_FILE} FILE_CONTENT)

    # split the content by newlines into a list of lines
    string(REPLACE "\n" ";" LINES "${FILE_CONTENT}")

    # This variable will accumulate the new content for the rewritten .pth file.
    set(NEW_PTH_CONTENT "")

    # Process each line from the .pth file.
    foreach(LINE ${LINES_LIST})
      # Remove leading/trailing whitespace.
      string(STRIP "${LINE}" CLEAN_LINE)

      # skip empty lines or comments.
      if(CLEAN_LINE MATCHES "^#|^$")
        continue()
      endif()

      # Extract the path string from the `site.addsitedir()` function call.
      string(REGEX MATCH "'.*'" PATH_STRING "${CLEAN_LINE}")

      if(PATH_STRING)
        # Remove the single quotes to get a clean path.
        string(REPLACE "'" "" ADDITIONAL_DIR "${PATH_STRING}")

        # Check if the path matches the Homebrew Cellar format.
        if(ADDITIONAL_DIR MATCHES "${HOMEBREW_PREFIX}/Cellar")

          # We want to extract the part of the path starting with the package name.
          # e.g., "coin3d@4.0.3_py312/..."
          # string(REGEX MATCH "[^/]+/.+" RELATIVE_TAIL "${ADDITIONAL_DIR}")
          string(REGEX MATCH "Cellar/[^/]+/[^/]+/.+" RELATIVE_PART "${ADDITIONAL_DIR}")

          # We need to clean this up and make it a valid path inside the bundle.
          string(REPLACE "Cellar/" "" RELATIVE_INSTALL_PATH "${RELATIVE_PART}")
          message(STATUS "RELATIVE_INSTALL_PATH is ${RELATIVE_INSTALL_PATH} -------------ipatch--")

          # Construct the full, absolute destination path for the `install` command.
          set(ABSOLUTE_INSTALL_DESTINATION "${CMAKE_INSTALL_PREFIX}/${MACOS_BUNDLE_LIB_DIR}/python3.12/${RELATIVE_INSTALL_PATH}")

          message(STATUS "ABSOLUTE_INSTALL_DESTINATION is ${ABSOLUTE_INSTALL_DESTINATION} -------------ipatch--")

          # string(FIND "${ADDITIONAL_DIR}" "${HOMEBREW_PREFIX}/Cellar" POSITION)
          # string(LENGTH "${ADDITIONAL_DIR}" DIR_LENGTH)
          # string(SUBSTRING "${ADDITIONAL_DIR}" ${POSITION} ${DIR_LENGTH}-${POSITION} DIR_TAIL)
          # string(REGEX MATCHALL "^([/A-Za-z0-9_.@-]+)" CLEAR_TAIL ${DIR_TAIL})
          # string(REGEX REPLACE "^${HOMEBREW_PREFIX}/Cellar/([A-Za-z0-9_]+).*$" "\\1" LIB_NAME ${CLEAR_TAIL})
          # string(REGEX REPLACE ".*libexec(.*)/site-packages" "libexec/${LIB_NAME}\\1" NEW_SITE_DIR ${CLEAR_TAIL})

          # install(DIRECTORY ${CLEAR_TAIL} DESTINATION ${CMAKE_INSTALL_PREFIX}/${NEW_SITE_DIR})
          # Now, perform the installation of the directory.
          # install(DIRECTORY "${ADDITIONAL_DIR}" DESTINATION "${DEST_SITE_DIR}")
          # install(DIRECTORY "${ADDITIONAL_DIR}" DESTINATION "${DESTINATION_PATH}")
          # Now, perform the installation of the directory.
          install(DIRECTORY "${ADDITIONAL_DIR}" DESTINATION "${ABSOLUTE_INSTALL_DESTINATION}")

          # Print a status message for clarity.
          message(STATUS "Installed directory: ${ADDITIONAL_DIR}")
          message(STATUS "  Destination: ${ABSOLUTE_INSTALL_DESTINATION}")

          # Get the path that will be written to the new .pth file.
          # This path must be relative to the `site-packages` directory.
          string(REPLACE "/site-packages" "" RELATIVE_PTH_PATH "${RELATIVE_INSTALL_PATH}")
          string(APPEND NEW_PTH_CONTENT "../../../${RELATIVE_PTH_PATH}/site-packages\n")
        endif()
      endif()
    endforeach(LINE)

    # This block handles updating the paths of the .pth files *after* the directories have been processed.
    # This part should be outside the inner loop but inside the outer loop.
    get_filename_component(PTH_FILENAME "${PTH_FILE}" NAME)

    # Define the full path to the .pth file that will be created inside the bundle.
    set(TARGET_PTH_PATH "${CMAKE_INSTALL_PREFIX}/${MACOS_BUNDLE_LIB_DIR}/python3.12/site-packages/${PTH_FILENAME}")

    # Define the content that will be written to the .pth file.
    # set(PTH_CONTENT "../../../${NEW_SITE_DIR}/site-packages")

    # Print a status message to show the paths involved.
    message(STATUS "Rewriting .pth file: ${PTH_FILENAME}")
    message(STATUS "  Destination: ${TARGET_PTH_PATH}")
    message(STATUS "  New content: ${PTH_CONTENT}")

     install(CODE
      "file(WRITE \"${TARGET_PTH_PATH}\" \"${NEW_PTH_CONTENT}\")"
    )

    # install(CODE
    #   "file(WRITE
    #   ${CMAKE_INSTALL_LIBDIR}/${PYTHON_DIR_BASENAME}/site-packages/${PTH_FILENAME}
    #   \"../../../${NEW_SITE_DIR}/site-packages\"
    #   )"
    # )
  endforeach(PTH_FILE)
endif()

set(QT_PLUGINS_DIR "${Qt5Core_DIR}/../../../plugins")
execute_process(COMMAND "xcode-select" "--print-path"
  OUTPUT_VARIABLE XCODE_PATH
  ERROR_QUIET
)
string(STRIP ${XCODE_PATH} XCODE_PATH)

set(XCTEST_PATH "${XCODE_PATH}/Platforms/MacOSX.platform/Developer/Library/Frameworks/XCTest.framework/Versions/Current")

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
    ${APP_PATH}
    ${HOMEBREW_PREFIX}${MACPORTS_PREFIX}/lib
    ${HOMEBREW_PREFIX}/opt
    ${HOMEBREW_PREFIX}/opt/*/lib
    ${Qt5Core_DIR}/../../..
    ${XCTEST_PATH}
    )"
  )

endif(FREECAD_CREATE_MAC_APP)
