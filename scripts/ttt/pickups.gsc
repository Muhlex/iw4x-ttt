#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	precacheModel("weapon_scavenger_grenadebag");
}

getRandomWeapon()
{
	tieredWeapons = [];
	for (i = 0; i < 3; i++) tieredWeapons[i] = [];

	tieredWeapons[0][0] = "famas";
	tieredWeapons[0][1] = "scar";
	tieredWeapons[0][2] = "fal";
	tieredWeapons[0][3] = "tavor";
	tieredWeapons[0][4] = "masada";
	tieredWeapons[0][5] = "ump45";
	tieredWeapons[0][6] = "aug";

	tieredWeapons[1][0] = "m4";
	tieredWeapons[1][1] = "m16";
	tieredWeapons[1][2] = "ak47";
	tieredWeapons[1][3] = "mp5k";
	tieredWeapons[1][4] = "p90";
	tieredWeapons[1][5] = "kriss";
	tieredWeapons[1][6] = "m240";
	tieredWeapons[1][7] = "m1014";
	tieredWeapons[1][8] = "beretta393";

	tieredWeapons[2][0] = "uzi";
	tieredWeapons[2][1] = "mg4";
	tieredWeapons[2][2] = "m40a3";
	tieredWeapons[2][3] = "m40a3"; // generate more sniper rifles as this is the only one in the pool
	tieredWeapons[2][4] = "deserteagle";
	tieredWeapons[2][5] = "coltanaconda";
	tieredWeapons[2][6] = "pp2000";
	tieredWeapons[2][7] = "tmp";
	tieredWeapons[2][8] = "model1887";
	tieredWeapons[2][9] = "glock";

	weighting = randomInt(100);
	if (weighting < 20) return tieredWeapons[0][randomInt(tieredWeapons[0].size)];
	else if (weighting < 50) return tieredWeapons[1][randomInt(tieredWeapons[1].size)];
	else return tieredWeapons[2][randomInt(tieredWeapons[2].size)];
}

spawnWorldPickups()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_dm_spawn");
	spawnPoints = array_randomize(spawnPoints);

	for (i = 0; i < spawnPoints.size; i++)
	{
		// Spawn weapons
		origin = spawnPoints[i].origin;
		moveForwardBy = anglesToForward(spawnPoints[i].angles) * randomIntRange(80, 160);
		origin += (0, 0, 32);
		origin += moveForwardBy;
		weaponName = "weapon_" + getRandomWeapon() + "_mp";
		weapon = spawn(weaponName, origin);
		weapon itemWeaponSetAmmo(0, 0, 0);

		// Spawn ammo
		for (j = 0; j < 3; j++)
		{
			ammoOrigin = origin + (randomIntRange(-35, 36), randomIntRange(-35, 36), 8 * (j+1));
			ammoModel = spawn("script_model", ammoOrigin);
			ammoModel setModel("weapon_scavenger_grenadebag");
			ammoModel.angles = (0, 0, 90);
			ammoModel physicsLaunchServer((0, 0, 0), (0, 0, 0));

			// ammoModel setCursorHint("HINT_NOICON");
			// ammoModel setHintString(&"MP_AMMO_PICKUP");
			// ammoModel makeUsable();
			// foreach (player in level.players) ammoModel enablePlayerUse(player);
			// ammoTrigger = spawn("trigger_radius", ammoOrigin, 0, 16, 128);
			// ammoTrigger linkTo(ammoModel, "tag_origin", (0, 0, 0), (0, 0, 0));
			// ammoTrigger thread ammoTriggerThink(ammoModel);
			ammoModel thread ammoModelThink();
		}
	}
}

ammoModelThink()
{
	self endon ("death");

	pickupDistanceSq = 32 * 32;

	for(;;)
	{
		// self waittill("trigger", player);
		wait(0.1);

		foreach (player in getLivingPlayers())
		{
			if (distanceSquared(player.origin, self.origin) > pickupDistanceSq) continue;

			weapon = player getCurrentWeapon();
			maxClip = weaponClipSize(weapon);
			currentStock = player getWeaponAmmoStock(weapon);
			maxStock = int(weaponMaxAmmo(weapon) / 4);
			if (maxStock < maxClip) maxStock = maxClip;

			if (currentStock >= maxStock) continue;

			newStock = currentStock + maxClip;
			if (newStock > maxStock) newStock = maxStock;

			player setWeaponAmmoStock(weapon, newStock);
			player playLocalSound("scavenger_pack_pickup");
			self delete();
		}
	}
}
