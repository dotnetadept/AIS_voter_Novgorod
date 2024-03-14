macro(add_sample)
    if(POLICY CMP0015)
        cmake_policy(SET CMP0015 OLD)
    endif(POLICY CMP0015)

	include_directories("../common")
	include_directories("../../include")

	if(MSVC)
		link_directories(../../../../lib/Win32)
	endif()

	add_definitions("-Wall")
    add_definitions("-DPKCS_LIB_PATH=\"${PKCS_LIB_PATH}\"")
	if (MSVC)
        add_definitions("/wd4514 /wd4710 /wd4820 /wd4350 /wd4668 /wd4711 /wd4365 ")
		add_definitions("-DCK_Win32 -D_CRT_SECURE_NO_WARNINGS")
		if (${CMAKE_GENERATOR} MATCHES Win64)
			add_definitions("-DBUILD_WIN64")
		else()
			add_definitions("-DBUILD_WIN32")
		endif()
	else ()
		add_definitions("-DCK_GENERIC -Wno-write-strings -fpermissive")
		if(APPLE)
			add_definitions("-DBUILD_OSX")
		else()
			add_definitions("-DBUILD_NIX -DUNIX")
		endif()
	endif()

	message (${CMAKE_CURRENT_SOURCE_DIR})
	file (GLOB SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

	add_executable(
		${PROJECT}
		${SOURCES}
		"../common/P11Loader.cpp"
		"../common/Utils.cpp"
		${AUXILIARY_FILES}
	)
    if(WIN32)
        target_link_libraries(${PROJECT} "Ws2_32.lib")
    endif()
    if(UNIX AND NOT APPLE)
        target_link_libraries(${PROJECT} dl)
    endif()
    set_target_properties(${PROJECT} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${JC_OUTPUT_DIR}")
endmacro()
