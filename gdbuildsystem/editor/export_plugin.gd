## Purpose:
# This file will define the primary export plugin, this allows us to manage the order of the execution of sub-export plugins.
#  Additionally, this plugin will allow continuous memory between the export plugins, so we can share data between them.
@tool
class_name GDBuildSystemEditorExportPlugin
extends EditorExportPlugin

var settings: BuildSystemSettings:
    get():
        return GDBuildSystemPlugin.settings
var _export_steps: Array[ExportStep] = []
var godot_files: GodotFiles

func add_step(step: ExportStep) -> void:
    _export_steps.append(step)

func insert_step(step: ExportStep, index: int) -> void:
    _export_steps.insert(index, step)

func _export_begin(features: PackedStringArray, is_debug: bool, executable_path: String, flags: int) -> void:
    godot_files = GodotFiles.new()

    for step: ExportStep in _export_steps:
        # Share variables with the export step.
        # ------------------------------------------
        step.godot_files = godot_files
        step.export_configuration = ExportStep.Configuration.RELEASE if not is_debug else ExportStep.Configuration.DEBUG
        step.features = features
        step.output_path = executable_path.get_base_dir()
        step.executable_path = executable_path
        # ------------------------------------------
        
        if not step.is_runnable():
            continue # Skip steps that are not runnable.

        print("Running export step: %s" % step._get_name())

        # Execute the begin method of the export step.
        step.begin()
    # After the godot files are editted by the export steps, we will flush them to the disk.
    godot_files.flush()

func _export_end() -> void:
    for step in _export_steps:
        if not step.is_runnable():
            continue # Skip steps that are not runnable.
        step.end()
    # After the export steps are done, we will restore the godot files to their original state.
    godot_files.restore()

func _export_file(path: String, type: String, features: PackedStringArray) -> void:
    for step in _export_steps:
        if not step.is_runnable():
            continue # Skip steps that are not runnable.
        if step.next_file(path, type) == ExportStep.FileResult.SKIP:
            skip()
            continue