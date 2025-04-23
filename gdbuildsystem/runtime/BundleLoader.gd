class_name BundleLoader
extends Node

signal on_loaded_bundle(name: String)
signal on_inform_to_be_loaded(bundle_path: String)

@export var autoload: bool = true

func _ready() -> void:
    if not DirAccess.dir_exists_absolute(BuiltBundleData.get_bundle_path()):
        push_error("Cannot find Bundles Directory, exiting...")
        await get_tree().process_frame
        get_tree().quit(1)
        return
        
    # Inform other systems about what we want to do.
    for bundle_name: String in BuiltBundleData.get_bundles():
        var bundle_path: String = "%s/%s.pck" % [BuiltBundleData.get_bundle_path(), bundle_name]
        on_inform_to_be_loaded.emit(bundle_path)
        
    if autoload:
        load_internal_bundles()

func load_internal_bundles() -> void:
    for bundle_name: String in BuiltBundleData.get_bundles():
        var bundle_path: String = "%s/%s.pck" % [BuiltBundleData.get_bundle_path(), bundle_name]
        if not ProjectSettings.load_resource_pack(bundle_path) and not OS.has_feature("editor"):
            push_error("Failed loading bundle: %s" % bundle_name)
            continue
        on_loaded_bundle.emit(bundle_path)
