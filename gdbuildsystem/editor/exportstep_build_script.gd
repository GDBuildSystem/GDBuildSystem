# Purpose: This class is responsible for running the build scripts before and after the export process.
#  It will find all scripts that extend ExportStep outside of the addons folder and run them.

@tool
class_name GDBuildExportStep_BuildScript
extends ExportStep

var gdscripts: PackedStringArray = []
var _buildscripts: PackedStringArray = []
var _buildscripts_steps: Array[ExportStep] = []

func begin() -> void:
    gdscripts.clear()
    _buildscripts.clear()
    gdscripts = _recursively_file_find(".gd", "res://")
    for gdscript: String in gdscripts:
        if gdscript.begins_with("res://addons/") or gdscript.begins_with("res:///addons/"): # Skip scripts in the addons folder.
            continue
        var file: FileAccess = FileAccess.open(gdscript, FileAccess.READ)
        if file:
            var content: String = file.get_as_text()
            file.close()
            if content.find("extends ExportStep") != -1:
                _buildscripts.append(gdscript)
    for buildscript: String in _buildscripts:
        var script: GDScript = load(buildscript)
        if script == null:
            push_error("BuildScript: Failed to load build script: %s" % buildscript)
            continue
        if not script.is_tool(): # This is a good practice to ensure the script is a tool script, since we want to execute it on the editor.
            push_error("BuildScript: Build script is not a tool script: %s" % buildscript)
            continue
        var step: ExportStep = script.new()
        if not step is ExportStep:
            push_error("BuildScript: Build script does not extend ExportStep: %s" % buildscript)
            continue
        
        # Set the properties for the step before running it.
        step.godot_files = godot_files
        step.export_configuration = export_configuration
        step.features = features
        step.output_path = output_path
        step.executable_path = executable_path
        if not step.is_runnable():
            print("BuildScript: Skipping build script: %s" % buildscript)
            continue # Skip steps that are not runnable.
        print("BuildScript: Running pre-build script: %s" % buildscript)
        # Run the step.
        step.begin()
        _buildscripts_steps.append(step)

func end() -> void:
    for step: ExportStep in _buildscripts_steps:
        if not step.is_runnable():
            continue # Skip steps that are not runnable.
        step.end()

func next_file(_file_path: String, _resource_type: String) -> FileResult:
    if _buildscripts.has(_file_path):
        return FileResult.SKIP # Skip files that are build scripts themselves.

    for step: ExportStep in _buildscripts_steps:
        if not step.is_runnable():
            continue # Skip steps that are not runnable.
        var result: FileResult = step.next_file(_file_path, _resource_type)
        if result == FileResult.SKIP:
            return FileResult.SKIP
    return FileResult.EXPORT

func _recursively_file_find(search: String, path: String) -> PackedStringArray:
    var files: PackedStringArray = []
    var dir: DirAccess = DirAccess.open(path)
    dir.list_dir_begin()
    var file: String = dir.get_next()
    while file != "":
        var file_path: String = path + "/" + file
        if dir.current_is_dir():
            files += _recursively_file_find(search, file_path)
        elif file_path.ends_with(search):
            files.append(file_path)
        file = dir.get_next()
    return files

func _get_name() -> String:
    return "Build Script Extender"