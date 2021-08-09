#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\ttt\_util;

init()
{
	precacheShader("hud_suitcase_bomb");

	bomb = spawnStruct();
	bomb.name = "BOMB";
	bomb.description = "^3Deployable Active Item\n^7Causes a ^2huge explosion ^7after ^3" + getDvarInt("ttt_bomb_timer") + " ^7sec.\nCan be ^1defused^7. Emits a ^1sound^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	bomb.activateHint = &"Hold [ ^3[{+attack}]^7 ] to ^3plant ^7the bomb";
	bomb.icon = "hud_suitcase_bomb";
	bomb.onBuy = ::OnBuy;
	bomb.onActivate = ::OnActivate;
	bomb.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	bomb.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	bomb.weaponName = "onemanarmy_mp";
	if (level.ttt.modEnabled) bomb.weaponName = "oma_bomb_mp";

	scripts\ttt\items::registerItem(bomb, "traitor");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item);
}

OnActivate(item)
{
	self endon("disconnect");
	self endon("death");

	self notify("ttt_planting_bomb");
	self endon("ttt_planting_bomb");

	BOMB_WEAPON = "briefcase_bomb_mp";

	self giveWeapon(BOMB_WEAPON);
	self setWeaponAmmoClip(BOMB_WEAPON, 0);
	self setWeaponAmmoStock(BOMB_WEAPON, 0);
	self switchToWeapon(BOMB_WEAPON);

	self thread OnBombInteractionInterrupt();

	TIMEOUT = 1.5 * 1000;
	startTime = getTime();
	while (self getCurrentWeapon() != BOMB_WEAPON || !self isOnGround())
	{
		wait(0.05);
		if (startTime + TIMEOUT < getTime())
		{
			if (self getCurrentWeapon() == BOMB_WEAPON) switchToLastWeapon();
			self notify("ttt_bomb_interaction_canceled");
			return;
		}
	}

	// self playSound("mp_bomb_plant");
	self freezePlayer();
	self thread attachBombModel();

	self thread activateBombThink(item);
}

activateBombThink(item)
{
	self endon("disconnect");
	self endon("death");

	BOMB_WEAPON = "briefcase_bomb_mp";
	PLANT_TIME = 4.0 * 1000;
	plantStartTime = getTime();

	for (;;)
	{
		wait(0.05);

		if (self.ttt.items.roleInventory.item != item || self getCurrentWeapon() != BOMB_WEAPON || (!self attackButtonPressed() && !self useButtonPressed()))
		{
			self stopBombInteraction();
			return;
		}

		if (plantStartTime + PLANT_TIME > getTime()) continue;

		self notify("ttt_planted_bomb");

		self stopBombInteraction(true, BOMB_WEAPON);

		bombEnt = spawn("script_model", self.origin);
		bombEnt.angles = self.angles + (0, -90, 0);
		bombEnt setModel("prop_suitcase_bomb");
		bombEnt.owner = self;
		bombEnt.killCamEnt = spawn("script_model", self.origin + (0, 0, maps\mp\killstreaks\_airdrop::getFlyHeightOffset(self.origin)));
		bombEnt.objectName = "ttt_bomb";

		bombEnt showBomb();

		level.ttt.bombs[level.ttt.bombs.size] = bombEnt;
		updateBombHuds();

		self scripts\ttt\items::takeRoleWeapon();
		self switchToLastWeapon();
		self scripts\ttt\items::resetRoleInventory();

		bombEnt thread OnBombDeath();
		bombEnt thread bombThink(self);

		return;
	}
}

OnDefuse(bombEnt)
{
	self endon("disconnect");
	self endon("death");
	bombEnt endon("death");

	if (isDefined(bombEnt.interactingPlayer)) return;

	self notify("ttt_defusing_bomb");
	self endon("ttt_defusing_bomb");

	BOMB_WEAPON = "briefcase_bomb_defuse_mp";

	if (!maps\mp\gametypes\_weapons::mayDropWeapon(self getCurrentWeapon())) return;

	self giveWeapon(BOMB_WEAPON);
	self setWeaponAmmoClip(BOMB_WEAPON, 0);
	self setWeaponAmmoStock(BOMB_WEAPON, 0);
	self switchToWeapon(BOMB_WEAPON);

	bombEnt hideBomb(self);

	self thread OnBombInteractionInterrupt(bombEnt);

	TIMEOUT = 1.5 * 1000;
	startTime = getTime();
	while (self getCurrentWeapon() != BOMB_WEAPON || !self isOnGround())
	{
		wait(0.05);
		if (startTime + TIMEOUT < getTime())
		{
			if (self getCurrentWeapon() == BOMB_WEAPON) switchToLastWeapon();
			bombEnt showBomb();
			self notify("ttt_bomb_interaction_canceled");
			return;
		}
	}

	self playSound("mp_bomb_defuse");
	self freezePlayer();
	self thread attachBombModel();

	self thread defuseBombThink(bombEnt);
}

defuseBombThink(bombEnt)
{
	self endon("disconnect");
	self endon("death");
	bombEnt endon("death");

	BOMB_WEAPON = "briefcase_bomb_defuse_mp";
	DEFUSE_TIME = 4.0 * 1000;
	defuseStartTime = getTime();

	for (;;)
	{
		wait(0.05);

		if (self getCurrentWeapon() != BOMB_WEAPON || (!self attackButtonPressed() && !self useButtonPressed()))
		{
			self stopBombInteraction();
			bombEnt showBomb();
			return;
		}

		if (defuseStartTime + DEFUSE_TIME > getTime()) continue;

		if (randomFloat(1.0) < getDvarFloat("ttt_bomb_defuse_failure_pct"))
		{
			bombEnt thread explodeBomb();
			return;
		}

		self notify("ttt_defused_bomb");

		self stopBombInteraction(true, BOMB_WEAPON);

		bombEnt.killCamEnt delete();
		bombEnt.fxEnt delete();
		bombEnt delete();

		return;
	}
}

showBomb()
{
	self show();
	self.interactingPlayer = undefined;
	self.fxEnt = spawnFX(level.ttt.effects.bombBlink, self.origin + (0, 0, 2) + anglesToRight(self.angles) * 3);
	triggerFx(self.fxEnt);
	self scripts\ttt\use::makeUsableCustom(
		::OnDefuse,
		::OnBombEntAvailable,
		::OnBombEntAvailableEnd
	);
}

hideBomb(player)
{
	self.interactingPlayer = player;
	self hide();
	self.fxEnt delete();
	self scripts\ttt\use::makeUnusableCustom();
}

stopBombInteraction(isDone, bombWeaponName)
{
	if (!isDefined(isDone)) isDone = false;

	self notify("ttt_bomb_interaction_canceled");

	self unfreezePlayer();
	self thread detachBombModel();
	if (isDone)
	{
		self setWeaponAmmoClip(bombWeaponName, 1);
		self setWeaponAmmoStock(bombWeaponName, 1);
	}
	if (isAlive(self)) self switchToLastWeapon();
}

OnBombInteractionInterrupt(bombEnt)
{
	self endon("ttt_planted_bomb");
	self endon("ttt_defused_bomb");
	self endon("ttt_bomb_interaction_canceled");

	self waittill_any("disconnect", "death");

	self stopBombInteraction();
	if (isDefined(bombEnt)) bombEnt showBomb();
}

attachBombModel()
{
	self endon("death");
	self endon("disconnect");
	self endon("ttt_bomb_interaction_canceled");

	self thread detachBombModel();

	wait(0.4);

	self attach("prop_suitcase_bomb", "tag_inhand", true);
}
detachBombModel()
{
	self endon("death");
	self endon("disconnect");

	wait(0.15);

	self detach("prop_suitcase_bomb", "tag_inhand");
}

OnBombEntAvailable(bombEnt)
{
	label = &"Hold [ ^3[{+activate}] ^7] to ^3defuse^7 the bomb\n\n^7Explodes in: ^1";
	if (getDvarFloat("ttt_bomb_defuse_failure_pct") > 0.0)
		label = &"Hold [ ^3[{+activate}] ^7] to ^3risk defusing^7 the bomb\n\n^7Explodes in: ^1";
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(
		label,
		undefined,
		getBombSecondsRemaining(bombEnt)
	);
}
OnBombEntAvailableEnd(bombEnt)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

getBombSecondsRemaining(bombEnt)
{
	return max(0, ceil(getDvarInt("ttt_bomb_timer") - (getTime() - bombEnt.birthtime) / 1000));
}

OnBombDeath()
{
	self waittill("death");

	level.ttt.bombs = array_remove(level.ttt.bombs, self);
	updateBombHuds();
	if (isDefined(self.interactingPlayer)) self.interactingPlayer stopBombInteraction();
}

bombThink()
{
	self endon("death");

	TICK_SOUND = "weap_fraggrenade_pin";
	if (level.ttt.modEnabled) TICK_SOUND = "bomb_tick_world";

	for (;;)
	{
		wait(1.0);

		updateBombHuds();

		secondsRemaining = getBombSecondsRemaining(self);
		self playSound(TICK_SOUND);
		if (secondsRemaining <= 10) self thread playSoundDelayed(TICK_SOUND, 0.5);
		if (secondsRemaining <= 5)
		{
			self thread playSoundDelayed(TICK_SOUND, 0.25);
			self thread playSoundDelayed(TICK_SOUND, 0.75);
		}

		foreach (player in scripts\ttt\use::getUseEntAvailablePlayers(self))
			player scripts\ttt\ui::updateUseAvailableHint(undefined, undefined, secondsRemaining);

		if (secondsRemaining > 0) continue;

		self thread explodeBomb();
	}
}

explodeBomb()
{
	RADIUS = getDvarInt("ttt_bomb_radius");

	foreach (player in getLivingPlayers())
	{
		distance = distance(self.origin, player.origin);
		damageNormalized = 1 - distance / RADIUS;
		if (damageNormalized <= 0) continue;
		damage = int(damageNormalized * level.ttt.maxhealth * 3);

		player thread [[level.callbackPlayerDamage]](
			self, // eInflictor The entity that causes the damage. ( e.g. a turret )
			self.owner, // eAttacker The entity that is attacking.
			damage, // iDamage Integer specifying the amount of damage done
			level.iDFLAGS_RADIUS, // iDFlags Integer specifying flags that are to be applied to the damage
			"MOD_EXPLOSIVE", // sMeansOfDeath Integer specifying the method of death
			"none", // sWeapon The weapon number of the weapon used to inflict the damage
			self.origin, // vPoint The point the damage is from?
			vectorNormalize(player.origin - self.origin), // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
		);
	}

	damageableEnts = [];
	damageableEnts = array_combine(getEntArray("grenade", "classname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("misc_turret", "classname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("ttt_destructible_item", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("destructible_toy", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("destructible_vehicle", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("explodable_barrel", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("vending_machine", "targetname"), damageableEnts);

	foreach (ent in damageableEnts)
	{
		distance = distance(self.origin, ent.origin);
		damageNormalized = 1 - distance / RADIUS;
		if (damageNormalized <= 0) continue;
		damage = int(damageNormalized * 1000);

		ent notify(
			"damage",
			damage, // damage
			self.owner, // attacker
			vectorNormalize(ent.origin - self.origin), // direction_vec
			self.origin, // point
			"MOD_EXPLOSIVE", // type
			"", // modelName
			"", // tagName
			"", // partName
			level.iDFLAGS_RADIUS // iDFlags
		);
	}

	scriptVehicles = getEntArray("script_vehicle", "classname");

	foreach (vehicle in scriptVehicles)
	{
		distance = distance(self.origin, vehicle.origin);
		damageNormalized = 1 - distance / (RADIUS * 1.5);
		if (damageNormalized <= 0) continue;
		damage = int(damageNormalized * 2000);

		if (vehicle.damageTaken + damage >= vehicle.maxhealth) vehicle.largeProjectileDamage = true;
		vehicle maps\mp\gametypes\_callbacksetup::CodeCallback_VehicleDamage(
			self,
			self.owner,
			damage,
			0,
			"MOD_EXPLOSIVE",
			"none",
			self.origin,
			vehicle.origin - self.origin,
			"none",
			0,
			0,
			""
		);
	}

	/*
	foreach (player in level.players)
	{
		player thread drawDebugLine(self.origin - (RADIUS, 0, 0), self.origin + (RADIUS, 0, 0), (1, 0, 0), 120);
		player thread drawDebugLine(self.origin - (0, RADIUS, 0), self.origin + (0, RADIUS, 0), (0, 1, 0), 120);
		player thread drawDebugLine(self.origin - (0, 0, RADIUS), self.origin + (0, 0, RADIUS), (0, 0, 1), 120);

		player thread drawDebugCircle(self.origin, RADIUS / 1.5, (1, 0.5, 0.5), 600);
		player thread drawDebugCircle(self.origin, RADIUS, (1, 1, 1), 600);
	}
	*/

	glassRadiusDamage(self.origin + (0, 0, 24), RADIUS, 300, 20);
	physicsExplosionSphere(self.origin, RADIUS + 512, RADIUS, 2.5);
	earthquake(0.75, 2.0, self.origin, RADIUS * 2);
	self playSound("exp_suitcase_bomb_main");
	playFX(level.ttt.effects.bombExplosion, self.origin);

	if (RADIUS >= 640)
	{
		FX_COUNT = 8;
		for (i = 0; i < FX_COUNT; i++)
		{
			forward = anglesToForward(combineAngles((0, 360 / FX_COUNT * i, 0), (0, randomFloatRange(-10, 10), 0)));
			thread playFXDelayed(
				level.ttt.effects.bombOuterExplosion,
				self.origin + forward * (RADIUS - 800) + (0, 0, randomIntRange(-128, 384)),
				randomFloatRange(0.05, 0.8)
			);
		}
	}

	self.killCamEnt delete();
	self.fxEnt delete();
	self delete();
}

updateBombHuds()
{
	foreach (player in level.players)
	{
		player destroyBombHud();
		player displayBombHud();
	}
}

displayBombHud()
{
	if ((isAlive(self) && (!isDefined(self.ttt.role) || self.ttt.role != "traitor")) || self.ttt.items.inBuyMenu) return;

	self.ttt.ui["hud"]["self"]["bombs"] = [];

	foreach(i, bombEnt in level.ttt.bombs)
	{
		self.ttt.ui["hud"]["self"]["bombs"][i] = [];

		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] = newClientHudElem(self);
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] setShader("hud_suitcase_bomb");
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"].color = (1, 0.3, 0.3);
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"].alpha = 0.5;
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] setWaypoint(true, true);
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] setTargetEnt(bombEnt);

		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] = self createIcon("hud_suitcase_bomb", 24, 24);
		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"].color = (1, 0.3, 0.3);
		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"].hidewheninmenu = true;
		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] setPoint("TOP RIGHT", "TOP RIGHT", -20, 60);
		if (i > 0)
		{
			self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] setParent(self.ttt.ui["hud"]["self"]["bombs"][i - 1]["icon"]);
			self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] setPoint("TOP LEFT", "TOP LEFT", 0, 24 + 12);
		}

		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] = self createFontString("default", 1.5);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] setParent(self.ttt.ui["hud"]["self"]["bombs"][i]["icon"]);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] setPoint("BOTTOM RIGHT ", "BOTTOM RIGHT", 2, 2);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"].color = (1, 1, 1);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"].hidewheninmenu = true;
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"].foreground = true;
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] setValue(scripts\ttt\items\bomb::getBombSecondsRemaining(bombEnt));
	}
}

destroyBombHud()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["bombs"]);
}
