#include scripts\ttt\_util;

init()
{
	healthstation = spawnStruct();
	healthstation.name = "HEALTH STATION";
	healthstation.description = "^3Deployable item\n^7Slowly ^2regenerates health ^7on use.\nCan be placed anywhere.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	healthstation.activateHint = &"Press [ ^3[{+attack}]^7 ] to ^3place ^7the health station";
	healthstation.icon = "hint_health";
	healthstation.onBuy = ::OnBuy;
	healthstation.onActivate = ::OnActivate;
	healthstation.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	healthstation.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	healthstation.weaponName = "onemanarmy_mp";
	if (level.ttt.modEnabled) healthstation.weaponName = "oma_healthstation_mp";

	scripts\ttt\items::registerItem(healthstation, "detective");
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
		self iPrintLnBold("You cannot place a health station here");
		return;
	}

	self scripts\ttt\items::takeRoleWeapon();
	self switchToLastWeapon();
	self scripts\ttt\items::resetRoleInventory();

	healthStation = spawn("script_model", spawnPos);
	healthStation.targetname = "ttt_destructible_item";
	healthStation setModel("com_plasticcase_friendly");
	healthStation.angles = self.angles + (0, 90, 0);
	healthStation cloneBrushmodelToScriptmodel(level.airDropCrateCollision);
	healthStation physicsLaunchServer();
	healthStation.hp = int(level.ttt.maxhealth * 2);
	healthStation.lastDispenseTime = 0;
	healthStation.inUse = false;

	healthStation setCanDamage(true);
	healthStation.maxhealth = 500;
	healthStation.health = healthStation.maxhealth;
	healthStation.damageTaken = 0;
	healthStation thread OnHealthStationDamage();
	healthStation thread OnHealthStationDeath();

	healthStation scripts\ttt\use::makeUsableCustom(
		::OnHealthStationTrigger,
		::OnHealthStationAvailable,
		::OnHealthStationAvailableEnd, 80, 45, 0, true
	);
}

OnHealthStationDamage()
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

OnHealthStationDeath()
{
	self waittill("death", attacker);

	attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
	playFX(level._effect["sentry_explode_mp"], self.origin);
	self playSound("sentry_explode");
	wait(4);
	self delete();
}

OnHealthStationTrigger(healthStation)
{
	if (healthStation.inUse) return;

	healthStation.inUse = true;
	self thread healthStationUseThink(healthStation);
}

healthStationUseThink(healthStation)
{
	healthStation endon("death");

	ticksUsed = 0;

	while (isAlive(self) && self useButtonPressed() && self scripts\ttt\use::isUseEntAvailable(healthStation))
	{
		if (healthStation.lastDispenseTime <= getTime() - 100 && healthStation.hp > 0 && self.health < level.ttt.maxhealth)
		{
			self.health++;
			self.maxhealth = self.health;
			healthStation.hp--;
			healthStation.lastDispenseTime = getTime();

			if (healthStation.hp <= 0) healthStation notify("death");

			if (ticksUsed == 0) healthStation playSound("intelligence_pickup");
			else if (ticksUsed % 2 == 1) healthStation playSound("gear_rattle_sprint");

			foreach (player in scripts\ttt\use::getUseEntAvailablePlayers(healthStation))
				player scripts\ttt\ui::updateUseAvailableHint(undefined, undefined, healthStation.hp);

			ticksUsed++;
		}

		wait(0.05);
	}

	healthStation.inUse = false;
}

OnHealthStationAvailable(healthStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(
		&"Hold [ ^3[{+activate}] ^7] to ^3heal^7 yourself\n\nAvailable health: ^2",
		undefined,
		healthStation.hp
	);
}
OnHealthStationAvailableEnd(healthStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}
