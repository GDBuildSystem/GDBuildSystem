# Purpose: Base class for export steps in the Godot Build System.
#  This class is designed to be extended by specific export steps that will handle different aspects of the export process.
@tool
class_name ExportStep # Todo : 4.5-dev5 adds abstract classes, once that is stable, we can make this an abstract class.

enum FileResult {
    SKIP,
    EXPORT
}

enum Configuration {
    RELEASE,
    DEBUG
}

var settings: BuildSystemSettings:
    get():
        return GDBuildSystemPlugin.settings
var godot_files: GodotFiles
var export_configuration: Configuration = Configuration.RELEASE
var features: PackedStringArray = []
var output_path: String = ""
var executable_path: String = ""

## This method is called at the beginning of the export process.
## Essentially, before the gdscripts or any other resource are compiled and exported.
func begin() -> void: # Virtual method to be overridden by subclasses.
    pass

## This method is called at the end of the export process, post-build of the project's executable.
## This is where you can do any final cleanup or modifications to the exported files.
## Note: godot_files will be restored post this method.
func end() -> void: # Virtual method to be overridden by subclasses.
    pass

## This method is called for each file that is being exported.
## It allows you to modify the file or skip it based on the resource type.
func next_file(_file_path: String, _resource_type: String) -> FileResult: # Virtual method to be overridden by subclasses.
    return FileResult.EXPORT

func _get_name() -> String:
    assert(false, "This method should be overridden by subclasses to return the name of the export step.")
    return "Unknown Export Step"

## This method should be overridden by subclasses to specify if the export step can run.
func _override_can_run() -> bool:
    return true
## This method should be overridden by subclasses to specify the features required for this export step.
func _override_feature_requirements() -> PackedStringArray:
    return []
## This method should be overridden by subclasses to specify the features that are excluded for this export step.
func _override_feature_exclusions() -> PackedStringArray:
    return []
## This method should be overridden by subclasses to specify the configurations required for this export step.
func _override_required_configurations() -> PackedInt32Array:
    return [Configuration.RELEASE, Configuration.DEBUG]

## This method checks if the export step can run based on the current settings, features, and configurations.
func is_runnable() -> bool:
    # Custom rules to run the export step, and prevent it from running if the rules are not met.
    if not _override_can_run():
        return false
    # Check if the export configuration is valid for this step, and prevent the step from running if it is not.
    if not _override_required_configurations().has(export_configuration):
        return false
    # Check if the required features are present, and prevent the step from running if they are not.
    for feature in _override_feature_requirements():
        if not features.has(feature):
            return false
    # Check if any excluded features are present, and prevent the step from running if they are.
    for feature in _override_feature_exclusions():
        if features.has(feature):
            return false
    return true