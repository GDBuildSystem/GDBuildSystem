extends Control

@export var progress_bar: ProgressBar
@export var loading_text: Label

func _ready() -> void:
    AssetLoader.on_loaded_asset.connect(_on_asset_loader_loaded_asset)
    AssetLoader.on_progress_update.connect(_on_asset_loader_progress_update)
    AssetLoader.on_fully_loaded.connect(_on_asset_loader_fully_loaded)
    AssetLoader.on_started.connect(_on_asset_loader_started)

func _exit_tree() -> void:
    AssetLoader.on_loaded_asset.disconnect(_on_asset_loader_loaded_asset)
    AssetLoader.on_progress_update.disconnect(_on_asset_loader_progress_update)
    AssetLoader.on_fully_loaded.disconnect(_on_asset_loader_fully_loaded)
    AssetLoader.on_started.disconnect(_on_asset_loader_started)

func _on_asset_loader_progress_update(percentage: float, _current_index: int, _max_index: int) -> void:
    progress_bar.value = percentage
    progress_bar.max_value = 1.0

func _on_asset_loader_loaded_asset(loaded_asset: String) -> void:
    loading_text.text = "Loaded %s" % loaded_asset

func _on_asset_loader_fully_loaded() -> void:
    visible = false

func _on_asset_loader_started() -> void:
    visible = true
    progress_bar.value = 0.0
    loading_text.text = "Loading assets..."
