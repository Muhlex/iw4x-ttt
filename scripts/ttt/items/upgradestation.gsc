#include common_scripts\utility;
#include scripts\ttt\_util;

init()
{
	if (level.ttt.modEnabled) precacheModel("com_plasticcase_upgrade");

	upgradestation = spawnStruct();
	upgradestation.name = "UPGRADE STATION";
	upgradestation.description = "^3Deployable Active Item\n^7Trade ^3" + level.ttt.upgradestationAmountRequired + " ^7weapons for an ^2extra powerful\none^7. Rarer weapons, ^2special rewards^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	upgradestation.activateHint = &"Press [ ^3[{+attack}]^7 ] to ^3place ^7the upgrade station";
	upgradestation.icon = "rank_sgt1";
	upgradestation.onBuy = ::OnBuy;
	upgradestation.onActivate = ::OnActivate;
	upgradestation.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	upgradestation.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	upgradestation.weaponName = "onemanarmy_mp";
	if (level.ttt.modEnabled) upgradestation.weaponName = "oma_upgradestation_mp";

	scripts\ttt\items::registerItem(upgradestation, "detective");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item);
}

OnActivate()
{
	eyePos = self getEye();
	spawnPos = physicsTrace(eyePos, eyePos + anglesToForward(self.angles) * 64);
	spawnPos -= anglesToForward(self.angles) * 16;
	spawnPos = physicsTrace(spawnPos, spawnPos - (0, 0, self getPlayerViewHeight())) + (0, 0, 16);

	spawnPosLeft = spawnPos + anglesToRight(self.angles) * -20;
	spawnPosRight = spawnPos + anglesToRight(self.angles) * 20;
	if (positionWouldTelefrag(spawnPos) || positionWouldTelefrag(spawnPosLeft) || positionWouldTelefrag(spawnPosRight))
	{
		self iPrintLnBold("You cannot place an upgrade station here");
		return;
	}

	self scripts\ttt\items::takeRoleWeapon();
	self switchToLastWeapon();
	self scripts\ttt\items::resetRoleInventory();

	upgradeStation = spawn("script_model", spawnPos);
	upgradeStation setModel("com_plasticcase_enemy");
	upgradeStation.angles = combineAngles(self.angles, (0, -90, 0));

	if (level.ttt.modEnabled)
	{
		upgradeStation.logoCrate = spawn("script_model", upgradeStation.origin);
		upgradeStation.logoCrate.angles = upgradeStation.angles;
		upgradeStation.logoCrate setModel("com_plasticcase_upgrade");
		upgradeStation.logoCrate notSolid();
		upgradeStation.logoCrate linkTo(upgradeStation);
	}

	upgradeStation.targetname = "ttt_destructible_item";
	upgradeStation cloneBrushmodelToScriptmodel(level.airDropCrateCollision);
	upgradeStation physicsLaunchServer();
	upgradeStation.placedWeapons = [];
	upgradeStation.generatedWeapons = [];
	upgradeStation.upgrading = false;
	upgradeStation thread OnUpgradePhysicsFinish();

	upgradeStation setCanDamage(true);
	upgradeStation.maxhealth = 500;
	upgradeStation.health = upgradeStation.maxhealth;
	upgradeStation.damageTaken = 0;
	upgradeStation thread OnUpgradeStationDamage();
	upgradeStation thread OnUpgradeStationDeath();
}

OnUpgradePhysicsFinish()
{
	self endon("death");

	self waittill("physics_finished");

	self thread upgradeStationThink();
	self scripts\ttt\use::makeUsableCustom(
		::OnUpgradeStationTrigger,
		::OnUpgradeStationAvailable,
		::OnUpgradeStationAvailableEnd, 80, 45, 0, true
	);
}

OnUpgradeStationDamage()
{
	self endon("death");

	for (;;)
	{
		self waittill("damage", damage, attacker);

		self.damageTaken += damage;

		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
		playFX(level._effect["sentry_smoke_mp"], self.origin);
		self playSound("bullet_ap_crate");

		if (self.damageTaken > self.maxhealth) self notify("death");
	}
}

OnUpgradeStationDeath()
{
	self waittill("death", attacker);

	attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
	playFX(level._effect["sentry_explode_mp"], self.origin);
	self playSound("sentry_explode");

	wait(4);

	foreach (weaponEnt in self.placedWeapons)
	{
		weaponEnt.physicsEnt physicsLaunchServer();
		weaponEnt.implicitPickup = true;
	}

	if (level.ttt.modEnabled) self.logoCrate delete();
	self delete();
}

upgradeStationThink()
{
	self endon("death");

	SAFEGUARD_DIST_SQ = 48 * 48;

	CENTER = self.origin;
	HALF = spawnStruct();
	HALF.X = 34;
	HALF.Y = 20;
	HALF.Z = 18;
	DIR = spawnStruct();
	DIR.X = anglesToForward(self.angles);
	DIR.Y = anglesToRight(self.angles);
	DIR.Z = anglesToUp(self.angles);

	// thread drawDebugCircle(CENTER, sqrt(SAFEGUARD_DIST_SQ), (1, 1, 1), 72000);
	// thread drawDebugLine(CENTER - DIR.X * HALF.X, CENTER + DIR.X * HALF.X, (1, 0, 0), 72000);
	// thread drawDebugLine(CENTER - DIR.Y * HALF.Y, CENTER + DIR.Y * HALF.Y, (0, 1, 0), 72000);
	// thread drawDebugLine(CENTER - DIR.Z * HALF.Z, CENTER + DIR.Z * HALF.Z, (0, 0, 1), 72000);

	for (;;)
	{
		droppedWeaponEnts = getEntArray("ttt_dropped_weapon", "targetname");

		foreach (weaponEnt in droppedWeaponEnts)
		{
			if (self.placedWeapons.size >= level.ttt.upgradestationAmountRequired)
				continue;

			if (distanceSquared(weaponEnt.origin, CENTER) > SAFEGUARD_DIST_SQ)
				continue;

			diff = weaponEnt.origin - CENTER;
			if (
				abs(vectordot(diff, DIR.X)) > HALF.X ||
				abs(vectordot(diff, DIR.Y)) > HALF.Y ||
				abs(vectordot(diff, DIR.Z)) > HALF.Z
			) continue;

			if (isInArray(self.placedWeapons, weaponEnt) || isInArray(self.generatedWeapons, weaponEnt))
				continue;

			self placeWeapon(weaponEnt);
		}

		wait(0.05);
	}
}

placeWeapon(oldEnt)
{
	newEnt = scripts\ttt\pickups::createWeaponEnt(
		oldEnt.weaponName,
		oldEnt.ammoClip,
		oldEnt.ammoStock,
		oldEnt.item,
		oldEnt.data,
		oldEnt.physicsEnt.origin - anglesToForward(oldEnt.physicsEnt.angles) * 12,
		oldEnt.physicsEnt.angles,
		undefined,
		false
	);
	newEnt.implicitPickup = false;

	weaponSlot = 0;
	for (i = 0; i < level.ttt.upgradestationAmountRequired; i++)
	{
		if (!isDefined(self.placedWeapons[i]))
		{
			self.placedWeapons[i] = newEnt;
			weaponSlot = i;
			break;
		}
	}
	self updateUseHint();

	targetAngles = combineAngles(self.angles, (0, 135, 90));
	targetOrigin = getWeaponOffset(weaponSlot) + anglesToForward(targetAngles) * 12;
	newEnt.physicsEnt moveTo(targetOrigin, 0.4, 0.1, 0.2);
	newEnt.physicsEnt rotateTo(targetAngles, 0.3, 0.1, 0.1);

	self thread OnPlacedWeaponDeath(newEnt);

	oldEnt scripts\ttt\pickups::deleteWeaponEnt();
}

getWeaponOffset(posIndex)
{
	requiredCount = level.ttt.upgradestationAmountRequired;
	forwardVector = anglesToForward(self.angles);
	centerPos = self.origin + anglesToUp(self.angles) * 15;
	maxLeftPos = centerPos - forwardVector * 26;
	width = distance(maxLeftPos, centerPos) * 2;
	spaceBetween = width / requiredCount;

	return maxLeftPos + (forwardVector * spaceBetween / 2) + (posIndex * forwardVector * spaceBetween);
}

OnPlacedWeaponDeath(weaponEnt)
{
	weaponEnt waittill("death");

	index = arrayFindIndex(self.placedWeapons, weaponEnt);
	self.placedWeapons[index] = undefined;
	self updateUseHint();
}

OnUpgradeStationTrigger(upgradeStation)
{
	if (upgradeStation.upgrading) return;
	if (upgradeStation.placedWeapons.size < level.ttt.upgradestationAmountRequired) return;

	upgradeStation thread upgradeWeapons();
}

upgradeWeapons()
{
	SPECIAL_WEAPONNAME = "deserteaglegold_mp";
	specialPercent = 0.0;

	w = [];
	w[0] = "cheytac_mp";
	w[1] = "striker_mp";
	w[2] = "glock_akimbo_mp";
	w[3] = "m79_mp";
	w[4] = "m4_heartbeat_mp";

	upVector = anglesToUp(self.angles);

	self.upgrading = true;
	self updateUseHint();

	self playSound("intelligence_pickup");

	foreach (inputEnt in self.placedWeapons)
	{
		inputEnt.allowPickup = false;
		inputEnt.physicsEnt moveTo(inputEnt.physicsEnt.origin - upVector * 6, 0.5, 0.5);

		if (isInArray(level.ttt.tieredWeapons[0], inputEnt.weaponName))
			specialPercent += 0.5 / self.placedWeapons.size;
		else if (scripts\ttt\items::isRoleWeapon(inputEnt.weaponName))
			specialPercent += 1.0 / self.placedWeapons.size;
		else if (isInArray(w, inputEnt.weaponName) || inputEnt.weaponName == SPECIAL_WEAPONNAME)
			specialPercent += 1.0 / self.placedWeapons.size;
	}

	fxTargetEnt = spawn("script_model", self.origin + upVector * 6);
	fxTargetEnt.angles = combineAngles(self.angles, (-90, 0, 0));
	fxTargetEnt setModel("tag_origin");

	wait(0.5);

	playFXOnTag(level.ttt.effects.redFlare, fxTargetEnt, "tag_origin");
	fxTargetEnt playLoopSound("tactical_insert_flare_burn");

	foreach (inputEnt in self.placedWeapons)
		inputEnt scripts\ttt\pickups::deleteWeaponEnt();

	self.placedWeapons = [];

	rollRigEnt = spawn("script_model", self.origin + upVector * 10);
	rollRigEnt.angles = self.angles;
	rollRigEnt moveTo(self.origin + upVector * 32, 1.5, 0.1, 1.0);

	rollDisplayEnt = undefined;
	weaponName = undefined;
	randomIndex = undefined;

	for (i = 0; i < 24; i++)
	{
		if (isDefined(rollDisplayEnt)) rollDisplayEnt scripts\ttt\pickups::deleteWeaponEnt();
		if (isDefined(randomIndex))
		{
			lastRandomIndex = randomIndex;
			randomIndex = randomInt(w.size - 1);
			if (randomIndex == lastRandomIndex) randomIndex = w.size - 1;
		}
		else randomIndex = randomInt(w.size);

		weaponName = w[randomIndex];
		if (randomFloat(1.0) < specialPercent)
			weaponName = SPECIAL_WEAPONNAME;

		rollDisplayEnt = scripts\ttt\pickups::spawnWeaponModel(weaponName, rollRigEnt.origin, rollRigEnt.angles);
		rollDisplayEnt linkTo(rollRigEnt);
		if (i > 5 || i % 2 == 0) self playSound("vending_machine_button_press");

		wait(clamp(i * 0.018, 0.05, 1.0));
	}

	wait(1);

	stopFXOnTag(level.ttt.effects.redFlare, fxTargetEnt, "tag_origin");
	fxTargetEnt stopLoopSound();
	fxTargetEnt delete();
	rollDisplayEnt scripts\ttt\pickups::deleteWeaponEnt();
	rollRigEnt delete();
	self playSound("elev_bell_ding");

	weaponEnt = scripts\ttt\pickups::createWeaponEnt(
		weaponName,
		weaponClipSize(weaponName),
		0,
		undefined, undefined,
		self.origin + upVector * 24,
		self.angles,
		(upVector * 128) + (anglesToForward((0, randomInt(360), 0)) * 48)
	);

	self.generatedWeapons[self.generatedWeapons.size] = weaponEnt;
	self.upgrading = false;
	self updateUseHint();
}

OnUpgradeStationAvailable(upgradeStation)
{
	useHint = upgradeStation getUseHint();
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(useHint.label, undefined, useHint.value);
}
OnUpgradeStationAvailableEnd(upgradeStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}
getUseHint()
{
	result = spawnStruct();

	remainingRequiredCount = level.ttt.upgradestationAmountRequired - self.placedWeapons.size;
	result.label = &"[ ^3[{+activate}] ^7] to ^3trade-in ^7weapons.";
	result.value = undefined;
	if (self.upgrading) result.label = "";
	else if (remainingRequiredCount > 0)
	{
		if (remainingRequiredCount == 1)
			result.label = &"^3Drop weapons ^7to put up for ^3trade-in^7.\n\n^3&&1 ^7more weapon required.";
		else
			result.label = &"^3Drop weapons ^7to put up for ^3trade-in^7.\n\n^3&&1 ^7more weapons required.";
		result.value = remainingRequiredCount;
	}

	return result;
}
updateUseHint()
{
	useHint = self getUseHint();
	foreach (player in scripts\ttt\use::getUseEntAvailablePlayers(self))
	{
		if (!isDefined(useHint.value))
		{
			player scripts\ttt\ui::destroyUseAvailableHint();
			player scripts\ttt\ui::displayUseAvailableHint(useHint.label);

		}
		player scripts\ttt\ui::updateUseAvailableHint(useHint.label, undefined, useHint.value);
	}
}
