@tool
class_name EditorExportBuildScript
extends EditorExportPlugin

## ExportBuildScript
# This exporter is responsible for running a build script when exporting the project, it will be run before and after the execution of the export process.
# --- Uses Cases --- #
# * When exporting a build, we may want to implement a semantic version system, where before it builds it will be grabbing an environment variable to update the version.
# * Another use is to have files excluded from the buildsystem programmatically.
# * We may want to run a script that will run a command line tool to build the project, like a C++ project that uses premake or cmake. 
# * Etc...
