# The following are set after configuration is done: WITH_CUDA
# ONEFLOW_INCLUDE_DIR ONEFLOW_ROOT_DIR

include(python)

execute_process(
  COMMAND ${Python_EXECUTABLE} -c
          "import oneflow.sysconfig; print(oneflow.sysconfig.with_cuda())"
  OUTPUT_VARIABLE OneFlow_WITH_CUDA
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if("${OneFlow_WITH_CUDA}" STREQUAL "True")
  message(STATUS "Build WITH_CUDA=ON")
  set(WITH_CUDA ON)
  add_definitions(-DWITH_CUDA)
else()
  message(STATUS "Build WITH_CUDA=OFF")
  set(WITH_CUDA OFF)
endif()

execute_process(
  COMMAND ${Python_EXECUTABLE} -c
          "import oneflow.sysconfig; print(oneflow.sysconfig.get_include())"
  OUTPUT_VARIABLE ONEFLOW_INCLUDE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(
  COMMAND ${Python_EXECUTABLE} -c
          "import oneflow.sysconfig; print(oneflow.sysconfig.get_lib())"
  OUTPUT_VARIABLE ONEFLOW_ROOT_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(
  COMMAND
    ${Python_EXECUTABLE} -c
    "import oneflow.sysconfig; \
                 print(oneflow.sysconfig.get_liboneflow_link_flags()[0].replace('-L', ''))"
  OUTPUT_VARIABLE OneFlow_LIBRARIE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(
  COMMAND
    ${Python_EXECUTABLE} -c
    "import oneflow.sysconfig; \
                 print(oneflow.sysconfig.get_liboneflow_link_flags()[1].replace('-l:', ''))"
  OUTPUT_VARIABLE OneFlow_LIBRARIES
  OUTPUT_STRIP_TRAILING_WHITESPACE)

find_library(
  ONEFLOW_LIBRARIES
  NAMES ${OneFlow_LIBRARIES}
  PATHS ${OneFlow_LIBRARIE_DIR})

if(NOT ONEFLOW_LIBRARIES)
  execute_process(
    COMMAND
      ${Python_EXECUTABLE} -c
      "import os; import glob; \
               print(os.path.basename(glob.glob('/home/chenhoujiang/.local/lib/python3.8/site-packages/oneflow.libs/*oneflow-*')[0]));"
    OUTPUT_VARIABLE OneFlow_LIBRARIES
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  find_library(
    ONEFLOW_LIBRARIES
    NAMES ${OneFlow_LIBRARIES}
    PATHS ${OneFlow_LIBRARIE_DIR})

  if(NOT ONEFLOW_LIBRARIES)
    message(
      FATAL_ERROR
        "can not find oneflow libraries in directory: ${OneFlow_LIBRARIE_DIR}")
  endif()
endif()

message(STATUS "ONEFLOW_LIBRARIES: ${ONEFLOW_LIBRARIES}")

add_library(oneflow UNKNOWN IMPORTED)
set_property(TARGET oneflow PROPERTY IMPORTED_LOCATION ${ONEFLOW_LIBRARIES})
