#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	precacheModel("weapon_scavenger_grenadebag");

	level.ttt.pickups = spawnStruct();
	level.ttt.effects.trailEffect = loadFX("props/throwingknife_geotrail");
}

initPlayer()
{
	self.ttt.pickups = spawnStruct();
	self.ttt.pickups.dropVelocity = 64;
	self.ttt.pickups.dropCanDamage = false;
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
	tieredWeapons[2][4] = "usp";
	tieredWeapons[2][5] = "deserteagle";
	tieredWeapons[2][6] = "coltanaconda";
	tieredWeapons[2][7] = "pp2000";
	tieredWeapons[2][8] = "tmp";
	tieredWeapons[2][9] = "model1887";

	weighting = randomInt(100);
	result = undefined;
	if (weighting < 20) result = tieredWeapons[0][randomInt(tieredWeapons[0].size)];
	else if (weighting < 50) result = tieredWeapons[1][randomInt(tieredWeapons[1].size)];
	else result = tieredWeapons[2][randomInt(tieredWeapons[2].size)];

	return result + "_mp";
}

createWeaponEnt(weaponName, ammoClip, ammoStock, item, origin, angles, velocity)
{
	if (!isDefined(weaponName)) return;
	if (!isDefined(ammoClip)) ammoClip = 0;
	if (!isDefined(ammoStock)) ammoStock = 0;
	if (!isDefined(item)) item = undefined;
	if (!isDefined(origin)) origin = (0, 0, 0);
	if (!isDefined(angles)) angles = (0, 0, 0);
	if (!isDefined(velocity)) velocity = (0, 0, 0);

	/**
	 * Some weapons have weird models that always fall straight to the ground
	 * even when velocity is applied. Some weapons seem to not be able to have physics
	 * at all (coltanaconda). Due to this an invisible physicsEnt is used that has the
	 * model of a weapon that works correctly.
	 */

	// offset the p90 model so that it's actual center is at the specified origin
	physicsEnt = spawn("script_model", origin + anglesToForward(angles) * 12);
	physicsEnt.angles = angles;
	physicsEnt setModel(getWeaponModel("p90_mp"));
	physicsEnt hide();

	weaponEnt = spawn("script_model", origin);
	weaponEnt.angles = angles;
	switch (getWeaponClass(weaponName)) {
		case "weapon_smg":
			weaponEnt.origin += anglesToForward(angles) * 10;
			break;
		case "weapon_pistol":
		case "weapon_machine_pistol":
		case "weapon_assault":
			weaponEnt.origin += anglesToForward(angles) * 6;
			break;
		case "weapon_shotgun":
			weaponEnt.origin += anglesToForward(angles) * -2;
			break;
	}
	if (weaponName == "riotshield_mp") weaponEnt.angles = combineAngles(angles, (0, 90, 90));
	if (weaponName == "onemanarmy_mp")
	{
		weaponEnt.angles = combineAngles(angles, (-90, 100, -35));
		weaponEnt.origin += anglesToRight(angles) * -2;
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

	// ... because this takes an absolute position:
	physicsEnt physicsLaunchServer(physicsEnt.origin + launchOffset, velocity);

	weaponEnt thread OnWeaponEntUsable();
	weaponEnt thread OnWeaponEntPhysicsFinish();

	return weaponEnt;
}

OnWeaponPickupTrigger(ent)
{
	self tryPickUpWeapon(ent, true);
}
OnWeaponPickupAvailable(ent)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
	displayName = level.ttt.localizedWeaponNames[ent.weaponName];
	if (ent.weaponName == "onemanarmy_mp" && isDefined(ent.item)) displayName = ent.item.name;
	self scripts\ttt\ui::displayUseAvailableHint(&"[ ^3[{+activate}] ^7] for ^3", displayName);
}
OnWeaponPickupAvailableEnd(ent)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

OnWeaponEntUsable()
{
	wait(0.25);

	self scripts\ttt\use::makeUsableCustom(
		::OnWeaponPickupTrigger,
		::OnWeaponPickupAvailable,
		::OnWeaponPickupAvailableEnd
	);
}

OnWeaponEntPhysicsFinish()
{
	self endon("death");

	self.physicsEnt waittill("physics_finished");

	stopFXOnTag(level.ttt.effects.trailEffect, self, "tag_weapon");

	self thread weaponEntThink();
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
			isNearOrigin = distanceSquared(player.origin, self.origin) <= pickupDistanceSq;
			isNearEyes = distanceSquared(player getEye(), self.origin) <= pickupDistanceSq;
			if (!isNearOrigin && !isNearEyes) continue;

			player tryPickUpWeapon(self);
		}

		wait(0.1);
	}
}

createAmmoEnt(origin, angles)
{
	if (!isDefined(origin)) origin = (0, 0, 0);
	if (!isDefined(angles)) angles = (0, 0, 0);

	ammoEnt = spawn("script_model", origin);
	ammoEnt setModel("weapon_scavenger_grenadebag");
	ammoEnt.angles = angles + (0, 0, 90);

	ammoEnt thread ammoEntThink();
}

ammoEntThink()
{
	self endon ("death");

	pickupDistanceSq = 32 * 32;

	for (;;)
	{
		foreach (player in getLivingPlayers())
		{
			isNearOrigin = distanceSquared(player.origin, self.origin) <= pickupDistanceSq;
			isNearEyes = distanceSquared(player getEye(), self.origin) <= pickupDistanceSq;
			if (!isNearOrigin && !isNearEyes) continue;

			currentWeaponName = player getCurrentWeapon();
			player tryPickUpAmmo(self, currentWeaponName);
			foreach (weaponName in player getWeaponsListPrimaries())
				player tryPickUpAmmo(self, weaponName);
		}

		wait(0.1);
	}
}

tryPickUpWeapon(weaponEnt, explicitPickup)
{
	if (!isDefined(explicitPickup)) explicitPickup = false;

	hasRoleWeapon = self scripts\ttt\items::hasRoleWeapon();
	isRoleWeaponEquipped = self scripts\ttt\items::isRoleWeaponEquipped();
	newIsRoleWeapon = scripts\ttt\items::isRoleWeapon(weaponEnt.weaponName);

	if (self hasWeapon(weaponEnt.weaponName) || (hasRoleWeapon && newIsRoleWeapon)) return;

	currentWeapon = self getCurrentWeapon();

	if (newIsRoleWeapon)
	{
		if (!explicitPickup) return;
		scripts\ttt\items::setRoleInventory(weaponEnt.item, weaponEnt.ammoClip, weaponEnt.ammoStock);
		if (isDefined(weaponEnt.item.onPickUp)) self thread [[weaponEnt.item.onPickUp]](weaponEnt.item);
		self playLocalSound("weap_pickup");
	}
	else
	{
		hasDefaultWeapon = self hasWeapon(level.ttt.defaultWeapon);
		primariesList = self getWeaponsListPrimaries();
		weaponCount = primariesList.size - int(hasDefaultWeapon) - int(isRoleWeaponEquipped);
		lastValidWeapon = self getLastValidWeapon();

		if (weaponCount >= 2 && !explicitPickup) return;

		self giveWeapon(weaponEnt.weaponName);
		self setWeaponAmmoClip(weaponEnt.weaponName, weaponEnt.ammoClip);
		self setWeaponAmmoStock(weaponEnt.weaponName, weaponEnt.ammoStock);
		if (hasDefaultWeapon && weaponCount == 1) self takeWeapon(level.ttt.defaultWeapon);
		self thread maps\mp\gametypes\_weapons::stowedWeaponsRefresh();
		self playLocalSound("weap_pickup");

		if (weaponCount >= 2 && explicitPickup)
		{
			if (maps\mp\gametypes\_weapons::mayDropWeapon(currentWeapon) && !isRoleWeaponEquipped)
				self dropWeapon(currentWeapon);
			else
				self dropWeapon(lastValidWeapon);
		}

		if ((weaponCount == 0 || explicitPickup || currentWeapon == level.ttt.defaultWeapon) && !isRoleWeaponEquipped)
			self switchToWeapon(weaponEnt.weaponName);
	}

	weaponEnt.physicsEnt delete();
	weaponEnt.killCamEnt delete();
	weaponEnt delete();
}

tryPickUpAmmo(ammoEnt, weaponName)
{
	if (!self maps\mp\gametypes\_weapons::mayDropWeapon(weaponName)) return;
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

spawnWorldPickups()
{
	mapname = getDvar("mapname");
	spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray("mp_dm_spawn");
	if (isDefined(level.ttt.coords.pickups[mapname]))
		spawnPoints = array_combine(spawnPoints, level.ttt.coords.pickups[mapname]);
	spawnPoints = array_randomize(spawnPoints);

	foreach (spawnPoint in spawnPoints)
	{
		// Spawn weapons
		isPlayerSpawnPoint = isDefined(spawnPoint.origin);

		if (isPlayerSpawnPoint) origin = spawnPoint.origin;
		else origin = spawnPoint;

		origin += (0, 0, 48); // put up to about half of the player's height

		if (isPlayerSpawnPoint)
		{
			origin = physicsTrace(
				origin,
				origin + anglesToForward(spawnPoint.angles) * randomIntRange(96, 256)
			);
			origin -= anglesToForward(spawnPoint.angles) * 24; // prevent weapons from spawning in walls
		}

		origin = physicsTrace(origin, origin + (0, 0, -1024)) + (0, 0, 8);

		weaponName = getRandomWeapon();

		createWeaponEnt(weaponName, 0, weaponClipSize(weaponName), undefined, origin, (0, randomInt(360), 0));

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

			createAmmoEnt(ammoOrigin, (0, randomInt(360), 0));
		}
	}
}

OnPlayerDropWeapon()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("drop_weapon", "+actionslot 1");

	for (;;)
	{
		self waittill("drop_weapon");

		weaponName = self getCurrentWeapon();
		if (weaponName == level.ttt.defaultWeapon) continue;
		if (!maps\mp\gametypes\_weapons::mayDropWeapon(weaponName)) continue;

		self dropWeapon(
			weaponName,
			self getVelocity() * 0.5 + anglesToForward(self getPlayerAngles()) * self.ttt.pickups.dropVelocity + (0, 0, 64)
		);
	}
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

	weaponEnt = createWeaponEnt(weaponName, ammoClip, ammoStock, item, spawnPos, self getPlayerAngles() + (0, 90, 0), velocity);

	if (self.ttt.pickups.dropCanDamage)
	{
		self playSound("detpack_pickup");
		weaponEnt.killCamEnt = spawn("script_model", weaponEnt.origin);

		weaponEnt thread setTrailEffect();
		weaponEnt thread weaponEntKillCamEntThink(self);
		weaponEnt thread OnWeaponEntDamagePlayer(self);
	}

	if (!isAlive(self)) return;

	self takeWeapon(weaponName);
	if (!weaponWasActive) return;

	hasDefaultWeapon = self hasWeapon(level.ttt.defaultWeapon);
	weaponCount = self getWeaponsListPrimaries().size - int(hasDefaultWeapon);

	if (weaponCount <= 1 && !hasDefaultWeapon) self giveDefaultWeapon();

	self switchToLastWeapon();
}

setTrailEffect()
{
	wait(0.05);
	playFXOnTag(level.ttt.effects.trailEffect, self, "tag_weapon");
}

weaponEntKillCamEntThink(attacker)
{
	self endon("death");
	self.physicsEnt endon("physics_finished");

	playerAngles = attacker getPlayerAngles();
	offset = (0, 0, 16);
	offset += anglesToForward(playerAngles) * -48;
	offset += anglesToRight(playerAngles) * -16;

	for (;;)
	{
		wait(0.1); // needs to be at least 2 ticks to allow smooth movement

		self.killCamEnt moveTo(self.physicsEnt.origin + offset, 0.1);
	}
}

OnWeaponEntDamagePlayer(attacker)
{
	self endon("death");
	self.physicsEnt endon("physics_finished");

	TICK_RATE = 20;

	distanceSq = 0.0;

	for (;;)
	{
		if (isDefined(self.physicsEnt.lastTickOrigin))
		{
			forward = anglesToForward(self.physicsEnt.angles);
			lastForward = anglesToForward(self.physicsEnt.lastTickAngles);

			/**
			 * The "collision" of the weapon is determined with 3 parallel traces
			 * that each test for intersection with a player entity.
			 * The middle one (index 1) lies in the center of the weapon.
			 */

			origins = [];
			lastTickOrigins = [];
			for (i = 0; i < 3; i++)
			{
				origins[i] = self.physicsEnt.origin + forward * (i * -12);
				lastTickOrigins[i] = self.physicsEnt.lastTickOrigin + lastForward * (i * -12);
			}

			velocitySq = lengthSquared(origins[1] * TICK_RATE - lastTickOrigins[1] * TICK_RATE);
			distanceSq += distanceSquared(origins[1], lastTickOrigins[1]);

			for (i = 0; i < origins.size; i++)
			{
				trace = bulletTrace(lastTickOrigins[i], origins[i], true, attacker);
				if (isDefined(trace["entity"]) && isPlayer(trace["entity"]) && isAlive(trace["entity"]))
				{
					if (velocitySq > 256 * 256)
					{
						velocityFactor = min(velocitySq / (512 * 512), 1);
						distanceFactor = min(distanceSq / (192 * 192), 1);
						damage = level.ttt.maxhealth * velocityFactor * distanceFactor;
						trace["entity"] thread [[level.callbackPlayerDamage]](
							self, // eInflictor The entity that causes the damage. ( e.g. a turret )
							attacker, // eAttacker The entity that is attacking.
							int(damage), // iDamage Integer specifying the amount of damage done
							0, // iDFlags Integer specifying flags that are to be applied to the damage
							"MOD_IMPACT", // sMeansOfDeath Integer specifying the method of death
							self.weaponName, // sWeapon The weapon number of the weapon used to inflict the damage
							trace["position"], // vPoint The point the damage is from?
							trace["normal"] * -1, // vDir The direction of the damage
							"none", // sHitLoc The location of the hit
							0 // psOffsetTime The time offset for the damage
						);
						trace["entity"] playSound("knife_bounce_wood");
					}

					createWeaponEnt(
						self.weaponName,
						self.ammoClip,
						self.ammoStock,
						self.item,
						origins[1],
						self.physicsEnt.angles,
						trace["normal"] * 64 + (0, 0, 48)
					);

					self.physicsEnt delete();
					self.killCamEnt delete();
					self delete();
					return; // function already implicitly ends due to the entity being deleted
				}
			}
		}

		self.physicsEnt.lastTickOrigin = self.physicsEnt.origin;
		self.physicsEnt.lastTickAngles = self.physicsEnt.angles;
		wait(0.05);
	}
}

giveDefaultWeapon()
{
	self giveWeapon(level.ttt.defaultWeapon);
	self SetWeaponAmmoClip(level.ttt.defaultWeapon, 0);
	self SetWeaponAmmoStock(level.ttt.defaultWeapon, 0);
}
