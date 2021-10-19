#include scripts\ttt\_util;

init()
{
	precacheShader("ballistic_overlay");
	if (level.ttt.modEnabled)
	{
		precacheModel("com_plasticcase_black");
		precacheModel("com_plasticcase_juggernaut");
		precacheModel("body_complete_juggernaut");
		precacheModel("viewhands_juggernaut_ally");
	}

	juggernaut = spawnStruct();
	juggernaut.name = "JUGGERNAUT";
	juggernaut.description = "^3Airdropped Passive Item\n^7Greatly ^2reduce incoming damage^7.\n^1Slow movement^7 and ^1hipfire only^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip airdrop marker.";
	juggernaut.icon = "cardicon_juggernaut_1";
	juggernaut.onBuy = ::OnBuy;
	juggernaut.onEquip = ::OnEquip;
	juggernaut.onUnequip = ::OnUnequip;
	juggernaut.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	juggernaut.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	juggernaut.weaponName = "airdrop_marker_mp";
	juggernaut.juggernautPlayers = [];

	scripts\ttt\items::registerItem(juggernaut, "detective");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item, 0, 1);
}

OnEquip(item)
{
	self endon("ttt_items_juggernaut_marker_unequipped");

	for (;;)
	{
		self waittill("grenade_fire", grenade, weaponName);

		if (!maps\mp\killstreaks\_airdrop::isAirdropMarker(weaponName))
			continue;

		grenade thread OnMarkerStuck();
		grenade thread OnMarkerExplode(item);
		self scripts\ttt\items::resetRoleInventory();
	}
}

OnUnequip(item)
{
	self notify("ttt_items_juggernaut_marker_unequipped");
}

OnMarkerStuck()
{
	self waittill("missile_stuck");

	self detonate();
}

OnMarkerExplode(item)
{
	self waittill("explode", position);

	dropCrate(position, item);
}

dropCrate(position, item)
{
	wait(5.0);
	height = maps\mp\killstreaks\_airdrop::getFlyHeightOffset(position);

	crate = spawn("script_model", position + (0, 0, height));
	if (level.ttt.modEnabled)
		crate setModel("com_plasticcase_black");
	else
		crate setModel("com_plasticcase_enemy");

	if (level.ttt.modEnabled)
	{
		crate.logoCrate = spawn("script_model", crate.origin);
		crate.logoCrate.angles = crate.angles;
		crate.logoCrate setModel("com_plasticcase_juggernaut");
		crate.logoCrate notSolid();
		crate.logoCrate linkTo(crate);
	}

	crate cloneBrushmodelToScriptmodel(level.airDropCrateCollision);
	crate physicsLaunchServer();
	crate.item = item;
	crate thread OnCratePhysicsFinish();
}

OnCratePhysicsFinish()
{
	self endon("death");

	self waittill("physics_finished");

	self scripts\ttt\use::makeUsableCustom(
		::OnCrateTrigger,
		::OnCrateAvailable,
		::OnCrateAvailableEnd,
		80, 45, 0, true
	);
}

OnCrateTrigger(crate)
{
	if (isInArray(crate.item.juggernautPlayers, self)) return;

	crate.item.juggernautPlayers[crate.item.juggernautPlayers.size] = self;
	// self playLocalSound("ammo_crate_use");
	self giveJuggernaut();

	crate scripts\ttt\use::makeUnusableCustom();
	if (level.ttt.modEnabled) crate.logoCrate delete();
	crate delete();
}

OnCrateAvailable(healthStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(&"[ ^3[{+activate}] ^7] to ^3equip Juggernaut ^7armor.");
}
OnCrateAvailableEnd(healthStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

giveJuggernaut()
{
	mods = [];
	mods["bullet"][0] = "MOD_PISTOL_BULLET";
	mods["bullet"][1] = "MOD_RIFLE_BULLET";
	mods["bullet"][2] = "MOD_HEAD_SHOT";
	mods["explosive"][0] = "MOD_EXPLOSIVE";
	mods["explosive"][1] = "MOD_PROJECTILE";
	mods["explosive"][2] = "MOD_PROJECTILE_SPLASH";
	mods["explosive"][3] = "MOD_GRENADE";
	mods["explosive"][4] = "MOD_GRENADE_SPLASH";
	self addDamageMultiplier("juggernaut_bullet", level.ttt.juggernautDamageMultiplierBullet, mods["bullet"], "in");
	self addDamageMultiplier("juggernaut_explosive", level.ttt.juggernautDamageMultiplierExplosive, mods["explosive"], "in");
	self addSpeedMultiplier("juggernaut", level.ttt.juggernautSpeedMultiplier);

	self allowAds(false);
	self allowSprint(false);

	if (level.ttt.modEnabled)
	{
		self setPlayerModel("body_complete_juggernaut");
		self setViewmodel("viewhands_juggernaut_ally");
	}
	else
		self setPlayerModel(game[self.team + "_model"]["RIOT"]);

	self playLocalSound("item_blast_shield_on");
	self playLocalSound("tactical_spawn");

	self visionSetNakedForPlayer("black_bw", 0.25);
	wait(0.25);
	self displayJuggernautHud();
	self visionSetNakedForPlayer(getDvar("mapname"), 0.4);
}

displayJuggernautHud()
{
	vignette = newClientHudElem(self);
	vignette.horzAlign = "fullscreen";
	vignette.vertAlign = "fullscreen";
	vignette setShader("ballistic_overlay", 640, 480);
	vignette.sort = 1;
	vignette.alpha = 0.85;
	self.ttt.ui["hud"]["self"]["juggernaut"]["vignette"] = vignette;
}
