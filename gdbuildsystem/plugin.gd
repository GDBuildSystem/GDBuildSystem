@tool
extends EditorPlugin
class_name GDBuildSystemPlugin

static var settings: BuildSystemSettings:
    get():
        if settings == null:
            settings = BuildSystemSettings.new()
        return settings

var main_export_plugin: GDBuildSystemEditorExportPlugin

func _enter_tree() -> void:
    # Initialize the settings.
    BuildSystemSettings.new()
    # Initialize the plugin.
    main_export_plugin = GDBuildSystemEditorExportPlugin.new()
    main_export_plugin.add_step(GDBuildExportStep_BuildScript.new())
    main_export_plugin.add_step(GDBuildExportStep_Preloads.new())
    main_export_plugin.add_step(GDBuildExportStep_Bundles.new())
    # Add the main export plugin to the editor.
    add_export_plugin(main_export_plugin)

func _exit_tree() -> void:
    remove_export_plugin(main_export_plugin)
