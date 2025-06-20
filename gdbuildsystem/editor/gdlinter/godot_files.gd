class_name GodotFiles
extends RefCounted

const BACKUP_PATH: String = "res://addons/gdbuildsystem/godot_files.backup"

var _files: Dictionary[String, ExportFile] = {}

func clear() -> void:
    _files.clear()

func flush() -> void:
    # Create a backup for all files
    var backups: Dictionary
    for path in _files:
        backups[path] = _files[path].source
    var backup_file := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
    backup_file.store_var(backups)
    backup_file.close()
    
    for path in _files:
        var file := FileAccess.open(path, FileAccess.WRITE)
        file.store_buffer(_files[path].export )
        file.close()

func restore() -> void:
    for path in _files:
        var file := FileAccess.open(path, FileAccess.WRITE)
        file.store_buffer(_files[path].source)
        file.close()
    
    # Delete backup after having successfully restored all files
    if FileAccess.file_exists(BACKUP_PATH):
        DirAccess.remove_absolute(BACKUP_PATH)

func edit_emplace(path: String, export: String) -> void:
    edit_buffer(path, FileAccess.get_file_as_bytes(path), export.to_utf8_buffer())
func edit(path: String, source: String, export: String) -> void:
    edit_buffer(path, source.to_utf8_buffer(), export.to_utf8_buffer())

func edit_buffer(path: String, source: PackedByteArray, export: PackedByteArray) -> void:
    _files[path] = ExportFile.new(source, export )

class ExportFile:
    var source: PackedByteArray
    var export: PackedByteArray
    
    func _init(source: PackedByteArray, export: PackedByteArray) -> void:
        self.source = source
        self.export = export