class_name BundleLoader
extends Node

const FEATURE_NO_BUNDLES: String = "no_bundles"

signal on_loaded_bundle(name: String)
signal on_inform_to_be_loaded(bundle_path: String)

@export var autoload: bool = true

func _ready() -> void:
    if OS.has_feature(FEATURE_NO_BUNDLES):
        return # No bundles to load, skip. Useful for dedicated servers.
    var bundles_path: String = "%s/%s" % [OS.get_executable_path().get_base_dir(), BuiltBundleData.get_bundle_path()]
    if not DirAccess.dir_exists_absolute(bundles_path) and not OS.has_feature("editor"):
        push_error("Cannot find Bundles Directory, exiting...")
        await get_tree().process_frame
        get_tree().quit(1)
        return
        
    # Inform other systems about what we want to do.
    for bundle_name: String in BuiltBundleData.get_bundles():
        var bundle_filename: String = "%s.pck" % bundle_name
        on_inform_to_be_loaded.emit(bundle_filename)
        AssetLoader.load_path(bundle_filename)
        
    if autoload:
        load_internal_bundles()

func load_internal_bundles() -> void:
    if OS.has_feature(FEATURE_NO_BUNDLES):
        return # No bundles to load, skip. Useful for dedicated servers.
    var absolute_bundles_path: String = "%s/%s" % [OS.get_executable_path().get_base_dir(), BuiltBundleData.get_bundle_path()]
    for bundle_name: String in BuiltBundleData.get_bundles():
        var absolute_bundle_path: String = "%s/%s.pck" % [absolute_bundles_path, bundle_name]
        var bundle_filename: String = "%s.pck" % bundle_name
        if OS.has_feature("debug"):
            print("Loading Bundle: %s" % absolute_bundle_path)
        
        if not OS.has_feature("editor"):
            if FileAccess.file_exists(absolute_bundle_path) == false:
                push_error("Cannot find bundle: %s" % absolute_bundle_path)
                continue
        
            var success: bool = ProjectSettings.load_resource_pack(absolute_bundle_path, true)
            if not success:
                push_error("Failed loading bundle: %s" % bundle_name)
                continue
            if OS.has_feature("debug"):
                print("Loaded Bundle: %s" % bundle_name)
        
        on_loaded_bundle.emit(bundle_filename)
        AssetLoader._handle_finished_asset(bundle_filename)
