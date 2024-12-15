
function(get_arm64_repro_dir returnValue)
    file(RELATIVE_PATH relativeDir "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_SOURCE_DIR}")
    cmake_path(APPEND joinedPath "${CMAKE_SOURCE_DIR}/out/build" ${relativeDir})
    set(${returnValue} "${joinedPath}" PARENT_SCOPE)
endfunction()

function(set_arm64_dependencies n)
    get_arm64_repro_dir(arm64ReproDir)
    cmake_path(APPEND REPRO_FILE "${arm64ReproDir}" "${n}.rsp")
    file(STRINGS "${REPRO_FILE}" ARM64_OBJS REGEX "obj\"$")
    file(STRINGS "${REPRO_FILE}" ARM64_DEF REGEX  "def\"$")
    file(STRINGS "${REPRO_FILE}" ARM64_LIBS REGEX  "lib\"$")

    string(REPLACE "\"" ";" ARM64_OBJS "${ARM64_OBJS}")
    string(REPLACE "\"" ";" ARM64_LIBS "${ARM64_LIBS}")
    string(REPLACE "\"" ";" ARM64_DEF "${ARM64_DEF}")
    string(REPLACE "/def:" "/defArm64Native:" ARM64_DEF "${ARM64_DEF}")

    target_sources(${n} PRIVATE ${ARM64_OBJS})
    target_link_options(${n} PRIVATE /machine:arm64x "${ARM64_DEF}" "${ARM64_LIBS}")
endfunction()

function(UpdateTargetForArm64X arm64xTargets)
    if("${BUILD_AS_ARM64X}" STREQUAL "ARM64")
        # During the arm64 build, create link.rsp files that containes the absolute path to the inputs
        # passed to the linker (objs, def files, libs).
        get_arm64_repro_dir(arm64ReproDir)
        add_custom_target(mkdirs ALL COMMAND cmd /c (if not exist \"${arm64ReproDir}/\" mkdir \"${arm64ReproDir}\" ))
        foreach (target ${arm64xTargets})
            add_dependencies(${target} mkdirs)
            # tell the linker to produce this special rsp file that has absolute paths to its inputs
            target_link_options(${target} PRIVATE "/LINKREPROFULLPATHRSP:${arm64ReproDir}/${target}.rsp")
        endforeach()
    elseif("${BUILD_AS_ARM64X}" STREQUAL "ARM64EC")
        # During the ARM64EC build, modify the link step appropriately to produce an arm64x binary
        foreach (target ${arm64xTargets})
            set_arm64_dependencies(${target})
        endforeach()
    endif()
endfunction()