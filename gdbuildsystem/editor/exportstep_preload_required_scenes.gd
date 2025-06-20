## Export Preload Required Scenes is a plugin that allows us to know what scenes need to be preloaded before loading anything else.
## - This will modify a Runtime script file allowing the developer to load these scenes individually and cache them into the Godot Engine's Cache.
class_name GDBuildExportStep_Preloads
extends ExportStep

const FEATURE_NO_PRELOADS: String = "no_preloads"

func next_file(path: String, type: String) -> FileResult:
    if not path.ends_with(".tscn") and not path.ends_with(".scn"):
        return FileResult.EXPORT # Ignore this file, we aren't gonna try to figure it out.

    # Check if the file is in the ignore directories.
    for ignore_dir: String in settings.preloads_ignore_directories:
        if path.contains(ignore_dir):
            if settings.preloads_debug:
                print("Ignored Preloadable Scene: %s" % path)
            return FileResult.EXPORT # Ignore this file, we aren't gonna try to figure it out.
    
    # Try to figure out the scene.
    var packedScene: PackedScene = load(path)
    var scene: Node = packedScene.instantiate()
    if _has_preloadable_nodes(scene, scene, path):
        print("Preloadable Scene: %s" % path)
    elif settings.preloads_debug:
        print("Not Preloadable Scene: %s" % path)
    
    scene.free()
    return FileResult.EXPORT

func _has_preloadable_nodes(root: Node, scene_root: Node, scene_path: String) -> bool:
    # Particles we always want to preload, their materials can be expensive to load, 
    #  especially they are immediately needed.
    if root is CPUParticles2D:
        if settings.preloads_debug:
            print("Preloadable CPUParticles2D: [%s] %s" % [root.name, scene_root.get_path_to(root)])
        return true
    if root is CPUParticles3D:
        if settings.preloads_debug:
            print("Preloadable CPUParticles3D: [%s] %s" % [root.name, scene_root.get_path_to(root)])
        return true
    if root is GPUParticles2D:
        if settings.preloads_debug:
            print("Preloadable GPUParticles2D: [%s] %s" % [root.name, scene_root.get_path_to(root)])
        return true
    if root is GPUParticles3D:
        if settings.preloads_debug:
            print("Preloadable GPUParticles3D: [%s] %s" % [root.name, scene_root.get_path_to(root)])
        return true
    # Load custom materials and shaders, this is required so we can have the GPU Renderer build render pipelines for them and cache them.
    if root is GeometryInstance3D:
        var geo: GeometryInstance3D = root as GeometryInstance3D
        if geo.material_overlay != null:
            if settings.preloads_debug:
                print("Preloadable Overlay-Material: [%s] %s" % [root.name, scene_root.get_path_to(root)])
            return true
        if geo.material_override != null:
            if settings.preloads_debug:
                print("Preloadable Override-Material: [%s] %s" % [root.name, scene_root.get_path_to(root)])
            return true
    if root is MeshInstance3D:
        var mesh: MeshInstance3D = root as MeshInstance3D
        if mesh.mesh != null:
            if mesh.mesh is PrimitiveMesh:
                var primitiveMesh: PrimitiveMesh = mesh.mesh as PrimitiveMesh
                if primitiveMesh.material != null:
                    if settings.preloads_debug:
                        print("Preloadable Primitive-Material: [%s] %s" % [root.name, scene_root.get_path_to(root)])
                    return true
            if mesh.mesh.get_surface_count() > 0:
                for i in range(mesh.mesh.get_surface_count()):
                    var material: Material = mesh.mesh.surface_get_material(i)
                    if material != null:
                        if settings.preloads_debug:
                            print("Preloadable Surface-Material: [%s] %s" % [root.name, scene_root.get_path_to(root)])
                        return true
    if settings.preloads_recursive_lookup:
        for child: Node in root.get_children():
            return _has_preloadable_nodes(child, scene_root, scene_path)
    return false

func _override_can_run() -> bool:
    return settings.preloads_enabled
func _override_feature_requirements() -> PackedStringArray:
    return [] # This step requires the no_preloads feature to be disabled.
func _override_feature_exclusions() -> PackedStringArray:
    return [FEATURE_NO_PRELOADS, "dedicated_server"] # This step should not run on dedicated servers.

func _get_name() -> String:
    return "Preload Required Collector"