cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "pdf_view")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "pdf_view_plugin")

add_library(${PLUGIN_NAME} SHARED
  "evince/shell/ev-window.c"
  "pdf_view_plugin.cc"
  "pdf_view_platform_view.cc"
  "pdf_view_view_factory.cc"
  
)
apply_standard_settings(${PLUGIN_NAME})

pkg_check_modules(Poppler REQUIRED IMPORTED_TARGET poppler-glib)
pkg_check_modules(evince_doc REQUIRED IMPORTED_TARGET evince-document-3.0)
pkg_check_modules(evince_view REQUIRED IMPORTED_TARGET evince-view-3.0)

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK PkgConfig::Poppler PkgConfig::evince_doc PkgConfig::evince_view)

# List of absolute paths to libraries that should be bundled with the plugin
set(pdf_view_bundled_libraries
  ""
  PARENT_SCOPE
)
