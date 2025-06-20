@tool
class_name GDBuildExportStep_Bundles
extends ExportStep

const FEATURE_NO_BUNDLES: String = "no_bundles"

var bundles: Dictionary[String, PackedStringArray] = {}
var bundles_directory: String
var absolute_path_to_builtbundledata: String
var project_path: String = ProjectSettings.globalize_path("res://")
var imported_hashed_files: Dictionary[String, PackedStringArray] = {}

func begin() -> void:
    # Clear old memory.
    bundles.clear()
    imported_hashed_files.clear()

    bundles_directory = "%s/%s" % [output_path, settings.export_directory]
    
    absolute_path_to_builtbundledata = ProjectSettings.globalize_path("res://addons/gdbuildsystem/runtime/BuiltBundleData.gd")
    
    # Collect all the imported hashed files.
    var imported_directory: String = "%s/.godot/imported" % project_path
    if not DirAccess.dir_exists_absolute(imported_directory):
        push_error("Imported directory doesn't exist: %s" % imported_directory)
        assert(false, "Build Failed.")
        return
    for file: String in DirAccess.get_files_at(imported_directory):
        var filesplit: PackedStringArray = file.split("-")
        var true_file_name: String = "-".join(filesplit.slice(0, filesplit.size() - 1)) # The true file name is the file name without the hash after the last "-".
        if not imported_hashed_files.has(true_file_name):
            imported_hashed_files[true_file_name] = PackedStringArray()
        var localized_file: String = "res://.godot/imported/%s" % file.get_file()
        imported_hashed_files[true_file_name].append(localized_file)


    # We need to collect accurate bundle information, so we don't have a client load bundles that aren't built, and we may need to do hashing.
    var bundles_info: BundlesInfo = _get_bundles()

    # Now we bake the "BuiltBundleData.gd" file to have all the necessary data.
    # - This doesn't full-proof prevent exploiting installations. When a user installs a mod that overrides our built bundles/pcks.
    #   We attempt to do a HASH check to verify the bundles are the same. A exploiter can modify the executable, completely negating this security measure.
    _bake_builtbundledata(bundles_info.bundles, bundles_info.bundle_hashes)

# This plugin is responsible for creating PCK Bundle Files for each subdirectory of the designated Bundles directory.
func next_file(path: String, type: String) -> FileResult:
    if not path.contains(settings.resource_directory):
        return FileResult.EXPORT
    var file_type: String = path.get_extension()
    var bundle_file_path: String = path.replace(settings.resource_directory + "/", "")
    var bundle_name: String = bundle_file_path.split("/")[0]
    var promitted_file_types: PackedStringArray = []
    for setting_file_type: String in settings.permitted_resources_types: # Cleanup the file types to be all lowercase, otherwise we will have false-positives.
        if setting_file_type == "":
            continue
        promitted_file_types.append(setting_file_type.to_lower())
    if not promitted_file_types.has(file_type.to_lower()):
        push_warning("[%s] " % bundle_name, "Cannot pack prohibited file type: %s " % bundle_file_path, "(Allowed Types: %s - and not: %s)" % [",".join(promitted_file_types), file_type])
        return FileResult.SKIP # We also don't want this to go into a Bundle PCK.
    if not bundles.has(bundle_name):
        bundles[bundle_name] = PackedStringArray()
    # Bundles collect the full path to the file.
    bundles[bundle_name].append(path)

    # ----------------------------------------------------------------------------------------------------------------------------------------
    # OMG Godot. This is so stupid, adding just the file into the file to a designated bundle isn't enough. 
    #  You need to load the import file and the dependent imported files that get baked for specific file types.
    #  Maybe in the future, godot will figure out how they want to do PCKs in a more sane way. But for now, here's our nightmare response.
    # As of writing this, technically... modding is semi-possible, but not really. Ugh... 
    #  but this currently in working state for splitting up your content for easier downloads.
    # ---------------------------------------------------------------------------------------------------------------------------------------
    # Find the .import file, and add it to the bundle.
    var import_file_path: String = path + ".import"
    if FileAccess.file_exists(import_file_path):
        bundles[bundle_name].append(import_file_path)
        if settings.bundles_debug:
            print("[%s] " % bundle_name, "Packing %s - %s" % [type, import_file_path.get_file()])
    # Find the .godot/import files, and add them to the bundle.
    if imported_hashed_files.has(bundle_file_path.get_file()):
        for file: String in imported_hashed_files[bundle_file_path.get_file()]:
            if file == path:
                continue # Skip the original file, we don't want to add it to the bundle.
            bundles[bundle_name].append(file)
            if settings.bundles_debug:
                print("[%s] " % bundle_name, "Packing %s - %s" % [type, file])

    if settings.bundles_debug:
        print("[%s] " % bundle_name, "Packing %s - %s" % [type, bundle_file_path])
    return FileResult.SKIP

# Now we build all the PCK bundles out, and reset the built script.
func end() -> void:
    # Create necessary directories.
    if not DirAccess.dir_exists_absolute(bundles_directory):
        var err: Error = DirAccess.make_dir_recursive_absolute(bundles_directory)
        if err != OK:
            push_error("Failed to create recursive absolute directory: %s" % bundles_directory)
            assert(false, "Build Failed.")
            return
    
    # Grab the encryption key from the environment variable or the .godot/export_credentials.cfg file.
    var encryption_key: String = OS.get_environment("SCRIPT_AES256_ENCRYPTION_KEY")
    if settings.bundles_encrypt:
        if encryption_key == "":
            # Lets' try hijacking the .godot/export_credentials.cfg file.
            var config_file: FileAccess = FileAccess.open(".godot/export_credentials.cfg", FileAccess.READ)
            if config_file == null:
                push_error("Failed to open .godot/export_credentials.cfg file.")
                assert(false, "Build Failed.")
                return
            var config_file_text: String = config_file.get_as_text()
            config_file.close()
            var lines: PackedStringArray = config_file_text.split("\n")
            for line: String in lines:
                if line.begins_with("script_encryption_key="):
                    var result: Variant = JSON.parse_string(line.split("=")[1].strip_edges())
                    if result is String:
                        if not result.is_empty():
                            encryption_key = result
                            break
        # We failed to get the encryption key, so we can't encrypt the bundle.
        if encryption_key == "":
            push_error("Bundle Encryption Key not set in environment variable: SCRIPT_AES256_ENCRYPTION_KEY")
            assert(false, "Build Failed.")
            return

    # Iterate over the bundles and pack them.
    for bundle_name: String in bundles.keys():
        if bundles[bundle_name].size() == 0:
            continue # Skip empty bundles.
        var output_bundle_path: String = "%s/%s.pck" % [bundles_directory, bundle_name]
        var bundle_files: PackedStringArray = bundles[bundle_name]
        var bundle_pack: PCKPacker = PCKPacker.new()
        var error_start: Error
        if settings.bundles_encrypt:
            error_start = bundle_pack.pck_start(output_bundle_path, 32, encryption_key, settings.bundles_encrypt_directories)
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
            elif settings.bundles_debug:
                print("Bundle Packing[%s]: %s" % [bundle_name, file_path])
        if settings.bundles_debug:
            print("Building Bundle[%s]: %s" % [bundle_name, output_bundle_path])
        var error_flush = bundle_pack.flush(settings.bundles_flush_verbosity)
        if error_flush != OK:
            push_error("Bundle Failed to Build[%s]...\n\t%s" % [bundle_name, error_string(error_flush)])
            assert(false, "Build Failed.")
            break
        print("Bundle[%s] Built: %s" % [bundle_name, output_bundle_path])

class BundlesInfo:
    var bundles: PackedStringArray
    var bundle_hashes: PackedInt64Array

func _get_bundles() -> BundlesInfo:
    var absolute_path_to_resource_directory: String = ProjectSettings.globalize_path(settings.resource_directory)
    if not DirAccess.dir_exists_absolute(absolute_path_to_resource_directory):
        push_error("Bundle Resource Directory doesn't exist: `%s` -> `%s`" % [settings.resource_directory, absolute_path_to_resource_directory])
        return
    
    const CHUNK_SIZE: int = 1024
    var info: BundlesInfo = BundlesInfo.new()

    for bundle_directory: String in DirAccess.get_directories_at(absolute_path_to_resource_directory):
        var files: PackedStringArray = _walk_directory_files("%s/%s" % [absolute_path_to_resource_directory, bundle_directory])
        if files.size() == 0:
            continue # Skip empty directories.
        info.bundles.append(bundle_directory)

        # Now we handle hashing the bundles, this is important for security reasons.
        #  We can use this to essentially verify the client has current bundles, and not some modded ones.
        #  Super important, when you have a dedicated game server that can verify the client has the correct bundles.
        #  Not entirely fool-proof, a modder can attempt to fake your hashes by modifying the executable, but in a active development, 
        #  the bundle hashes should be changing enough to prevent the modder for short durations.
        if not settings.bundles_bake_hashes:
            continue # We don't need to hash the files, so skip this.
        for file: String in files:
            # We need to hash the file, so how we do that is via this HashingContext class which allows us to stream the file in, instead of loading it all into memory.
            # This is important for large files, as we don't want to load them all into memory.
            var hasher: HashingContext = HashingContext.new()
            hasher.start(HashingContext.HASH_MD5)
            var file_handle: FileAccess = FileAccess.open(file, FileAccess.READ)
            if file_handle == null:
                push_error("Failed to open file: %s" % file)
                continue
            while file_handle.get_position() < file_handle.get_length():
                var remaining_chunk: int = file_handle.get_length() - file_handle.get_position()
                hasher.update(file_handle.get_buffer(mini(remaining_chunk, CHUNK_SIZE)))
            file_handle.close()
            var digest: PackedByteArray = hasher.finish()
            var stream: StreamPeerBuffer = StreamPeerBuffer.new()
            stream.data_array = digest
            stream.seek(0)
            var hash: int = stream.get_64()
            info.bundle_hashes.append(hash)
    return info

func _walk_directory_files(path: String) -> PackedStringArray:
    var files: PackedStringArray = []
    var dir: DirAccess = DirAccess.open(path)
    if dir == null:
        push_error("Failed to open directory: %s" % path)
        return files
    dir.list_dir_begin()
    while true:
        var file_name: String = dir.get_next()
        if file_name == "":
            break
        if dir.current_is_dir():
            files.append_array(_walk_directory_files("%s/%s" % [path, file_name]))
        else:
            files.append("%s/%s" % [path, file_name])
    dir.list_dir_end()
    return files

## We edit the "BuiltBundleData.gd" file inside this addon, so we can bake in the bundles that are going to be used by the this project.
func _bake_builtbundledata(bundles: PackedStringArray, bundle_hashes: PackedInt64Array) -> void:
    print("Bundle Path: %s" % settings.export_directory)
    print("Bundle Bake Hashes: %s" % settings.bundles_bake_hashes)
    print("Bundle Hashes: %s" % bundle_hashes)
    print("Bundle Names: %s" % bundles)
    print("Bundle Encrypt: %s" % settings.bundles_encrypt)
    print("Bundle Encrypt Directories: %s" % settings.bundles_encrypt_directories)
    print("Bundle Thread Loading: %s" % settings.bundles_thread_loading)

    # Here we modify the script virtually.
    var linter: GDLinter = GDLinter.new()
    linter.load(absolute_path_to_builtbundledata)
    linter.set_property("BUNDLE_PATH", settings.export_directory)
    linter.set_property("BUILT_BUNDLES", bundles)
    linter.set_property("BUILT_BUNDLES_HASHES", bundle_hashes)
    linter.set_property("THREAD_BUNDLE_LOADING", settings.bundles_thread_loading)
    linter.set_property("BUNDLES_DEBUG", settings.bundles_debug, true).set_const(true)

    var modified_script: String = linter.build()
    godot_files.edit_buffer(absolute_path_to_builtbundledata, FileAccess.get_file_as_bytes(absolute_path_to_builtbundledata), modified_script.to_utf8_buffer())

func _override_feature_exclusions() -> PackedStringArray:
    return ["dedicated_server", FEATURE_NO_BUNDLES]
func _override_feature_requirements() -> PackedStringArray:
    return []
func _override_can_run() -> bool:
    return settings.bundles_enabled

func _get_name() -> String:
    return "Bundles Packager"