@tool
extends EditorPlugin
class_name GDBuildSystemPlugin

const PLUGIN_PROJECT_SETTINGS: String = "build_system"

static var settings: BuildSystemSettings:
    get():
        if settings == null:
            settings = BuildSystemSettings.new()
        return settings
static var runtime_settings: BuildSystemRuntimeSettings:
    get():
        if runtime_settings == null:
            runtime_settings = BuildSystemRuntimeSettings.new()
        return runtime_settings

var main_export_plugin: GDBuildSystemEditorExportPlugin

const assetLoaderPath: String = "res://addons/gdbuildsystem/runtime/AssetLoader/AssetLoader.gd"

func _enter_tree() -> void:
    # Initialize the settings.
    BuildSystemSettings.new()
    BuildSystemRuntimeSettings.new()
    # Initialize the plugin.
    main_export_plugin = GDBuildSystemEditorExportPlugin.new()
    main_export_plugin.add_step(GDBuildExportStep_BuildScript.new())
    main_export_plugin.add_step(GDBuildExportStep_Preloads.new())
    main_export_plugin.add_step(GDBuildExportStep_Bundles.new())
    # Add the main export plugin to the editor.
    add_export_plugin(main_export_plugin)

    # Autoload the asset loader.
    add_autoload_singleton("AssetLoader", assetLoaderPath)

func _exit_tree() -> void:
    remove_export_plugin(main_export_plugin)
    remove_autoload_singleton("AssetLoader")
