macro(SetupBoost)
# -------------------------------- Boost --------------------------------

    # Set the path to your Boost installation
    set(BOOST_ROOT "~/homebrew/opt/boost-python3.11")

    set(_boost_TEST_VERSIONS ${Boost_ADDITIONAL_VERSIONS})

    set (BOOST_COMPONENTS filesystem program_options regex system thread date_time)
    find_package(Boost 1.83.0 REQUIRED COMPONENTS ${BOOST_COMPONENTS}
        HINTS ${BOOST_ROOT})

    if(UNIX AND NOT APPLE)
        # Boost.Thread 1.67+ headers reference pthread_condattr_*
        list(APPEND Boost_LIBRARIES pthread)
    endif()

    if(NOT Boost_FOUND)
        set (NO_BOOST_COMPONENTS)
        foreach (comp ${BOOST_COMPONENTS})
            string(TOUPPER ${comp} uppercomp)
            if (NOT Boost_${uppercomp}_FOUND)
                list(APPEND NO_BOOST_COMPONENTS ${comp})
            endif()
        endforeach()
        message(FATAL_ERROR "=============================================\n"
                            "Required components:\n"
                            " ${BOOST_COMPONENTS}\n"
                            "Not found, install the components:\n"
                            " ${NO_BOOST_COMPONENTS}\n"
                            "=============================================\n")
    endif(NOT Boost_FOUND)

endmacro(SetupBoost)

