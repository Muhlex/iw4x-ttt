#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	precacheModel("weapon_scavenger_grenadebag");
}

initPlayer()
{
	self.ttt.dropVelocity = 64;
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
	tieredWeapons[1][1] = "ak47";
	tieredWeapons[1][2] = "mp5k";
	tieredWeapons[1][3] = "p90";
	tieredWeapons[1][4] = "uzi";
	tieredWeapons[1][5] = "kriss";
	tieredWeapons[1][6] = "rpd";
	tieredWeapons[1][7] = "m1014";
	tieredWeapons[1][8] = "beretta393";
	tieredWeapons[1][9] = "glock";

	tieredWeapons[2][0] = "fn2000";
	tieredWeapons[2][1] = "mg4";
	tieredWeapons[2][2] = "m40a3";
	tieredWeapons[2][3] = "m40a3"; // generate more sniper rifles as this is the only one in the pool
	tieredWeapons[2][4] = "deserteagle";
	tieredWeapons[2][5] = "coltanaconda";
	tieredWeapons[2][6] = "pp2000";
	tieredWeapons[2][7] = "tmp";
	tieredWeapons[2][8] = "model1887";

	weighting = randomInt(100);
	result = undefined;
	if (weighting < 20) result = tieredWeapons[0][randomInt(tieredWeapons[0].size)];
	else if (weighting < 50) result = tieredWeapons[1][randomInt(tieredWeapons[1].size)];
	else result = tieredWeapons[2][randomInt(tieredWeapons[2].size)];

	return result + "_mp";
}

createWeaponEnt(weaponName, ammoClip, ammoStock, item, origin, angles, velocity, pickupDelay)
{
	if (!isDefined(weaponName)) return;
	if (!isDefined(ammoClip)) ammoClip = 0;
	if (!isDefined(ammoStock)) ammoStock = 0;
	if (!isDefined(item)) item = undefined;
	if (!isDefined(origin)) origin = (0, 0, 0);
	if (!isDefined(angles)) angles = (0, 0, 0);
	if (!isDefined(velocity)) velocity = (0, 0, 0);
	if (!isDefined(pickupDelay)) pickupDelay = 0;

	/**
	 * Some weapons have weird models that always fall straight to the ground
	 * even when velocity is applied. Some weapons seem to not be able to have physics
	 * at all (coltanaconda). Due to this an invisible physicsEnt is used that has the
	 * model of a weapon that works correctly.
	 */

	physicsEnt = spawn("script_model", origin);
	physicsEnt.angles = angles + (0, 90, 0);
	physicsEnt setModel(getWeaponModel("p90_mp"));
	physicsEnt hide();

	weaponEnt = spawn("script_model", origin);
	weaponEnt.angles = angles + (0, 90, 0);
	if (weaponName == "riotshield_mp") weaponEnt.angles += (0, 90, 0);
	if (weaponName == "onemanarmy_mp")
	{
		weaponEnt.angles += (-90, 100, -35);
		weaponEnt.origin += anglesToRight(physicsEnt.angles) * -2;
		physicsEnt.origin += anglesToForward(physicsEnt.angles) * 8;
	}
	weaponEnt linkTo(physicsEnt);
	weaponEnt setModel(getWeaponModel(weaponName));
	weaponParts = getWeaponHideTags(weaponName);
	foreach (part in weaponParts) weaponEnt hidePart(part);

	weaponEnt.physicsEnt = physicsEnt;
	weaponEnt.weaponName = weaponName;
	weaponEnt.ammoClip = ammoClip;
	weaponEnt.ammoStock = ammoStock;
	weaponEnt.item = item;

	// magic numbers to make the item receive velocity around it's center of mass
	launchOffset = 0 * anglesToRight(angles) + -10 * anglesToForward(angles) + 10 * anglesToUp(angles);

	physicsEnt physicsLaunchServer(origin + launchOffset, velocity); // this takes an absolute position!

	wait(pickupDelay);

	weaponEnt scripts\ttt\use::makeUsableCustom(
		::OnWeaponPickupTrigger,
		::OnWeaponPickupAvailable,
		::OnWeaponPickupAvailableEnd
	);
	weaponEnt thread weaponEntThink();
}

dropWeapon(weaponName, velocity)
{
	if (!isDefined(weaponName)) return;

	weaponWasActive = (weaponName == self getCurrentWeapon());

	ammoClip = self getWeaponAmmoClip(weaponName);
	ammoStock = self getWeaponAmmoStock(weaponName);
	item = undefined;

	if (scripts\ttt\items::isRoleWeapon(weaponName))
	{
		item = self.ttt.items.roleInventory.item;
		self scripts\ttt\items::resetRoleInventory();
	}

	eyePos = self getEye();
	spawnPos = physicsTrace(
		eyePos,
		eyePos + anglesToForward(self.angles) * 32
	);
	spawnPos -= anglesToForward(self.angles) * 24;
	spawnPos = physicsTrace(spawnPos, spawnPos + (0, 0, -16)) + (0, 0, 8);

	thread createWeaponEnt(weaponName, ammoClip, ammoStock, item, spawnPos, self getPlayerAngles(), velocity, 1);

	if (!isAlive(self)) return;

	self takeWeapon(weaponName);
	if (!weaponWasActive) return;

	primariesList = self getWeaponsListPrimaries();
	hasDefaultWeapon = self hasWeapon(level.ttt.defaultWeapon);
	weaponCount = primariesList.size - int(hasDefaultWeapon);

	if (weaponCount <= 1 && !hasDefaultWeapon) self giveDefaultWeapon();

	lastWeaponName = self getLastWeapon();
	if (!isDefined(lastWeaponName) || !self hasWeapon(lastWeaponName) || lastWeaponName == level.ttt.defaultWeapon)
		lastWeaponName = primariesList[0];
	if (!isDefined(lastWeaponName) || !self hasWeapon(lastWeaponName))
		return;
	self switchToWeapon(lastWeaponName);
}

tryPickUpWeapon(weaponEnt, pickupOnFullInventory)
{
	if (!isDefined(pickupOnFullInventory)) pickupOnFullInventory = false;

	hasRoleWeapon = self scripts\ttt\items::hasRoleWeapon();
	isRoleWeaponEquipped = self scripts\ttt\items::isRoleWeaponEquipped();
	newIsRoleWeapon = scripts\ttt\items::isRoleWeapon(weaponEnt.weaponName);

	if (self hasWeapon(weaponEnt.weaponName) || (hasRoleWeapon && newIsRoleWeapon)) return;

	currentWeapon = self getCurrentWeapon();

	if (newIsRoleWeapon)
	{
		scripts\ttt\items::setRoleInventory(weaponEnt.item, weaponEnt.ammoClip, weaponEnt.ammoStock);
		if (isDefined(weaponEnt.item.onPickUp)) self thread [[weaponEnt.item.onPickUp]](weaponEnt.item);
		self playLocalSound("weap_pickup");
	}
	else
	{
		hasDefaultWeapon = self hasWeapon(level.ttt.defaultWeapon);
		weaponCount = self getWeaponsListPrimaries().size - int(hasDefaultWeapon) - int(isRoleWeaponEquipped);

		if (weaponCount >= 2 && !pickupOnFullInventory) return;

		self giveWeapon(weaponEnt.weaponName);
		self setWeaponAmmoClip(weaponEnt.weaponName, weaponEnt.ammoClip);
		self setWeaponAmmoStock(weaponEnt.weaponName, weaponEnt.ammoStock);
		if (hasDefaultWeapon && weaponCount == 1) self takeWeapon(level.ttt.defaultWeapon);
		self thread maps\mp\gametypes\_weapons::stowedWeaponsRefresh();
		self playLocalSound("weap_pickup");

		if (weaponCount >= 2 && pickupOnFullInventory) self dropWeapon(currentWeapon);

		if (weaponCount == 0 || pickupOnFullInventory || currentWeapon == level.ttt.defaultWeapon)
			self switchToWeapon(weaponEnt.weaponName);
	}

	weaponEnt.physicsEnt delete();
	weaponEnt delete();
}

spawnWorldPickups()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_dm_spawn");
	spawnPoints = array_randomize(spawnPoints);

	foreach (spawnPoint in spawnPoints)
	{
		// Spawn weapons
		origin = spawnPoint.origin + (0, 0, 48); // put up to about half of the player's height
		origin = physicsTrace(
			origin,
			origin + anglesToForward(spawnPoint.angles) * randomIntRange(96, 256)
		);
		origin -= anglesToForward(spawnPoint.angles) * 24; // prevent weapons from spawning in walls

		origin = physicsTrace(origin, origin + (0, 0, -1024)) + (0, 0, 8);

		weaponName = getRandomWeapon();

		thread createWeaponEnt(weaponName, 0, weaponClipSize(weaponName), undefined, origin, (0, randomInt(360), 0));

		// Spawn ammo
		AMMO_COUNT = 3;
		for (i = 0; i < AMMO_COUNT; i++)
		{
			ammoForwardVector = anglesToForward((0, 360 / AMMO_COUNT * i, 0));
			ammoOrigin = physicsTrace(
				origin + (0, 0, 48),
				origin + ammoForwardVector * randomIntRange(48, 96)
			);
			ammoOrigin -= ammoForwardVector * 16;
			ammoOrigin = physicsTrace(ammoOrigin, ammoOrigin + (0, 0, -1024)) + (0, 0, 0);
			ammoModel = spawn("script_model", ammoOrigin);
			ammoModel setModel("weapon_scavenger_grenadebag");
			ammoModel.angles = (0, randomInt(360), 90);

			ammoModel thread ammoModelThink();
		}
	}
}

giveDefaultWeapon()
{
	self giveWeapon(level.ttt.defaultWeapon);
	self SetWeaponAmmoClip(level.ttt.defaultWeapon, 0);
	self SetWeaponAmmoStock(level.ttt.defaultWeapon, 0);
}

OnPlayerDropWeapon()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("drop_weapon", "+actionslot 1");

	for (;;)
	{
		self waittill("drop_weapon");

		// if (self getWeaponsListPrimaries().size < 1) continue;
		weaponName = self getCurrentWeapon();
		if (weaponName == level.ttt.defaultWeapon) continue;
		if (!maps\mp\gametypes\_weapons::mayDropWeapon(weaponName)) continue;

		self dropWeapon(
			weaponName,
			self getVelocity() * 0.5 + anglesToForward(self getPlayerAngles()) * self.ttt.dropVelocity + (0, 0, 64)
		);
	}
}

OnWeaponPickupTrigger(ent, player)
{
	player tryPickUpWeapon(ent, true);
}
OnWeaponPickupAvailable(ent, player)
{
	player scripts\ttt\ui::destroyUseAvailableHint();
	displayName = level.ttt.localizedWeaponNames[ent.weaponName];
	if (ent.weaponName == "onemanarmy_mp" && isDefined(ent.item)) displayName = ent.item.name;
	player scripts\ttt\ui::displayUseAvailableHint(&"[ ^3[{+activate}] ^7] for ^3", displayName);
}
OnWeaponPickupAvailableEnd(ent, player)
{
	player scripts\ttt\ui::destroyUseAvailableHint();
}

weaponEntThink()
{
	self endon("death");

	pickupDistanceSq = 32 * 32;

	for (;;)
	{
		// check if anyone is trying to implicitly pick up the weapon (walking over it)
		foreach (player in getLivingPlayers())
		{
			if (distanceSquared(player.origin, self.origin) > pickupDistanceSq) continue;

			player tryPickUpWeapon(self);
		}

		wait(0.1);
	}
}

ammoModelThink()
{
	self endon ("death");

	pickupDistanceSq = 32 * 32;

	for (;;)
	{
		foreach (player in getLivingPlayers())
		{
			if (distanceSquared(player.origin, self.origin) > pickupDistanceSq) continue;

			currentWeaponName = player getCurrentWeapon();
			player tryPickUpAmmo(self, currentWeaponName);
			foreach (weaponName in player getWeaponsListPrimaries())
				player tryPickUpAmmo(self, weaponName);
		}

		wait(0.1);
	}
}

tryPickUpAmmo(ammoEnt, weaponName)
{
	if (weaponName == level.ttt.defaultWeapon) return;
	if (weaponName == "rpg_mp") return;

	maxClip = weaponClipSize(weaponName);
	currentStock = self getWeaponAmmoStock(weaponName);
	maxStock = maxClip * int(weaponMaxAmmo(weaponName) / maxClip / 3);
	if (maxStock < maxClip) maxStock = maxClip;

	if (currentStock >= maxStock) return;

	newStock = currentStock + maxClip;
	if (newStock > maxStock) newStock = maxStock;

	self setWeaponAmmoStock(weaponName, newStock);
	self playLocalSound("scavenger_pack_pickup");
	ammoEnt delete();
}
