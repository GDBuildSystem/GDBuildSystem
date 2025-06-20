const axios = require('axios');

async function main()
{
    const API_URL = "https://godotengine.org/asset-library/api";
    const username = process.env.GODOT_LIBRARY_USERNAME;
    const password = process.env.GODOT_LIBRARY_PASSWORD;
    const assetName = process.env.GODOT_LIBRARY_ASSET_NAME;
    const assetId = process.env.GODOT_LIBRARY_ASSET_ID;
    const version = process.env.VERSION

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

    let page = 1;
    let asset = null;

    while (asset == null && page <= 100)
    {
        console.log(`Fetching page ${page}...`);
        const response = await axios.post(`${API_URL}/user/feed`, {
            page: page,
            max_results: 100,
            token: token,
        }, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const assets = response.data.result;
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

    if (asset == null)
    {
        throw new Error(`Asset "${assetName}" not found in the Godot Asset Library.`);
    }

    console.log(`Asset "${asset.title}" found!`);
    console.log(`Asset ID: ${asset.asset_id} | Edit ID: ${asset.edit_id} | Version: ${asset.version_string} -> ${version} | Last Modified: ${asset.modify_date} | Status: ${asset.status}`);

    const sendBlob = {
        "token": token,
        ...asset,
        "version_string": version,
    }

    console.log("Patching asset...\n", sendBlob);

    const editResponse = await axios.post(`${API_URL}/asset/edit/${asset.edit_id}`, sendBlob);
    if (editResponse.status !== 200)
    {
        throw new Error(`Failed to edit asset: ${editResponse.reason}`);
    }
    console.log("Asset modified successfully!");
}

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