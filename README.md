![](https://github.com/GDBuildSystem/GDBuildSystem/blob/main/godot-build-systems-logo.png)
---
## Purpose
This Godot Add-on makes exporting your game easier by providing necessary features into your export pipeline.

### Features
<details>
<summary>Click to expand</summary>
- **Asset Bundling**
> Simplifies the process of bundling assets without the need for complex scripts or manual work. Simply the user will place files within the designated bundle directory under the `bundles` directory.
- **Predictive Resource Loading**
> [!NOTE]
> Work in progress, not fully implemented yet.

> This feature allows you to load resources in advance, that may cause initial load lag spikes while in-game play. Example, particles, large textures, shaders, etc.
- **GDScript Export Execution**
> [!NOTE]
> Work in progress, not fully implemented yet.

> This feature allows you to run GDScript code during the export process. This is useful for tasks such as modifying files, creating directories, or performing other actions that need to be done before the export is complete.
</details>

### Installation
<details>
<summary>Click to expand (Installation by Cloning)</summary>

1. Clone the repository into your Godot project directory under `addons/godot-build-systems`.
2. Enable the add-on in the Godot editor by going to `Project` → `Project Settings` → `Plugins` and enabling the `godot-build-systems` plugin.
3. Configure the add-on settings in `Project` → `Project Settings` → `GDBuildSystem`.
4. Use the add-on features as needed in your project.

</details>
<details>
<summary>Click to expand (Installation by Downloading)</summary>

1. Download the latest release either from the [GitHub Releases](https://github.com/GDBuildSystem/GDBuildSystem/releases) page or from the [Godot Asset Library](https://godotengine.org/asset-library/asset/).
2. Extract the downloaded archive into your Godot project directory under `addons/godot-build-systems`.
3. Enable the add-on in the Godot editor by going to `Project` → `Project Settings` → `Plugins` and enabling the `godot-build-systems` plugin.
4. Configure the add-on settings in `Project` → `Project Settings` → `GDBuildSystem`.
5. Use the add-on features as needed in your project.

</details>

### Usage
