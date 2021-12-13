# Helper function to set up runtime or library targets
function(setup_binary_target target)
  _setup_binary_target(${ARGV})

  if(DEFINED ENV{obsInstallerTempDir})
    install(
      TARGETS ${target}
      RUNTIME
        DESTINATION $ENV{obsInstallerTempDir}/${OBS_EXECUTABLE_DESTINATION}
        COMPONENT obs_rundir
      LIBRARY DESTINATION $ENV{obsInstallerTempDir}/${OBS_LIBRARY_DESTINATION}
              COMPONENT obs_rundir
      PUBLIC_HEADER
        DESTINATION ${OBS_INCLUDE_DESTINATION}
        COMPONENT obs_rundir
        EXCLUDE_FROM_ALL)

    if(MSVC)
      install(
        FILES $<TARGET_PDB_FILE:${target}>
        CONFIGURATIONS "RelWithDebInfo" "Debug"
        DESTINATION
          $ENV{obsInstallerTempDir}/$<IF:$<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,EXECUTABLE>,${OBS_EXECUTABLE_DESTINATION},${OBS_LIBRARY_DESTINATION}>
        COMPONENT obs_rundir
        OPTIONAL EXCLUDE_FROM_ALL)
    endif()
  endif()

  if(MSVC)
    install(
      FILES $<TARGET_PDB_FILE:${target}>
      CONFIGURATIONS "RelWithDebInfo" "Debug"
      DESTINATION
        $<IF:$<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,EXECUTABLE>,${OBS_EXECUTABLE_DESTINATION},${OBS_LIBRARY_DESTINATION}>
      COMPONENT ${target}_Runtime
      OPTIONAL)

    install(
      FILES $<TARGET_PDB_FILE:${target}>
      CONFIGURATIONS "RelWithDebInfo" "Debug"
      DESTINATION
        $<IF:$<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,EXECUTABLE>,${OBS_EXECUTABLE_DESTINATION},${OBS_LIBRARY_DESTINATION}>
      COMPONENT obs_rundir
      OPTIONAL EXCLUDE_FROM_ALL)
  endif()

  if(${target} STREQUAL "libobs")
    setup_libobs_target(${target})
  endif()
endfunction()

# Helper function to set up OBS plugin targets
function(setup_plugin_target target)
  _setup_plugin_target(${ARGV})

  if(MSVC)
    install(
      FILES $<TARGET_PDB_FILE:${target}>
      CONFIGURATIONS "RelWithDebInfo" "Debug"
      DESTINATION ${OBS_PLUGIN_DESTINATION}
      COMPONENT ${target}_Runtime
      OPTIONAL)

    install(
      FILES $<TARGET_PDB_FILE:${target}>
      CONFIGURATIONS "RelWithDebInfo" "Debug"
      DESTINATION ${OBS_PLUGIN_DESTINATION}
      COMPONENT obs_rundir
      OPTIONAL EXCLUDE_FROM_ALL)
  endif()

  if(DEFINED ENV{obsInstallerTempDir})
    install(
      TARGETS ${target}
      RUNTIME DESTINATION $ENV{obsInstallerTempDir}/${OBS_PLUGIN_DESTINATION}
              COMPONENT obs_rundir
      LIBRARY DESTINATION $ENV{obsInstallerTempDir}/${OBS_PLUGIN_DESTINATION}
              COMPONENT obs_rundir
              EXCLUDE_FROM_ALL)

    if(MSVC)
      install(
        FILES $<TARGET_PDB_FILE:${target}>
        CONFIGURATIONS "RelWithDebInfo" "Debug"
        DESTINATION $ENV{obsInstallerTempDir}/${OBS_PLUGIN_DESTINATION}
        COMPONENT obs_rundir
        OPTIONAL EXCLUDE_FROM_ALL)
    endif()
  endif()
endfunction()

# Helper function to set up OBS scripting plugin targets
function(setup_script_plugin_target target)
  _setup_script_plugin_target(${ARGV})

  if(MSVC)
    install(
      FILES $<TARGET_PDB_FILE:${target}>
      CONFIGURATIONS "RelWithDebInfo" "Debug"
      DESTINATION ${OBS_SCRIPT_PLUGIN_DESTINATION}
      COMPONENT obs_rundir
      OPTIONAL EXCLUDE_FROM_ALL)
  endif()

  if(DEFINED ENV{obsInstallerTempDir})
    install(
      TARGETS ${target}
      RUNTIME
        DESTINATION $ENV{obsInstallerTempDir}/${OBS_SCRIPT_PLUGIN_DESTINATION}
        COMPONENT obs_rundir
      LIBRARY
        DESTINATION $ENV{obsInstallerTempDir}/${OBS_SCRIPT_PLUGIN_DESTINATION}
        COMPONENT obs_rundir
        EXCLUDE_FROM_ALL)

    if(MSVC)
      install(
        FILES $<TARGET_PDB_FILE:${target}>
        CONFIGURATIONS "RelWithDebInfo" "Debug"
        DESTINATION $ENV{obsInstallerTempDir}/${OBS_SCRIPT_PLUGIN_DESTINATION}
        COMPONENT obs_rundir
        OPTIONAL EXCLUDE_FROM_ALL)
    endif()

    if(${target} STREQUAL "obspython" AND ${_ARCH_SUFFIX} EQUAL 64)
      install(
        FILES
          "$<TARGET_FILE_DIR:${target}>/$<TARGET_FILE_BASE_NAME:${target}>.py"
        DESTINATION $ENV{obsInstallerTempDir}/${OBS_SCRIPT_PLUGIN_DESTINATION}
        COMPONENT obs_rundir
        EXCLUDE_FROM_ALL)
    endif()
  endif()
endfunction()

# Helper function to set up target resources (e.g. L10N files)
function(setup_target_resources target destination)
  _setup_target_resources(${ARGV})

  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/data")
    if(${_ARCH_SUFFIX} EQUAL 64 AND DEFINED ENV{obsInstallerTempDir})

      install(
        DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data/
        DESTINATION
          $ENV{obsInstallerTempDir}/${OBS_DATA_DESTINATION}/${destination}
        USE_SOURCE_PERMISSIONS
        COMPONENT obs_rundir
        EXCLUDE_FROM_ALL)
    endif()
  endif()
endfunction()

# Helper function to set up specific resource files for targets
function(add_target_resource target resource destination)
  _add_target_resource(${ARGV})

  if(DEFINED ENV{obsInstallerTempDir})
    install(
      FILES ${resource}
      DESTINATION
        $ENV{obsInstallerTempDir}/${OBS_DATA_DESTINATION}/${destination}
      COMPONENT obs_rundir
      EXCLUDE_FROM_ALL)
  endif()
endfunction()

# Helper function to set up OBS app target
function(setup_obs_app target)
  # detect outdated obs-browser submodule
  if(NOT TARGET OBS::browser AND TARGET obs-browser)
    if(MSVC)
      target_compile_options(obs-browser PRIVATE $<IF:$<CONFIG:DEBUG>,/MTd,/MT>)

      target_compile_options(obs-browser-page
                             PRIVATE $<IF:$<CONFIG:DEBUG>,/MTd,/MT>)
    endif()

    target_link_options(obs-browser PRIVATE "LINKER:/IGNORE:4099")

    target_link_options(obs-browser-page PRIVATE "LINKER:/IGNORE:4099"
                        "LINKER:/SUBSYSTEM:WINDOWS")
  endif()

  _setup_obs_app(${ARGV})

  if(MSVC)
    include(CopyMSVCBins)
  endif()
endfunction()

# Helper function to export target to build and install tree. Allows usage of
# `find_package(libobs)` by other build trees
function(export_target target)
  set(CMAKE_EXPORT_PACKAGE_REGISTRY OFF)

  install(
    TARGETS ${target}
    EXPORT ${target}Targets
    RUNTIME DESTINATION "${OBS_EXECUTABLE_EXPORT_DESTINATION}"
            COMPONENT obs_libraries
    LIBRARY DESTINATION "${OBS_LIBRARY_EXPORT_DESTINATION}"
            COMPONENT obs_libraries
    ARCHIVE DESTINATION "${OBS_LIBRARY_EXPORT_DESTINATION}"
            COMPONENT obs_libraries
    INCLUDES
    DESTINATION "${OBS_INCLUDE_DESTINATION}"
    PUBLIC_HEADER DESTINATION "${OBS_INCLUDE_DESTINATION}"
                  COMPONENT obs_libraries)

  if(MSVC)
    install(
      DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/pdbs/"
      DESTINATION "${OBS_EXECUTABLE_EXPORT_DESTINATION}"
      CONFIGURATIONS Debug RelWithDebInfo
      COMPONENT obs_libraries
      EXCLUDE_FROM_ALL)
  endif()

  include(GenerateExportHeader)
  generate_export_header(${target} EXPORT_FILE_NAME
                         "${CMAKE_CURRENT_BINARY_DIR}/${target}_EXPORT.h")

  target_sources(${target}
                 PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${target}_EXPORT.h")

  set(TARGETS_EXPORT_NAME "${target}Targets")
  include(CMakePackageConfigHelpers)
  configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${target}Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake"
    INSTALL_DESTINATION ${OBS_CMAKE_DESTINATION}
    PATH_VARS OBS_PLUGIN_DESTINATION OBS_DATA_DESTINATION)

  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${target}ConfigVersion.cmake
    VERSION ${OBS_VERSION_CANONICAL}
    COMPATIBILITY SameMajorVersion)

  export(
    EXPORT ${target}Targets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/${TARGETS_EXPORT_NAME}.cmake"
    NAMESPACE OBS::)

  export(PACKAGE "${target}")

  install(
    EXPORT ${TARGETS_EXPORT_NAME}
    FILE ${TARGETS_EXPORT_NAME}.cmake
    NAMESPACE OBS::
    DESTINATION ${OBS_CMAKE_DESTINATION}
    COMPONENT obs_libraries)

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake
          ${CMAKE_CURRENT_BINARY_DIR}/${target}ConfigVersion.cmake
    DESTINATION ${OBS_CMAKE_DESTINATION}
    COMPONENT obs_libraries)
endfunction()

# Helper function to do additional setup for browser source plugin
function(setup_target_browser target)
  install(
    DIRECTORY ${CEF_ROOT_DIR}/Resources/
    DESTINATION ${OBS_PLUGIN_DESTINATION}
    COMPONENT ${target}_Runtime)

  install(
    DIRECTORY ${CEF_ROOT_DIR}/Resources/
    DESTINATION ${OBS_OUTPUT_DIR}/$<CONFIG>/${OBS_PLUGIN_DESTINATION}
    COMPONENT obs_rundir
    EXCLUDE_FROM_ALL)

  if(DEFINED ENV{obsInstallerTempDir})
    install(
      DIRECTORY ${CEF_ROOT_DIR}/Resources/
      DESTINATION $ENV{obsInstallerTempDir}/${OBS_PLUGIN_DESTINATION}
      COMPONENT obs_rundir
      EXCLUDE_FROM_ALL)
  endif()

  set(_ADDITIONAL_BROWSER_FILES
      "libcef.dll" "libEGL.dll" "libGLESv2.dll" "snapshot_blob.bin"
      "v8_context_snapshot.bin" "natives_blob.bin")

  foreach(_ADDITIONAL_BROWSER_FILE IN LISTS _ADDITIONAL_BROWSER_FILES)
    if(EXISTS "${CEF_ROOT_DIR}/Release/${_ADDITIONAL_BROWSER_FILE}")
      install(
        FILES ${CEF_ROOT_DIR}/Release/${_ADDITIONAL_BROWSER_FILE}
        DESTINATION ${OBS_PLUGIN_DESTINATION}/
        COMPONENT ${target}_Runtime)

      install(
        FILES ${CEF_ROOT_DIR}/Release/${_ADDITIONAL_BROWSER_FILE}
        DESTINATION ${OBS_OUTPUT_DIR}/$<CONFIG>/${OBS_PLUGIN_DESTINATION}/
        COMPONENT obs_rundir
        EXCLUDE_FROM_ALL)

      if(DEFINED ENV{obsInstallerTempDir})
        install(
          FILES ${CEF_ROOT_DIR}/Release/${_ADDITIONAL_BROWSER_FILE}
          DESTINATION $ENV{obsInstallerTempDir}/${OBS_PLUGIN_DESTINATION}/
          COMPONENT obs_rundir
          EXCLUDE_FROM_ALL)
      endif()
    endif()
  endforeach()
endfunction()

# Helper function to gather external libraries depended-on by libobs
function(setup_libobs_target target)
  set(_ADDITIONAL_FILES "${CMAKE_SOURCE_DIR}/additional_install_files")

  if(DEFINED ENV{obsAdditionalInstallFiles})
    set(_ADDITIONAL_FILES "$ENV{obsAdditionalInstallFiles}")
  endif()

  if(NOT INSTALLER_RUN)
    list(APPEND _LIBOBS_FIXUPS "misc:." "data:${OBS_DATA_DESTINATION}"
         "libs${_ARCH_SUFFIX}:${OBS_LIBRARY_DESTINATION}"
         "exec${_ARCH_SUFFIX}:${OBS_EXECUTABLE_DESTINATION}")
  else()
    list(
      APPEND
      _LIBOBS_FIXUPS
      "misc:."
      "data:${OBS_DATA_DESTINATION}"
      "libs32:${OBS_LIBRARY32_DESTINATION}"
      "libs64:${OBS_LIBRARY64_DESTINATION}"
      "exec32:${OBS_EXECUTABLE32_DESTINATION}"
      "exec64:${OBS_EXECUTABLE64_DESTINATION}")
  endif()

  foreach(_FIXUP IN LISTS _LIBOBS_FIXUPS)
    string(REPLACE ":" ";" _FIXUP ${_FIXUP})
    list(GET _FIXUP 0 _SOURCE)
    list(GET _FIXUP 1 _DESTINATION)

    install(
      DIRECTORY ${_ADDITIONAL_FILES}/${_SOURCE}/
      DESTINATION ${_DESTINATION}
      USE_SOURCE_PERMISSIONS
      COMPONENT ${target}_Runtime
      PATTERN ".gitignore" EXCLUDE)

    install(
      DIRECTORY ${_ADDITIONAL_FILES}/${_SOURCE}/
      DESTINATION ${_DESTINATION}
      USE_SOURCE_PERMISSIONS
      COMPONENT obs_rundir
      EXCLUDE_FROM_ALL
      PATTERN ".gitignore" EXCLUDE)

    if(_SOURCE MATCHES "(libs|exec)(32|64)?")
      install(
        DIRECTORY "${_ADDITIONAL_FILES}/${_SOURCE}$<IF:$<CONFIG:Debug>,d,r>/"
        DESTINATION "${_DESTINATION}"
        USE_SOURCE_PERMISSIONS
        COMPONENT ${target}_Runtime
        PATTERN ".gitignore" EXCLUDE)

      install(
        DIRECTORY ${_ADDITIONAL_FILES}/${_SOURCE}$<IF:$<CONFIG:Debug>,d,r>/
        DESTINATION ${_DESTINATION}
        USE_SOURCE_PERMISSIONS
        COMPONENT obs_rundir
        EXCLUDE_FROM_ALL
        PATTERN ".gitignore" EXCLUDE)
    endif()
  endforeach()
endfunction()

# Helper function to compile artifacts for multi-architecture installer
function(generate_multiarch_installer)
  if(NOT DEFINED ENV{obsInstallerTempDir})
    message(
      FATAL_ERROR
        "Function generate_multiarch_installer requires environment variable 'obsInstallerTempDir' to be set"
    )
  endif()

  add_custom_target(installer_files ALL)

  setup_libobs_target(installer_files)

  install(
    DIRECTORY "$ENV{obsInstallerTempDir}/"
    DESTINATION "."
    USE_SOURCE_PERMISSIONS)
endfunction()
