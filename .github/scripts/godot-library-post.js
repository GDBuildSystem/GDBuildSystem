const axios = require('axios');

async function main()
{
    const API_URL = "https://godotengine.org/asset-library/api";
    const username = process.env.GODOT_LIBRARY_USERNAME;
    const password = process.env.GODOT_LIBRARY_PASSWORD;
    const assetName = process.env.GODOT_LIBRARY_ASSET_NAME;

    if (!username || !password)
    {
        throw new Error("Please set the GODOT_LIBRARY_USERNAME and GODOT_LIBRARY_PASSWORD environment variables.");
    }
    if (!assetName)
    {
        throw new Error("Please set the GODOT_LIBRARY_ASSET_NAME environment variable.");
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
        const response = await axios.get(`${API_URL}/asset?user=${username}`, {
            params: {
                page: page,
                max_results: 100
            },
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const assets = response.data.result;
        if (assets.length === 0)
        {
            console.log("No more assets found.");
            break;
        }

        for (const a of assets)
        {
            if (a.name === assetName)
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
    console.log(`Asset "${assetName}" found!`);

    console.log(`Asset ID: ${asset.id}`);

    const sendBlob = {
        "token": token,
        ...asset,
        "version_string": process.env.VERSION,
    }
    console.log("Patching asset...\n", sendBlob);
    const editResponse = await axios.post(`${API_URL}/asset/edit/${asset.asset_id}`, sendBlob);
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