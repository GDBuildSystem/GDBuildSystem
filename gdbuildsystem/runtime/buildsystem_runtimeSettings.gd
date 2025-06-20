extends RefCounted
class_name BuildSystemRuntimeSettings

const DEFAULT_PROJECT_SETTINGS_PATH: String = "build_system/runtime_settings"
const DEFAULT_PROJECT_SETTINGS_LOADING_SCREEN_PATH: String = "res://addons/gdbuildsystem/runtime/AssetLoader/LoadingScene.tscn"

static var loading_screen_path: String:
    get():
        return ProjectSettings.get_setting(DEFAULT_PROJECT_SETTINGS_PATH + "/asset_loader/loading_screen_path", DEFAULT_PROJECT_SETTINGS_LOADING_SCREEN_PATH)

static var loading_screen_scene: PackedScene:
    get():
        if not ResourceLoader.exists(loading_screen_path):
            push_error("Loading screen scene not found at path: %s" % loading_screen_path)
            return null
        return load(loading_screen_path) as PackedScene

func _init() -> void:
    _set_setting_property(DEFAULT_PROJECT_SETTINGS_PATH + "/asset_loader/loading_screen_path", DEFAULT_PROJECT_SETTINGS_LOADING_SCREEN_PATH)
    ProjectSettings.add_property_info({
        "name": DEFAULT_PROJECT_SETTINGS_PATH + "/asset_loader/loading_screen_path",
        "type": TYPE_STRING,
        "hint_string": "*.tscn,*.scn",
        "hint": PROPERTY_HINT_FILE
    })

func _set_setting_property(key: String, value: Variant) -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, value)
    ProjectSettings.set_initial_value(key, value)