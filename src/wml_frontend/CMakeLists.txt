SET (username "unknown")

EXECUTE_PROCESS(COMMAND "whoami"
    OUTPUT_VARIABLE username
)

CHOMP(username)

EXECUTE_PROCESS(COMMAND "${PERL_EXECUTABLE}"
    "-MPOSIX" "-e" "print strftime('%Y-%m-%d', localtime())"
    OUTPUT_VARIABLE date
)

MACRO(set_vars)
    SET (destbase "${cmd}.pl")
    SET (dest "${CMAKE_CURRENT_BINARY_DIR}/${destbase}")
    SET (srcbase "${cmd}.src")
    SET (src "${CMAKE_CURRENT_SOURCE_DIR}/${srcbase}")
    SET (mannamebase "${cmd}")
    SET (manname "${CMAKE_CURRENT_BINARY_DIR}/${mannamebase}")
ENDMACRO(set_vars)

SET (pod_dests )

FOREACH (cmd wmk wml wmb wmd wmu wml-params-conf)
    set_vars()
    # MESSAGE( FATAL_ERROR "WML_LIB_DIR = ${WML_LIB_DIR}")
    PREPROCESS_PATH_PERL_WITH_FULL_NAMES("preprocess_perl_frontend_${cmd}" "${src}" "${dest}")
    INSTALL (
        PROGRAMS "${dest}"
        DESTINATION "bin"
        RENAME "${cmd}"
        )
    INST_POD2MAN("pod_dests" "${srcbase}" "${mannamebase}" "1")
ENDFOREACH(cmd)

FOREACH(cmd wmd_missing)
    set_vars()
    INST_POD2MAN("pod_dests" "${srcbase}" "${mannamebase}" "1")
ENDFOREACH(cmd)

ADD_CUSTOM_TARGET(
    "frontend_pods" ALL
    DEPENDS ${pod_dests}
)

INSTALL_DATA ("wmd.txt")
