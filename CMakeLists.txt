cmake_minimum_required(VERSION 3.23.0)

project(StarterTemplate VERSION 0.1.0 LANGUAGES C CXX)

add_executable(StarterTemplate src/main.cpp)
if(DEFINED BUILD_AS_ARM64X)
    set(ARM64X_TARGETS StarterTemplate)
    include("cmake/arm64x.cmake")
endif()

include(CTest)
enable_testing()

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)
