const axios = require('axios');

async function main()
{
    // Grab the environment variables.
    const API_URL = "https://godotengine.org/asset-library/api";
    const username = process.env.GODOT_LIBRARY_USERNAME;
    const password = process.env.GODOT_LIBRARY_PASSWORD;
    const assetName = process.env.GODOT_LIBRARY_ASSET_NAME;
    const assetId = process.env.GODOT_LIBRARY_ASSET_ID;
    const version = process.env.VERSION

    // Validate the environment variables.
    if (!version)
    {
        throw new Error("Please set the VERSION environment variable.");
    }
    if (!username || !password)
    {
        throw new Error("Please set the GODOT_LIBRARY_USERNAME and GODOT_LIBRARY_PASSWORD environment variables.");
    }
    if (!assetName && !assetId)
    {
        throw new Error("Please set the GODOT_LIBRARY_ASSET_NAME or GODOT_LIBRARY_ASSET_ID environment variable.");
    }

    // Login into the Godot Asset Library.
    console.log("Logging in to Godot Asset Library...");
    const loginResponse = await axios.post(`${API_URL}/login`, {
        username: username,
        password: password
    });
    const token = loginResponse.data.token;
    if (!token)
    {
        throw new Error("Login failed: No token received.");
    }
    console.log("Login successful! Token received.");

    // Fetch the first reference to the asset either by name or ID, in each page.
    let page = 1;
    let asset = null;
    while (asset == null && page <= 100)
    {
        console.log(`Fetching page ${page}...`);
        const { data } = await axios.post(`${API_URL}/user/feed`, {
            page: page,
            max_results: 100,
            token: token,
        }, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const assets = data.events || data.results || [];
        console.log(`Received Page ${page}, data: ${JSON.stringify(assets, null, 2)}`);
        if (!Array.isArray(assets) || assets.length === 0)
        {
            console.log("No more assets found.");
            break;
        }

        for (const a of assets)
        {
            if ((assetName && a.title === assetName) || (assetId && a.asset_id === assetId))
            {
                asset = a;
                break;
            }
        }

        page++;
    }

    // Verify if the asset was found.
    if (asset == null)
    {
        throw new Error(`Asset "${assetName}" not found in the Godot Asset Library.`);
    }

    // Log the asset details.
    console.log(`Asset "${asset.title}" found!`);
    console.log(`Asset ID: ${asset.asset_id} | Edit ID: ${asset.edit_id} | Version: ${asset.version_string} -> ${version} | Last Modified: ${asset.modify_date} | Status: ${asset.status}`);

    // If the asset is not approved, we have to edit it differently than when it has been already approved before.
    if (asset.status === "new") // Edit the existing asset.
    {
        const { data: editedAssetData } = await axios.get(`${API_URL}/asset/edit/${asset.edit_id}`, {
            token: token,
        }, {
            headers: {
                "Authorization": `Bearer ${token}`
            }
        });

        const sendBlob = {
            "token": token,
            ...editedAssetData,
            // Overwrite the data inside the edited asset data.
            "version_string": version,
            "download_provider": "Custom",
            "download_commit": `https://github.com/GDBuildSystem/GDBuildSystem/releases/download/v${version}/gdbuildsystem-${version.replaceAll(".", "_")}.zip`
        }
        console.log("Patching existing asset edit...\n", sendBlob);

        const editResponse = await axios.post(`${API_URL}/asset/edit/${asset.edit_id}`, sendBlob);
        if (editResponse.status !== 200)
        {
            throw new Error(`Failed to edit asset: ${editResponse.reason}`);
        }

        // Print out the data.
        console.log("Patch response:", JSON.stringify(editResponse.data, null, 2));
    }
    else // Create a new asset version.
    {
        const sendBlob = {
            "token": token,
            ...asset,
            "version_string": version,
            "download_url": `https://github.com/GDBuildSystem/GDBuildSystem/releases/download/v${version}/gdbuildsystem-${version}.zip`
        }

        console.log("Creating new asset edit...\n", sendBlob);

        const editResponse = await axios.post(`${API_URL}/asset/${asset.asset_id}`, sendBlob);
        if (editResponse.status !== 200)
        {
            throw new Error(`Failed to edit asset: ${editResponse.reason}`);
        }
    }

    console.log("Asset modified successfully!");
}

// Run the main function and handle errors.
main().then(() =>
{
    console.log("Done!");
}
).catch((error) =>
{
    console.error("Error:", error);
    process.exit(1);
}
).finally(() =>
{
    console.log("Finished script execution.");
});