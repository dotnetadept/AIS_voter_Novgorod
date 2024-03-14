# Install script for directory: /home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/linux

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/")
  
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard"
         RPATH "$ORIGIN/lib")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle" TYPE EXECUTABLE FILES "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/intermediates_do_not_run/storeboard")
  if(EXISTS "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard"
         OLD_RPATH "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/flutter_webrtc:/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/media_kit_libs_linux:/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/screen_retriever:/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/window_manager:/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/window_size:/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/linux/flutter/ephemeral:"
         NEW_RPATH "$ORIGIN/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/snap/flutter/current/usr/bin/strip" "$ENV{DESTDIR}/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/storeboard")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/data/icudtl.dat")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/data" TYPE FILE FILES "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/linux/flutter/ephemeral/icudtl.dat")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libflutter_linux_gtk.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/linux/flutter/ephemeral/libflutter_linux_gtk.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libflutter_webrtc_plugin.so;/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libwebrtc.so;/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libmedia_kit_libs_linux_plugin.so;/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libscreen_retriever_plugin.so;/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libwindow_manager_plugin.so;/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libwindow_size_plugin.so;/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib/libmedia_kit_native_event_loop.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/lib" TYPE FILE FILES
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/flutter_webrtc/libflutter_webrtc_plugin.so"
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/linux/flutter/ephemeral/.plugin_symlinks/flutter_webrtc/linux/../third_party/libwebrtc/lib/linux-x64/libwebrtc.so"
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/media_kit_libs_linux/libmedia_kit_libs_linux_plugin.so"
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/screen_retriever/libscreen_retriever_plugin.so"
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/window_manager/libwindow_manager_plugin.so"
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/window_size/libwindow_size_plugin.so"
    "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/media_kit_native_event_loop/shared/libmedia_kit_native_event_loop.so"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/data/flutter_assets")
  
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/data/flutter_assets")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/bundle/data" TYPE DIRECTORY FILES "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build//flutter_assets")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/flutter/cmake_install.cmake")
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/flutter_webrtc/cmake_install.cmake")
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/media_kit_libs_linux/cmake_install.cmake")
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/screen_retriever/cmake_install.cmake")
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/window_manager/cmake_install.cmake")
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/window_size/cmake_install.cmake")
  include("/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/plugins/media_kit_native_event_loop/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/user/Desktop/AIS_voter_Yaroslavl/AIS_voting/src/clients/yar_storeboard/build/linux/x64/debug/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
