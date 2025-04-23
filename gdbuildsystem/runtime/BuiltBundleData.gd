class_name BuiltBundleData

const BUNDLE_PATH: String = "./"
const BUILT_BUNDLES: PackedStringArray = []
const BUILT_BUNDLES_HASHES: PackedInt64Array = []
const THREAD_BUNDLE_LOADING: bool = false

static func get_bundle_path() -> String:
    if OS.has_feature("editor"):
        return ProjectSettings.get_setting("build_system/pack_bundles/resource_directory", "").replace("\\", "/")
    else:
        return BUNDLE_PATH

static func get_bundles() -> PackedStringArray:
    if OS.has_feature("editor"):
        var resource_directory: String = get_bundle_path()
        var bundles: PackedStringArray = DirAccess.get_directories_at(resource_directory)
        return bundles
    else:
        return BUILT_BUNDLES
