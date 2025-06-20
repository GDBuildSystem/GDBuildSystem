class_name SceneLoader
extends Node

signal on_scene_change(new_scene: String)

@export_file("*.tscn") var packed_scene: String

@export var override_scene: bool = false
@export var world: Node

@export var autoload: bool = true

var _scene_node: Node

func _ready() -> void:
    if packed_scene == null:
        print("SceneLoader: No packed scene assigned.")
        return
    if autoload:
        await change_scenes(packed_scene)

func _exit_tree() -> void:
    pass

func _on_change_scene(scene_path: String) -> void:
    on_scene_change.emit(scene_path)

func change_scenes(scene_path: String) -> void:
    if not ResourceLoader.exists(scene_path):
        return
    
    # Clear nodes under the world node.
    if is_instance_valid(world):
        for child: Node in world.get_children():
            if child != self:
                child.queue_free()

    AssetLoader.load_path(scene_path)
    
    await AssetLoader.on_fully_loaded

    var _packed_scene: PackedScene = AssetLoader.get_asset(scene_path)

    # Now lets instantiate the packed scene
    if _packed_scene == null:
        printerr("Failed to load the packed scene correctly...")
        return
    if override_scene and world == null:
        var err: int = get_tree().change_scene_to_packed(_packed_scene)
        if err != OK:
            printerr("Failed to change scene to packed scene: %s - %s" % [_packed_scene.resource_name, error_string(err)])
            return
    else:
        if world == null:
            world = get_tree().root
        
        var instance: Node = _packed_scene.instantiate()
        if instance == null:
            printerr("Failed to instantiate the packed scene.")
            return
        
        # Add the instance to the current scene
        world.add_child(instance)
        _packed_scene = null
        _scene_node = instance
