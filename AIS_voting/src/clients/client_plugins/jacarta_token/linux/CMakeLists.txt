cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "jacarta_token")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

#add_library(jcPKCS11 SHARED IMPORTED)
#set_property(TARGET jcPKCS11 PROPERTY IMPORTED_LOCATION "/usr/lib/libjcPKCS11-2.so")
add_library(${PLUGIN_NAME} SHARED
  "${PLUGIN_NAME}.cc"
  "common/P11Loader.cpp"
)
# #Compilation settings that should be applied to most targets.
# function(APPLY_STANDARD_SETTINGS TARGET)
#   target_compile_features(${TARGET} PUBLIC cxx_std_14)
#   target_compile_options(${TARGET} PRIVATE -Wall -DBUILD_NIX -Wl -lpthread -ldl -v)
#   target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
#   target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
# endfunction()

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  #"${CMAKE_CURRENT_SOURCE_DIR}/common"
  )
target_link_libraries(${PLUGIN_NAME} PRIVATE dl)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
#target_link_libraries(${PLUGIN_NAME} PRIVATE jcPKCS11)

# List of absolute paths to libraries that should be bundled with the plugin
set(jacarta_token_bundled_libraries
  ""
  PARENT_SCOPE
)
