# Sets the following variables:
# OPENFST_FOUND
# OPENFST_DIR

if ("${OPENFST_ROOT}" STREQUAL "")
  if (NOT "$ENV{OPENFST_ROOT}" STREQUAL "")
    set (OPENFST_ROOT $ENV{OPENFST_ROOT})
  endif()
endif()

find_path(OPENFST_INCLUDE_DIR fst/fst.h PATHS ${OPENFST_ROOT}/include/ )
find_library(OPENFST_LIB fst PATHS ${OPENFST_ROOT}/lib)

if(OPENFST_INCLUDE_DIR)
  set(OPENFST_FOUND 1)
  string(REGEX REPLACE "src/include/fst$" "" OPENFST_DIR ${OPENFST_INCLUDE_DIR})
  #set(OPENFST_INCLUDE_DIR "${OPENFST_INCLUDE_DIR}/..")
  message(STATUS "OpenFst include: ${OPENFST_INCLUDE_DIR}")
  message(STATUS "OpenFst lib:     ${OPENFST_LIB}")
else()
  message("No OpenFst found")
ENDIF()