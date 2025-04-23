class_name BuildSystemSettings
extends RefCounted

const DEFAULT_PROJECT_SETTING_PATH: String = "build_system/pack_bundles/"
const DEFAULT_PROJECT_SETTING_ENABLE: bool = true
const DEFAULT_PROJECT_SETTING_RESOURCE_DIRECTORY: String = "res://Bundles"
const DEFAULT_PROJECT_SETTING_EXPORT_DIRECTORY: String = "bundles"
const DEFAULT_PROJECT_SETTING_PROMITTED_RESOURCE_TYPES: PackedStringArray = ["res", "scn"]
const DEFAULT_PROJECT_SETTING_ENABLE_DEBUG: bool = false
const DEFAULT_PROJECT_SETTING_BAKE_BUNDLE_HASHES: bool = false
const DEFAULT_PROJECT_SETTINGS_THREAD_BUNDLES_LOADING: bool = true
const DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLES: bool = false
const DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLE_DIRECTORIES: bool = true

static var enabled: bool = DEFAULT_PROJECT_SETTING_ENABLE:
    set(value):
        enabled = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "enable", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "enable", DEFAULT_PROJECT_SETTING_ENABLE)
static var enabled_debug: bool = DEFAULT_PROJECT_SETTING_ENABLE_DEBUG:
    set(value):
        enabled_debug = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "enable_debug", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "enable_debug", DEFAULT_PROJECT_SETTING_ENABLE_DEBUG)

static var export_directory: String = DEFAULT_PROJECT_SETTING_EXPORT_DIRECTORY:
    set(value):
        export_directory = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "export_directory", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "export_directory", DEFAULT_PROJECT_SETTING_EXPORT_DIRECTORY)
static var resource_directory: String = DEFAULT_PROJECT_SETTING_RESOURCE_DIRECTORY:
    set(value):
        resource_directory = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "resource_directory", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "resource_directory", DEFAULT_PROJECT_SETTING_RESOURCE_DIRECTORY).replace("\\", "/")

static var promitted_resources_types: PackedStringArray = DEFAULT_PROJECT_SETTING_PROMITTED_RESOURCE_TYPES:
    set(value):
        promitted_resources_types = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "promitted_resource_types", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "promitted_resource_types", DEFAULT_PROJECT_SETTING_PROMITTED_RESOURCE_TYPES)
        
        
static var bake_bundle_hashes: bool = DEFAULT_PROJECT_SETTING_BAKE_BUNDLE_HASHES:
    set(value):
        bake_bundle_hashes = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "bake_bundle_hashes", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "bake_bundle_hashes", DEFAULT_PROJECT_SETTING_BAKE_BUNDLE_HASHES)

static var thread_bundles_loading: bool = DEFAULT_PROJECT_SETTINGS_THREAD_BUNDLES_LOADING:
    set(value):
        bake_bundle_hashes = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "thread_bundles_loading", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "thread_bundles_loading", DEFAULT_PROJECT_SETTINGS_THREAD_BUNDLES_LOADING)

static var encrypt_bundles: bool = DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLES:
    set(value):
        bake_bundle_hashes = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "encrypt_bundles", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "encrypt_bundles", DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLES)

static var encrypt_bundle_directories: bool = DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLE_DIRECTORIES:
    set(value):
        bake_bundle_hashes = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + "encrypt_bundle_directories", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTING_PATH + "encrypt_bundle_directories", DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLE_DIRECTORIES)


func _init() -> void:
    _set_setting_property("enable", DEFAULT_PROJECT_SETTING_ENABLE)
    _set_setting_property("enable_debug", DEFAULT_PROJECT_SETTING_ENABLE_DEBUG)
    _set_setting_property("export_directory", DEFAULT_PROJECT_SETTING_EXPORT_DIRECTORY)
    _set_setting_property("resource_directory", DEFAULT_PROJECT_SETTING_RESOURCE_DIRECTORY)
    _set_setting_property("promitted_resource_types", DEFAULT_PROJECT_SETTING_PROMITTED_RESOURCE_TYPES)
    _set_setting_property("bake_bundle_hashes", DEFAULT_PROJECT_SETTING_BAKE_BUNDLE_HASHES)
    _set_setting_property("thread_bundles_loading", DEFAULT_PROJECT_SETTINGS_THREAD_BUNDLES_LOADING)
    _set_setting_property("encrypt_bundles", DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLES)
    _set_setting_property("encrypt_bundle_directories", DEFAULT_PROJECT_SETTINGS_ENCRYPT_BUNDLE_DIRECTORIES)

func _set_setting_property(key: String, value: Variant) -> void:
    if not ProjectSettings.has_setting(DEFAULT_PROJECT_SETTING_PATH + key):
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTING_PATH + key, value)
    ProjectSettings.set_initial_value(DEFAULT_PROJECT_SETTING_PATH + key, value)
