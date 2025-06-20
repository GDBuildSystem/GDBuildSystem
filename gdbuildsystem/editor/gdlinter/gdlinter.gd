class_name GDLinter

var _resource_path: String
var _modified_lines: Dictionary[int, GDScriptProperty] = {}
var _modified_line_keys: Dictionary[String, int] = {}
var _inject_lines: Dictionary[int, GDScriptProperty] = {}
var _last_variable_line: int = 0

## Sets the current resource path to look at.
func load(resource_file: String) -> void:
    _modified_lines.clear()
    _resource_path = resource_file
    var file: FileAccess = FileAccess.open(_resource_path, FileAccess.READ)
    if file:
        var content: String = file.get_as_text()
        var content_lines: PackedStringArray = content.split("\n")
        file.close()
        for i in range(content_lines.size()):
            var line: String = content_lines[i]

            # Skips lines that are not variable declarations at the class level.
            if not (line.begins_with("var ") or line.begins_with("const ") or line.begins_with("@export ")):
                continue

            # var identifier: Type = value
            # var identifier: Type
            # var identifier
            # var identifier := value
            # var identifier:=value
            # var identifier:Type=value
            var property_name: String = ""
            var property_value: Variant
            var property_is_exported: bool = line.begins_with("@export ")
            line = line.strip_edges().replace("@export ", "") # Remove the @export keyword if it exists. We can add it later.
            var property_is_const: bool = line.begins_with("const ")
            line = line.replace("const ", "") # Remove the const keyword if it exists. We can add it later.
            line = line.replace("var ", "") # Remove the var keyword.
            var parts: PackedStringArray = line.split("=", true, 2) # Split the line into two parts: the variable name and the value.
            var variable_declaration: String = parts[0].strip_edges() # The variable declaration is the first part.
            var variable_parts: PackedStringArray = variable_declaration.split(":") # Split the variable declaration into parts by the colon.
            property_name = variable_parts[0].strip_edges() # The property name is the first part.
            var value: String = parts[1].strip_edges() if parts.size() > 1 else "" # The value is the second part, if it exists.
            property_value = JSON.parse_string(value) # Parse the value as JSON to get the correct type.

            _last_variable_line = i
            _modified_lines[i] = GDScriptProperty.new(property_name, typeof(property_value), property_value, property_is_exported, property_is_const)
            _modified_line_keys[property_name] = i

## Returns the source code of the GDScript that has been modified.
func build() -> String:
    # Re-open the file, read it's contents, and replace the modified lines with the new values.
    var file: FileAccess = FileAccess.open(_resource_path, FileAccess.READ)
    if not file:
        return "" # If the file does not exist, return an empty string.
    var content: String = file.get_as_text()
    var content_lines: PackedStringArray = content.split("\n")
    file.close()
    for modified_line: int in _modified_lines.keys():
        if _inject_lines.has(modified_line):
            continue
        var property: GDScriptProperty = _modified_lines[modified_line]
        content_lines[modified_line] = property._to_string()
    for insert_line: int in _inject_lines.keys():
        var property: GDScriptProperty = _inject_lines[insert_line]
        var line: String = property._to_string()
        content_lines.insert(insert_line, line)
    return "\n".join(content_lines)

## Returns a property inside the GDScript, if available.
func get_property(name: String) -> Variant:
    if _modified_line_keys.has(name):
        var line_number: int = _modified_line_keys[name]
        if _modified_lines.has(line_number):
            return _modified_lines[line_number].value
    return null

func has_property(name: String) -> bool:
    if _modified_line_keys.has(name):
        var line_number: int = _modified_line_keys[name]
        return _modified_lines.has(line_number)
    return false

func get_property_type(name: String) -> int:
    if _modified_line_keys.has(name):
        var line_number: int = _modified_line_keys[name]
        if _modified_lines.has(line_number):
            return _modified_lines[line_number].type
    # If the property does not exist, return nil.
    push_warning("GDLinter: Property '%s' does not exist." % name)
    return Variant.Type.TYPE_NIL

func get_property_type_str(name: String) -> String:
    return type_string(get_property_type(name))

func set_property(name: String, value: Variant, bypass_prevent_new: bool = false) -> GDScriptProperty:
    if _modified_line_keys.has(name):
        var line_number: int = _modified_line_keys[name]
        _modified_lines[line_number].set_value(value)
        return _modified_lines[line_number]
    
    # Check if we want to inject a new property- consider this dangerous.
    if not bypass_prevent_new:
        push_warning("GDLinter: Property '%s' does not exist. Use 'bypass_prevent_new' to create a new property." % name)
        return GDScriptProperty.new(name, Variant.Type.TYPE_NIL, null, false, false) # Fake data, prevents crashes.

    # Inject a new property.
    var property_type: int = typeof(value)
    var property: GDScriptProperty = GDScriptProperty.new(name, property_type, value, false, false)
    _last_variable_line += 1
    _inject_lines[_last_variable_line] = property
    _modified_lines[_last_variable_line] = property
    _modified_line_keys[name] = _last_variable_line
    return property

func get_properties() -> PackedStringArray:
    var properties: PackedStringArray = []
    for line_number in _modified_lines.keys():
        properties.append(_modified_lines[line_number].name)
    return properties

class GDScriptProperty:
    var name: String
    var type: int
    var value: Variant
    var is_exported: bool = false
    var is_const: bool = false

    func _init(name: String, type: int, value: Variant, is_exported: bool = false, is_const: bool = false) -> void:
        self.name = name
        self.type = type
        self.value = value
        self.is_exported = is_exported
        self.is_const = is_const
        print("Created GDScriptProperty: [%s] %s = %s" % [type_string(type), name, value])
    
    func set_value(value: Variant) -> GDScriptProperty:
        self.value = value
        self.type = typeof(value)
        return self

    func set_exported(is_exported: bool) -> GDScriptProperty:
        self.is_exported = is_exported
        return self
    
    func set_const(is_const: bool) -> GDScriptProperty:
        self.is_const = is_const
        return self

    func _to_string() -> String:
        var property_string: String
        if is_exported:
            property_string = "@export "
        if is_const:
            property_string += "const "
        else:
            property_string += "var "
        property_string += "%s: %s" % [name, type_string(type)]
        property_string += " = %s" % JSON.stringify(value)
        print("Property string: [%s] %s = %s -> `%s`" % [type_string(type), name, value, property_string])
        return property_string.strip_edges()