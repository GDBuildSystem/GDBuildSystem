@tool
extends EditorPlugin

var export_bundler_plugin: EditorBundlerExportPlugin
var export_preload_required_scene_plugin: EditorExportPreloadRequiredScenes

func _enter_tree() -> void:
    # Initialize the settings.
    BuildSystemSettings.new()
    # Initialize the plugins.
    export_bundler_plugin = EditorBundlerExportPlugin.new()
    export_preload_required_scene_plugin = EditorExportPreloadRequiredScenes.new()
    add_export_plugin(export_bundler_plugin)
    add_export_plugin(export_preload_required_scene_plugin)

func _exit_tree() -> void:
    remove_export_plugin(export_bundler_plugin)
    remove_export_plugin(export_preload_required_scene_plugin)
