@tool
class_name EditorBundlerExportPlugin
extends EditorExportPlugin

const FEATURE_NO_BUNDLES: String = "no_bundles"

static var settings: BuildSystemSettings:
    get():
        if settings == null:
            settings = BuildSystemSettings.new()
        return settings
static var bundles: Dictionary[String, PackedStringArray] = {}
static var output_directory: String
static var absolute_path_to_builtbundledata: String
static var original_builtbundledata_script: String

func _export_begin(features: PackedStringArray, is_debug: bool, executable_filepath: String, flags: int) -> void:
    var build_path: String = executable_filepath.get_base_dir()
    output_directory = "%s/%s" % [build_path, settings.export_directory]
    
    absolute_path_to_builtbundledata = ProjectSettings.globalize_path("res://addons/gdbuildsystem/runtime/BuiltBundleData.gd")
    
    # Pre-emptly get the bundles list.
    var absolute_path_to_resource_directory: String = ProjectSettings.globalize_path(settings.resource_directory)
    if not DirAccess.dir_exists_absolute(absolute_path_to_resource_directory):
        push_error("Bundle Resource Directory doesn't exist: `%s` -> `%s`" % [settings.resource_directory, absolute_path_to_resource_directory])
        return
    var bundles: PackedStringArray = DirAccess.get_directories_at(absolute_path_to_resource_directory)
    var bundle_hashes: PackedInt64Array = [123]
    
    # Now we bake the "BuiltBundleData.gd" file to have all the necessary data.
    # - This doesn't full-proof prevent exploiting installations. When a user installs a mod that overrides our built bundles/pcks.
    #   We attempt to do a HASH check to verify the bundles are the same. A exploiter can modify the executable, completely negating this security measure.
    _bake_builtbundledata(bundles, bundle_hashes)

# This plugin is responsible for creating PCK Bundle Files for each subdirectory of the designated Bundles directory.
func _export_file(path: String, type: String, features: PackedStringArray) -> void:
    if features.has(FEATURE_NO_BUNDLES):
        return # Skip export if the no_bundles feature is enabled
    if not path.contains(settings.resource_directory):
        return
    var file_type: String = path.get_extension()
    var bundle_file_path: String = path.replace(settings.resource_directory + "/", "")
    var bundle_name: String = bundle_file_path.split("/")[0]
    var promitted_file_types: PackedStringArray = settings.promitted_resources_types
    if not promitted_file_types.has(file_type):
        push_warning("[%s] " % bundle_name, "Cannot pack prohibited file type: %s " % bundle_file_path, "(Allowed Types: %s - and not: %s)" % [",".join(promitted_file_types), file_type])
        skip() # We don't want to add this file into the base PCK of the game.
        return # We also don't want this to go into a Bundle PCK.
    if not bundles.has(bundle_name):
        bundles[bundle_name] = PackedStringArray()
    # Bundles collect the full path to the file.
    bundles[bundle_name].append(path)
    if settings.enabled_debug:
        print("[%s] " % bundle_name, "Packing %s - %s" % [type, bundle_file_path])
    skip() # We don't want to add this to the base PCK, instead it was added to the Bundle PCK files.

# Now we build all the PCK bundles out, and reset the built script.
func _export_end() -> void:
    _revert_builtbundledata()
    
    # Create necessary directories.
    if not DirAccess.dir_exists_absolute(output_directory):
        var err: Error = DirAccess.make_dir_recursive_absolute(output_directory)
        if err != OK:
            push_error("Failed to create recursive absolute directory: %s" % output_directory)
            assert(false, "Build Failed.")
            return 
    
    for bundle_name: String in bundles.keys():
        var output_bundle_path: String = "%s/%s.pck" % [output_directory, bundle_name]
        var bundle_files: PackedStringArray = bundles[bundle_name]
        var bundle_pack: PCKPacker = PCKPacker.new()
        var error_start: Error
        if settings.encrypt_bundles:
            error_start = bundle_pack.pck_start(output_bundle_path, 32, OS.get_environment("SCRIPT_AES256_ENCRYPTION_KEY"), settings.bundles_encrypt_directories)
        else:
            error_start = bundle_pack.pck_start(output_bundle_path)
        if error_start != OK:
            push_error("Failed to Start Bundle[%s]...\n\t%s" % [bundle_name, error_string(error_start)])
            assert(false, "Build Failed.")
            break
        for file_path: String in bundle_files:
            var err: Error = bundle_pack.add_file(file_path, file_path)
            if err != OK:
                push_error("Bundle Failed Packing[%s]: %s\n\t%s" % [bundle_name, file_path, error_string(err)])
                assert(false, "Build Failed.")
                break
            elif settings.enabled_debug:
                print("Bundle Packing[%s]: %s" % [bundle_name, file_path])
        print("Building Bundle[%s]: %s" % [bundle_name, output_bundle_path])
        var error_flush = bundle_pack.flush(settings.enabled_debug)
        if error_flush != OK:
            push_error("Bundle Failed to Build[%s]...\n\t%s" % [bundle_name, error_string(error_flush)])
            assert(false, "Build Failed.")
            break
    if settings.enabled_debug:
        print(original_builtbundledata_script)

func _get_name() -> String:
    return "Export Builder Plugin"

## We edit the "BuiltBundleData.gd" file inside this addon, so we can bake in the bundles that are going to be used by the this project.
func _bake_builtbundledata(bundles: PackedStringArray, bundle_hashes: PackedInt64Array) -> void:
    
    var file: FileAccess = FileAccess.open(absolute_path_to_builtbundledata, FileAccess.READ_WRITE)
    assert(file != null, "BuiltBundleData.gd doesn't exist!")
    original_builtbundledata_script = file.get_as_text()
    file.close()
    
    # Here we modify the script virtually.
    var modified_lines: PackedStringArray = []
    var lines: PackedStringArray = original_builtbundledata_script.split("\n")
    for line: String in lines:
        if line.begins_with("const BUNDLE_PATH: String ="):
            modified_lines.append("const BUNDLE_PATH: String = \"%s\"" % settings.export_directory)
        elif line.begins_with("const BUILT_BUNDLES: PackedStringArray ="):
            modified_lines.append("const BUILT_BUNDLES: PackedStringArray = " + JSON.stringify(bundles))
        elif settings.bake_bundle_hashes and line.begins_with("const BUILT_BUNDLES_HASHES: PackedInt64Array ="):
            modified_lines.append("const BUILT_BUNDLES_HASHES: PackedInt64Array = " + JSON.stringify(bundle_hashes))
        elif line.begins_with("const THREAD_BUNDLE_LOADING: bool ="):
            var value: String = "false"
            if settings.thread_bundles_loading:
                value = "true"
            modified_lines.append("const THREAD_BUNDLE_LOADING: bool = " + value)
        else:
            modified_lines.append(line)
    var modified_script: String = "\n".join(modified_lines)
    if settings.enabled_debug:
        print(modified_script)
    # Now we write to the script.
    file = FileAccess.open(absolute_path_to_builtbundledata, FileAccess.WRITE)
    file.store_string(modified_script)
    file.flush()
    file.close()

func _revert_builtbundledata() -> void:
    var file: FileAccess = FileAccess.open(absolute_path_to_builtbundledata, FileAccess.WRITE)
    file.store_string(original_builtbundledata_script)
    file.flush()
    file.close()
