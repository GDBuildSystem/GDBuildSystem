# Purpose: Build settings for the Godot Build System.

@tool
class_name BuildSystemSettings
extends RefCounted

# -------------------------------------------- CONSTANTS / DEFAULT VARIABLES -------------------------------------------- #
# Generic settings
const DEFAULT_PROJECT_SETTINGS_PATH: String = "build_system/settings/"
const DEFAULT_PROJECT_SETTINGS_RESOURCE_DIRECTORY: String = "res://Bundles"
const DEFAULT_PROJECT_SETTINGS_EXPORT_DIRECTORY: String = "bundles"
# Bundle settings
const DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH: String = DEFAULT_PROJECT_SETTINGS_PATH + "bundles/"
const DEFAULT_PROJECT_SETTINGS_BUNDLES_DEBUG: bool = false
const DEFAULT_PROJECT_SETTINGS_BUNDLES_FLUSH_VERBOSITY: bool = false
const DEFAULT_PROJECT_SETTINGS_BUNDLES_ENABLE: bool = true
const DEFAULT_PROJECT_SETTINGS_BUNDLES_BAKE_HASHES: bool = false
const DEFAULT_PROJECT_SETTINGS_BUNDLES_THREAD_LOADING: bool = true
const DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT: bool = false
const DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT_DIRECTORIES: bool = true
const DEFAULT_PROJECT_SETTINGS_BUNDLES_PROMITTED_RESOURCE_TYPES: PackedStringArray = ["res", "scn", "tscn", "tres", "glb", "gltf", "png", "wav", "ogg"]
# Preload settings
const DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH: String = DEFAULT_PROJECT_SETTINGS_PATH + "preloads/"
const DEFAULT_PROJECT_SETTINGS_PRELOAD_ENABLE: bool = true
const DEFAULT_PROJECT_SETTINGS_PRELOAD_DEBUG: bool = false
const DEFAULT_PROJECT_SETTINGS_PRELOAD_RECURSIVE_LOOKUP: bool = true
const DEFAULT_PROJECT_SETTINGS_PRELOAD_IGNORE_DIRECTORIES: PackedStringArray = []

# -------------------------------------------- VARIABLES -------------------------------------------- #

# Generic settings
static var export_directory: String = DEFAULT_PROJECT_SETTINGS_EXPORT_DIRECTORY:
    set(value):
        export_directory = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_PATH + "export_directory", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PATH + "export_directory", DEFAULT_PROJECT_SETTINGS_EXPORT_DIRECTORY)
static var resource_directory: String = DEFAULT_PROJECT_SETTINGS_RESOURCE_DIRECTORY:
    set(value):
        resource_directory = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_PATH + "resource_directory", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PATH + "resource_directory", DEFAULT_PROJECT_SETTINGS_RESOURCE_DIRECTORY).replace("\\", "/")

# Bundle settings
static var bundles_enabled: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_ENABLE:
    set(value):
        bundles_enabled = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "enable", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "enable", DEFAULT_PROJECT_SETTINGS_BUNDLES_ENABLE)
static var bundles_debug: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_DEBUG:
    set(value):
        bundles_debug = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "debug", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "debug", DEFAULT_PROJECT_SETTINGS_BUNDLES_DEBUG)
static var bundles_flush_verbosity: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_FLUSH_VERBOSITY:
    set(value):
        bundles_flush_verbosity = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "flush_verbosity", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "flush_verbosity", DEFAULT_PROJECT_SETTINGS_BUNDLES_FLUSH_VERBOSITY)
static var permitted_resources_types: PackedStringArray = DEFAULT_PROJECT_SETTINGS_BUNDLES_PROMITTED_RESOURCE_TYPES:
    set(value):
        permitted_resources_types = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "promitted_resource_types", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "promitted_resource_types", DEFAULT_PROJECT_SETTINGS_BUNDLES_PROMITTED_RESOURCE_TYPES)
static var bundles_bake_hashes: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_BAKE_HASHES:
    set(value):
        bundles_bake_hashes = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "bake_hashes", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "bake_hashes", DEFAULT_PROJECT_SETTINGS_BUNDLES_BAKE_HASHES)

static var bundles_thread_loading: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_THREAD_LOADING:
    set(value):
        bundles_thread_loading = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "thread_loading", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "thread_loading", DEFAULT_PROJECT_SETTINGS_BUNDLES_THREAD_LOADING)

static var bundles_encrypt: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT:
    set(value):
        bundles_encrypt = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "encrypt", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "encrypt", DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT)
static var bundles_encrypt_directories: bool = DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT_DIRECTORIES:
    set(value):
        bundles_encrypt_directories = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "encrypt_directories", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "encrypt_directories", DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT_DIRECTORIES)

# Preload settings
static var preloads_enabled: bool = DEFAULT_PROJECT_SETTINGS_PRELOAD_ENABLE:
    set(value):
        preloads_enabled = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "enable", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "enable", DEFAULT_PROJECT_SETTINGS_PRELOAD_ENABLE)
static var preloads_debug: bool = DEFAULT_PROJECT_SETTINGS_PRELOAD_DEBUG:
    set(value):
        preloads_debug = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "debug", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "debug", DEFAULT_PROJECT_SETTINGS_PRELOAD_DEBUG)
static var preloads_recursive_lookup: bool = DEFAULT_PROJECT_SETTINGS_PRELOAD_RECURSIVE_LOOKUP:
    set(value):
        preloads_recursive_lookup = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "recursive_lookup", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "recursive_lookup", DEFAULT_PROJECT_SETTINGS_PRELOAD_RECURSIVE_LOOKUP)
static var preloads_ignore_directories: PackedStringArray = DEFAULT_PROJECT_SETTINGS_PRELOAD_IGNORE_DIRECTORIES:
    set(value):
        preloads_ignore_directories = value
        ProjectSettings.set_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "ignore_directories", value)
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "ignore_directories", DEFAULT_PROJECT_SETTINGS_PRELOAD_IGNORE_DIRECTORIES)

# -------------------------------------------- FUNCTIONS -------------------------------------------- #

func _init() -> void:
    # Generic settings
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PATH + "export_directory", DEFAULT_PROJECT_SETTINGS_EXPORT_DIRECTORY)
    ProjectSettings.add_property_info({
        "name": DEFAULT_PROJECT_SETTINGS_PATH + "export_directory",
        "type": TYPE_STRING,
        "hint_string": "*",
        "hint": PROPERTY_HINT_GLOBAL_DIR
    })
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PATH + "resource_directory", DEFAULT_PROJECT_SETTINGS_RESOURCE_DIRECTORY)
    ProjectSettings.add_property_info({
        "name": DEFAULT_PROJECT_SETTINGS_PATH + "resource_directory",
        "type": TYPE_STRING,
        "hint_string": "*",
        "hint": PROPERTY_HINT_DIR
    })
    # Bundle settings
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "enable", DEFAULT_PROJECT_SETTINGS_BUNDLES_ENABLE)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "debug", DEFAULT_PROJECT_SETTINGS_BUNDLES_DEBUG)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "flush_verbosity", DEFAULT_PROJECT_SETTINGS_BUNDLES_FLUSH_VERBOSITY)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "promitted_resource_types", DEFAULT_PROJECT_SETTINGS_BUNDLES_PROMITTED_RESOURCE_TYPES)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "bake_hashes", DEFAULT_PROJECT_SETTINGS_BUNDLES_BAKE_HASHES)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "thread_loading", DEFAULT_PROJECT_SETTINGS_BUNDLES_THREAD_LOADING)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "encrypt", DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_BUNDLES_PATH + "encrypt_directories", DEFAULT_PROJECT_SETTINGS_BUNDLES_ENCRYPT_DIRECTORIES)
    # Preload settings
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "enable", DEFAULT_PROJECT_SETTINGS_PRELOAD_ENABLE)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "debug", DEFAULT_PROJECT_SETTINGS_PRELOAD_DEBUG)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "recursive_lookup", DEFAULT_PROJECT_SETTINGS_PRELOAD_RECURSIVE_LOOKUP)
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PRELOAD_PATH + "ignore_directories", DEFAULT_PROJECT_SETTINGS_PRELOAD_IGNORE_DIRECTORIES)

    # Save...
    ProjectSettings.save()

func _set_setting_property(key: String, value: Variant) -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, value)
    ProjectSettings.set_initial_value(key, value)
