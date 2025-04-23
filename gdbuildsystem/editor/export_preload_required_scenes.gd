## Export Preload Required Scenes is a plugin that allows us to know what scenes need to be preloaded before loading anything else.
## - This will modify a Runtime script file allowing the developer to load these scenes individually and cache them into the Godot Engine's Cache.
class_name EditorExportPreloadRequiredScenes
extends EditorExportPlugin

func _export_file(path: String, type: String, features: PackedStringArray) -> void:
    if not path.ends_with(".tscn") and not path.ends_with(".scn"):
        return # Ignore this file, we aren't gonna try to figure it out.
        
    # Try to figure out the scene.
    var packedScene: PackedScene = load(path)
    var scene: Node = packedScene.instantiate()
    
    if _has_preloadable_nodes(scene):
        print("Preloadable Scene: %s" % path)
    else:
        print("Not Preloadable Scene: %s" % path)
    
    scene.free()

func _has_preloadable_nodes(root: Node) -> bool:
    if root is CPUParticles2D:
        return true
    if root is CPUParticles3D:
        return true
    if root is GPUParticles2D:
        return true
    if root is GPUParticles3D:
        return true
    if root is Node2D:
        if root.material != null or root.use_parent_material:
            return true
    if root is Node3D:
        if root.material != null:
            return true
    for child: Node in root.get_children():
        return _has_preloadable_nodes(child)
    return false

func _get_name() -> String:
    return "Export Preload Required Scenes"
