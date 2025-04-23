class_name ExportBuildScript

var excluded_resource_paths: PackedStringArray = []

#- Virtual Methods -#

## Executes the build script before the export process.
## This is useful for implementing a semantic version system, where before it builds it will be grabbing an environment variable to update the version.
func _pre_build() -> void:
    pass

## Executes the build script after the export process.
## This is useful for cleaning up the build directory or running a script that will run a command line tool to build the project, like a C++ project that uses premake or cmake.
func _post_build() -> void:
    pass

#- Useful Methods -#

## Add a file to the list of excluded files. 
func add_excluded_resource_path(resource_path: String) -> void:
    if excluded_resource_paths.has(resource_path):
        return
    excluded_resource_paths.append(resource_path)
## Remove a file from the list of excluded files.
func get_excluded_resource_paths() -> PackedStringArray:
    # Get the list of excluded files.
    return excluded_resource_paths