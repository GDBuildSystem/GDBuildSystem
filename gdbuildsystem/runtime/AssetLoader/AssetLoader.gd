extends Node

class ThreadedAsset:
    var path: String
    var progress: float = 0.0
    var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS
    var result: Variant = null
    var callable: Callable
    var started: bool = false
    
    func _noop() -> void:
        pass
    
    func _init(_path: String, _callable: Callable = _noop) -> void:
        path = _path
        callable = _callable
    
    func start() -> void:
        if started:
            return
        started = true
        ResourceLoader.load_threaded_request(path)

    func update() -> void:
        if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
            if result != null:
                progress = 1.0
            return # We are no longer in progress.
        var _progress: Array = []
        status = ResourceLoader.load_threaded_get_status(path, _progress)
        if _progress.size() > 0:
            var next_progress: float = _progress[0]
            progress = maxf(progress, next_progress)
        if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
            result = ResourceLoader.load_threaded_get(path)
        # var status_str: String = "Unknown"
        # match status:
        #     ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
        #         status_str = "Failed"
        #     ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
        #         status_str = "Invalid Resource"
        #     ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
        #         status_str = "In Progress"
        #     ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
        #         status_str = "Loaded"
        # print("Loading Resource: %s [%s - %s]" % [path, progress, status_str])
        # if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
        #     print("Finished loading resource: %s (%s)" % [path, result])
        
signal on_inform_needs(loader: AssetLoader)
signal on_progress_update(percentage: float, current_index: int, max_index: int)
signal on_loaded_asset(loaded_asset: String)
signal on_start_fully_loaded()
signal on_fully_loaded()
signal on_started()


@export var fully_loaded_count_down: float = 2.0 # in seconds
@export var deferred_start_time: float = 2.5 # in seconds
#@export var delete_after_completion: float = 0.5 # in seconds
@export var debug: bool = false

var runtime_settings: BuildSystemRuntimeSettings:
    get():
        if runtime_settings == null:
            runtime_settings = BuildSystemRuntimeSettings.new()
        return runtime_settings

var AssetLoaderScene: PackedScene = null:
    get():
        if AssetLoaderScene == null:
            AssetLoaderScene = runtime_settings.loading_screen_scene
            if AssetLoaderScene == null:
                push_error("AssetLoaderScene is not set! Please ensure the loading screen scene is set in the project settings.")
        return AssetLoaderScene
static var asset_loader_visual: CanvasLayer = null

var _max_items: PackedStringArray = []
var _threaded_items: Dictionary[String, ThreadedAsset] = {}
var _loaded_items: PackedStringArray = []
var _queue_loaded_items: PackedStringArray = []
var _count_down: float = fully_loaded_count_down
var _is_loaded: bool = false
var _deferred_countdown: float = deferred_start_time

func _ready() -> void:
    _deferred_needs.call_deferred()

    asset_loader_visual = AssetLoaderScene.instantiate()
    if asset_loader_visual != null:
        asset_loader_visual.visible = false # Hide the visual by default.
        add_child(asset_loader_visual)
        asset_loader_visual.name = "AssetLoaderVisual"

func _deferred_needs() -> void:
    on_inform_needs.emit(self)

func _process(delta: float) -> void:
    if _deferred_countdown > 0.0:
        _deferred_countdown -= delta
        return
    _handle_asset_loading()
    _handle_item_loading(delta)
    _update_progress()

func _handle_asset_loading() -> void:
    var remove_items: Array[String] = []
    for item: String in _threaded_items:
        var asset: ThreadedAsset = _threaded_items[item]
        if asset.started == false:
            asset.start()
        var was_loading: bool = asset.status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS
        asset.update()
        if asset.status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS and was_loading:
            var status_str: String = "Unknown"
            match asset.status:
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
                    status_str = "Failed"
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
                    status_str = "Invalid Resource"
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
                    status_str = "In Progress"
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
                    status_str = "Loaded"
            if asset.status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
                _handle_finished_asset(asset.path)
                remove_items.append(asset.path)
                if asset.callable != null and asset.callable.get_argument_count() == 1:
                    asset.callable.call(asset.result)
                elif asset.callable != null:
                    push_error("Cannot call Asset Callable: %s" % asset.callable.get_method())
            else:
                push_error("An error happened while loading a Threaded Asset: %s [%s]" % [asset.path, status_str])

func _handle_item_loading(delta: float) -> void:
    # Atomically grab the items.
    var loading_items: PackedStringArray = []
    for asset: String in _queue_loaded_items:
        if not _max_items.has(asset):
            push_error("Handled a finished loading asset that was not apart of the expected asset loading: %s" % asset)
            continue
        loading_items.append(asset)
    
    # Remove the items that we see this frame.
    for asset: String in loading_items:
        var indx: int = _queue_loaded_items.find(asset)
        if indx == -1:
            continue
        _queue_loaded_items.remove_at(indx)
    
    # Communicate that we loaded these items...
    for asset: String in loading_items:
        _loaded_items.append(asset)
        on_loaded_asset.emit(asset)
        if OS.has_feature("debug") and debug:
            print("Loaded Asset: %s [%s / %s]" % [asset, _loaded_items.size(), _max_items.size()])
        _update_progress()
    
    # Start and Stop the ticking down before we call that we are done here.
    if _loaded_items.size() == _max_items.size():
        if _count_down == fully_loaded_count_down:
            on_start_fully_loaded.emit()
            if OS.has_feature("debug") and debug:
                print("Started Counting down to finished!")
        _count_down -= delta
        if _count_down <= 0.0 and not _is_loaded:
            # if OS.has_feature("debug") and debug:
            print("Finished loading: %s" % _max_items)
            on_fully_loaded.emit()
            _is_loaded = true

            _loaded_items.clear() # Clear the loaded items.
            _max_items.clear() # Clear the max items.
            _threaded_items.clear() # Clear the threaded items.
            _queue_loaded_items.clear() # Clear the queue loaded items.
    elif not _is_loaded: # Reset the count-down everytime it is no longer the max == loaded and is still not loaded.
        _count_down = fully_loaded_count_down

func _handle_finished_asset(asset: String) -> void:
    if _queue_loaded_items.has(asset):
        return # Ignore!
    if _is_loaded:
        push_warning("Attempting to load assets while the Asset Loader is considered finished!")
        return # Ignored!
    _queue_loaded_items.append(asset)

func _on_inform_to_load_asset(path: String) -> void:
    load_path(path)

static func noop(_result: Variant) -> void:
    # This is a no-op function that can be used as a callable.
    pass

func get_asset(path: String) -> Variant:
    if OS.has_feature("debug") and path.begins_with("uid://"):
        path = ResourceUID.get_id_path(ResourceLoader.get_resource_uid(path))
    if not _threaded_items.has(path):
        push_error("Attempting to get an asset that is not loaded: %s" % path)
        return null
    if _threaded_items[path].status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
        push_error("Attempting to get an asset that is not loaded yet: %s" % path)
        return null
    if _threaded_items[path].result == null:
        push_error("Attempting to get an asset that is not loaded yet or an error occured: %s" % path)
        return null
    return _threaded_items[path].result

func load(resource: Resource, callable: Callable = noop) -> void:
    load_path(resource.resource_path, callable)

func load_path(expected_string: String, callable: Callable = noop) -> void:
    if _max_items.has(expected_string):
        return # Ignore!

    if OS.has_feature("debug") and expected_string.begins_with("uid://"):
        expected_string = ResourceUID.get_id_path(ResourceLoader.get_resource_uid(expected_string))

    if _max_items.size() == 0:
        print("Asset Loader: Starting to load assets...")
        on_started.emit() # Emit that we have started loading assets.
        _is_loaded = false
        if asset_loader_visual != null:
            asset_loader_visual.visible = true # Show the asset loader visual.
        
    if _is_loaded:
        push_warning("Attempting to add needed assets while the Asset Loader is considered finished!")
        return # Ignored!
    
    _max_items.append(expected_string)
    
    if OS.has_feature("debug") and debug:
        print("Added Expected Asset Resource To Be loaded: %s" % expected_string)
    if ResourceLoader.exists(expected_string): # If this is a resource file that we can asynchronously load, then we will.
        _threaded_items[expected_string] = ThreadedAsset.new(expected_string, callable)
        
        if OS.has_feature("debug") and debug:
            print("\tAdded Threaded Resource: %s" % expected_string)
    else:
        if OS.has_feature("debug") and debug:
            print("\tAdded Non-Threaded Resource: %s" % expected_string)
    
    _update_progress()

func _update_progress() -> void:
    var total_progress: float = 0
    for item: ThreadedAsset in _threaded_items.values():
        total_progress += item.progress
    var max_size: int = _max_items.size()
    var percentage: float = total_progress / max_size
    on_progress_update.emit(percentage, total_progress, max_size)
