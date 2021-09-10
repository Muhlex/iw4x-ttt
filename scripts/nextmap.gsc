#include common_scripts\utility;

init()
{
	if (isDefined(game["nextmap_executed"]) && game["nextmap_executed"]) return;

	setDvarIfUninitialized("sv_mapRotationQueue", "");

	configs = parseRotationString(getDvar("sv_mapRotation"));
	if (!isDefined(configs)) return;
	if (configs.size == 0)
	{
		printLn("[nextmap] No rotation configured.");
		return;
	}

	queuedConfigs = parseRotationString(getDvar("sv_mapRotationQueue"));

	if (queuedConfigs.size > 0)
	{
		queuedConfigs = array_remove(
			queuedConfigs,
			findConfig(queuedConfigs, getDvar("g_gametype"), getDvar("mapname"))
		);
	}

	if (queuedConfigs.size == 0)
	{
		if (getDvarInt("sv_mapRotationRandomize"))
			queuedConfigs = fisherYatesShuffle(configs);
		else
			queuedConfigs = configs;
	}

	nextConfig = queuedConfigs[0];

	setDvar("sv_mapRotationQueue", buildRotationString(queuedConfigs));

	printLn("[nextmap] Configured gametype/map rotation:");
	foreach (config in configs)
		printLn("[nextmap] GAMETYPE: ^3" + config.gametype + "^7 | MAP: ^3" + config.map);

	printLn("[nextmap] Next up: " + nextConfig.gametype + " on " + nextConfig.map);

	wait(1.0);
	setDvar("sv_mapRotationCurrent", buildCurrentString(nextConfig));

	game["nextmap_executed"] = true;
}

parseRotationString(string)
{
	args = strTok(string, " ");
	if (!isDefined(args)) args = [];

	configs = [];
	lastKey = ""; // was "gametype" or "map" parsed in the last iteration?
	gametype = getDvar("g_gametype");
	map = getDvar("mapname");

	for (i = 0; i < args.size; i += 2)
	{
		key = args[i];
		value = args[i + 1];

		switch (key) {
			case "gametype":
				if (!isValidGameType(value))
				{
					printLn("[nextmap] ^1sv_mapRotation: Invalid gametype specified." + value);
					return;
				}
				gametype = value;
				break;

			case "map":
				if (!mapExists(value))
				{
					printLn("[nextmap] ^1sv_mapRotation: Invalid map specified: " + value);
					return;
				}
				map = value;
				break;

			default:
				printLn("[nextmap] ^1sv_mapRotation: Invalid Syntax.");
				return;
		}

		config = spawnStruct();
		config.gametype = gametype;
		config.map = map;

		// if the last iteration was a gametype, a following map belongs to the same config
		if (lastKey == "gametype" && key == "map")
			configs[configs.size - 1] = config;
		else
			configs[configs.size] = config;

		lastKey = key;
	}

	return configs;
}

buildRotationString(configs)
{
	result = "";
	foreach (i, config in configs)
	{
		result += "gametype " + config.gametype + " map " + config.map;
		if (i < configs.size - 1) result += " ";
	}
	return result;
}

buildCurrentString(config)
{
	result = "gametype " + config.gametype + " map " + config.map;
	// add a dummy set to prevent the game from messing with the queue once it runs out:
	result += " gametype null map null";
	return result;
}

findConfig(configs, gametype, map)
{
	foreach (config in configs)
		if (config.gametype == gametype && config.map == map) return config;

	return undefined;
}

fisherYatesShuffle(array)
{
	for (i = array.size - 1; i > 0; i--)
	{
		j = randomInt(i + 1);
		temp = array[i];
		array[i] = array[j];
		array[j] = temp;
	}
	return array;
}
