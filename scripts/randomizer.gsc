#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

getRandomWeapon(type)
{
	weapons = [];
	weapons["primaries"] = [];
	weapons["secondaries"] = [];
	weapons["special"] = [];

	weapons["primaries"][0] = "riotshield";
	weapons["primaries"][1] = "ak47";
	weapons["primaries"][2] = "m16";
	weapons["primaries"][3] = "m4";
	weapons["primaries"][4] = "fn2000";
	weapons["primaries"][5] = "masada";
	weapons["primaries"][6] = "famas";
	weapons["primaries"][7] = "fal";
	weapons["primaries"][8] = "scar";
	weapons["primaries"][9] = "tavor";
	weapons["primaries"][10] = "mp5k";
	weapons["primaries"][11] = "uzi";
	weapons["primaries"][12] = "p90";
	weapons["primaries"][13] = "kriss";
	weapons["primaries"][14] = "ump45";
	weapons["primaries"][15] = "barrett";
	weapons["primaries"][16] = "wa2000";
	weapons["primaries"][17] = "m21";
	weapons["primaries"][18] = "cheytac";
	weapons["primaries"][19] = "rpd";
	weapons["primaries"][20] = "sa80";
	weapons["primaries"][21] = "mg4";
	weapons["primaries"][22] = "m240";
	weapons["primaries"][23] = "aug";
	weapons["primaries"][24] = "peacekeeper";
	weapons["primaries"][25] = "ak47classic";
	weapons["primaries"][26] = "ak74u";
	weapons["primaries"][27] = "m40a3";
	weapons["primaries"][28] = "dragunov";

	weapons["secondaries"][0] ="beretta";
	weapons["secondaries"][1] ="usp";
	weapons["secondaries"][2] ="deserteagle";
	weapons["secondaries"][3] ="coltanaconda";
	weapons["secondaries"][4] ="glock";
	weapons["secondaries"][5] ="beretta393";
	weapons["secondaries"][6] ="pp2000";
	weapons["secondaries"][7] ="tmp";
	weapons["secondaries"][8] ="m79";
	weapons["secondaries"][9] ="rpg";
	weapons["secondaries"][10] ="at4";
	// weapons["secondaries"][11] ="stinger";
	weapons["secondaries"][11] ="javelin";
	weapons["secondaries"][12] ="ranger";
	weapons["secondaries"][13] ="model1887";
	weapons["secondaries"][14] ="striker";
	weapons["secondaries"][15] ="aa12";
	weapons["secondaries"][16] ="m1014";
	weapons["secondaries"][17] ="spas12";
	weapons["secondaries"][18] ="deserteaglegold";
	//weapons["secondaries"][19] ="onemanarmy";

	weapons["special"][0] = "ac130_105mm";
	weapons["special"][1] = "ac130_40mm";
	weapons["special"][2] = "ac130_25mm";
	weapons["special"][3] = "defaultweapon";

	return weapons[type][randomint(weapons[type].size)];
}

getRandomCamo()
{
	camos = [];
	camos[0] = "none";
	camos[1] = "woodland";
	camos[2] = "desert";
	camos[3] = "arctic";
	camos[4] = "digital";
	camos[5] = "red_urban";
	camos[6] = "red_tiger";
	camos[7] = "blue_tiger";
	camos[8] = "orange_fall";

	return camos[randomint(camos.size)];
}

getRandomPerk(slotIndex)
{
	perks = [];
	for (i = 0; i <= 2; i++) perks[i] = [];

	perks[0][0] = "specialty_marathon";
	perks[0][1] = "specialty_fastreload";
	if (!getdvarint("randomizer_infinite_ammo")) perks[0][2] = "specialty_scavenger";
	//perks[0][3] = "specialty_bling";
	//perks[0][4] = "specialty_onemanarmy";

	perks[1][0] = "specialty_bulletdamage";
	perks[1][1] = "specialty_lightweight";
	perks[1][2] = "specialty_hardline";
	perks[1][3] = "specialty_coldblooded";
	perks[1][4] = "specialty_explosivedamage";

	perks[2][0] = "specialty_extendedmelee";
	perks[2][1] = "specialty_bulletaccuracy";
	perks[2][2] = "specialty_localjammer";
	perks[2][3] = "specialty_heartbreaker";
	perks[2][4] = "specialty_detectexplosive";
	perks[2][5] = "specialty_pistoldeath";

	return perks[slotIndex][randomint(perks[slotIndex].size)];
}

getRandomEquipment()
{
	equipment = [];
	equipment[0] = "frag_grenade_mp";
	equipment[1] = "semtex_mp";
	equipment[2] = "throwingknife_mp";
	equipment[3] = "specialty_tacticalinsertion";
	equipment[4] = "specialty_blastshield";
	equipment[5] = "claymore_mp";
	equipment[6] = "c4_mp";

	return equipment[randomint(equipment.size)];
}

getRandomOffhand()
{
	offhands = [];
	offhands[0] = "flash_grenade";
	offhands[1] = "concussion_grenade";
	offhands[2] = "smoke_grenade";

	return offhands[randomint(offhands.size)];
}

getRandomDeathstreak()
{
	deathstreaks = [];
	//deathstreaks[0] = "specialty_copycat";
	deathstreaks[0] = "specialty_combathigh";
	deathstreaks[1] = "specialty_grenadepulldeath";
	deathstreaks[2] = "specialty_finalstand";

	return deathstreaks[randomint(deathstreaks.size)];
}

getRandomAttachmentsForWeapon(weapon, bling)
{
	validWeaponAttachments = [];
	// Retrieve all valid attachments for the specified weapon
	for (i = 11; i <= 20 ; i++)
	{
		attachment = tablelookup("mp/statstable.csv", 4, weapon, i);
		if (attachment != "") validWeaponAttachments[i - 11] = attachment;
	}

	randomAttachments = [];
	if (validWeaponAttachments.size == 0)
		randomAttachments[0] = "none";
	else
		randomAttachments[0] = validWeaponAttachments[randomint(validWeaponAttachments.size)];

	if (!bling) return randomAttachments[0];

	// Columns of "mp/attachmentcombos.csv":
	attachmentComboCols = [];
	attachmentComboCols[0] = "no";
	attachmentComboCols[1] = "reflex";
	attachmentComboCols[2] = "acog";
	attachmentComboCols[3] = "thermal";
	attachmentComboCols[4] = "grip";
	attachmentComboCols[5] = "gl";
	attachmentComboCols[6] = "shotgun";
	attachmentComboCols[7] = "heartbeat";
	attachmentComboCols[8] = "silencer";
	attachmentComboCols[9] = "akimbo";
	attachmentComboCols[10] = "fmj";
	attachmentComboCols[11] = "rof";
	attachmentComboCols[12] = "xmags";
	attachmentComboCols[13] = "eotech";
	attachmentComboCols[14] = "tactical";

	// Remove any attachments incompatible with previous attachments
	for (i = 1; i <= 14; i++)
	{
		isValid = tablelookup("mp/attachmentcombos.csv", 0, randomAttachments[0], i);
		if (isValid == "no") validWeaponAttachments = array_remove(validWeaponAttachments, attachmentComboCols[i]);
	}

	if (validWeaponAttachments.size == 0)
		randomAttachments[1] = "none";
	else
		randomAttachments[1] = validWeaponAttachments[randomint(validWeaponAttachments.size)];
	return randomAttachments;
}

getRandomLoadout()
{
	loadout = spawnstruct();

	primaryType = undefined;
	secondaryType = undefined;

	switch (randomint(3))
	{
		case 0:
			primaryType = "primaries";
			secondaryType = primaryType;
			break;
		case 1:
			primaryType = "secondaries";
			secondaryType = primaryType;
			break;
		default:
			if (randomint(2)) {
				primaryType = "primaries";
				secondaryType = "secondaries";
			} else {
				primaryType = "secondaries";
				secondaryType = "primaries";
			}
			break;
	}

	loadout.weapons = [];
	for (i = 0; i <= 1; i++) loadout.weapons[i] = "none";

	if (randomint(100) < getdvarint("randomizer_special_chance"))
		loadout.weapons[0] = getRandomWeapon("special");
	else
	{
		loadout.weapons[0] = getRandomWeapon(primaryType);
		if (randomint(100) < getdvarint("randomizer_secondary_chance")) loadout.weapons[1] = getRandomWeapon(secondaryType);
	}

	loadout.camos = [];
	for (i = 0; i <= 1; i++) loadout.camos[i] = getRandomCamo();

	loadout.attachments = [];
	for (i = 0; i <= 1; i++)
	{
		loadout.attachments[i] = [];

		switch(randomint(6)) // Make it more likely to get Bling because that's more fun
		{
			case 0:
				loadout.attachments[i][0] = "none";
				loadout.attachments[i][1] = "none";
				break;
			case 1:
			case 2:
				loadout.attachments[i][0] = getRandomAttachmentsForWeapon(loadout.weapons[i], false);
				loadout.attachments[i][1] = "none";
				break;
			default:
				loadout.attachments[i] = getRandomAttachmentsForWeapon(loadout.weapons[i], true);
				break;
		}
	}

	loadout.equipment = getRandomEquipment();
	loadout.perks = [];
	if (!getdvarint("randomizer_perk_streaks")) for (i = 0; i <= 2; i++) loadout.perks[i] = getRandomPerk(i);
	else for (i = 0; i <= 2; i++) loadout.perks[i] = "none";
	loadout.offhand = getRandomOffhand();
	loadout.deathstreak = getRandomDeathstreak();

	return loadout;
}

giveRandomizerLoadout(team, class, loadout, isSpawn)
{
	self takeAllWeapons();

	// initialize specialty array
	self.specialty = [];

	class_num = 0;
	self.class_num = class_num;

	if ( level.killstreakRewards )
	{
		if ( getDvarInt( "scr_classic" ) == 1 )
		{
			loadoutKillstreak1 = "uav";
			loadoutKillstreak2 = "precision_airstrike";
			loadoutKillstreak3 = "helicopter";
		}
		else
		{
			loadoutKillstreak1 = self getPlayerData( "killstreaks", 0 );
			loadoutKillstreak2 = self getPlayerData( "killstreaks", 1 );
			loadoutKillstreak3 = self getPlayerData( "killstreaks", 2 );
		}
	}
	else
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}

	secondaryName = maps\mp\gametypes\_class::buildWeaponName( loadout.weapons[1], loadout.attachments[1][0], loadout.attachments[1][1] );
	self _giveWeapon( secondaryName, int(tableLookup( "mp/camoTable.csv", 1, loadout.camos[1], 0 ) ) );

	self.loadoutPrimary = loadout.weapons[0];
	self.loadoutPrimaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadout.camos[0], 0 ));
	self.loadoutSecondary = loadout.weapons[1];
	self.loadoutSecondaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadout.camos[1], 0 ));

	self SetOffhandPrimaryClass( "other" );

	// Action Slots
	//self _SetActionSlot( 1, "" );
	self _SetActionSlot( 1, "nightvision" );
	self _SetActionSlot( 3, "altMode" );
	self _SetActionSlot( 4, "" );

	// Perks
	self _clearPerks();
	self maps\mp\gametypes\_class::_detachAll();

	// these special case giving pistol death have to come before
	// perk loadout to ensure player perk icons arent overwritten
	if ( level.dieHardMode )
		self maps\mp\perks\_perks::givePerk( "specialty_pistoldeath" );

	// only give the deathstreak for the initial spawn for this life.
	if ( loadout.deathstreak != "specialty_null" && getTime() == self.spawnTime )
	{
		deathVal = int( tableLookup( "mp/perkTable.csv", 1, loadout.deathstreak, 6 ) );

		if ( self maps\mp\gametypes\_class::getPerkUpgrade( loadout.perks[0] ) == "specialty_rollover" || self maps\mp\gametypes\_class::getPerkUpgrade( loadout.perks[1] ) == "specialty_rollover" || self maps\mp\gametypes\_class::getPerkUpgrade( loadout.perks[2] ) == "specialty_rollover" )
			deathVal -= 1;

		if ( self.pers["cur_death_streak"] == deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadout.deathstreak );
			self thread maps\mp\gametypes\_hud_message::splashNotify( loadout.deathstreak );
		}
		else if ( self.pers["cur_death_streak"] > deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadout.deathstreak );
		}
	}

	self maps\mp\gametypes\_class::loadoutAllPerks( loadout.equipment, loadout.perks[0], loadout.perks[1], loadout.perks[2] );
	if (getdvarint("randomizer_perk_streaks")) self GivePerkStreakRewards();

	self maps\mp\gametypes\_class::setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );

	if ( self hasPerk( "specialty_extraammo", true ) && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self giveMaxAmmo( secondaryName );

	// Primary Weapon
	primaryName = maps\mp\gametypes\_class::buildWeaponName( loadout.weapons[0], loadout.attachments[0][0], loadout.attachments[0][1] );
	self _giveWeapon( primaryName, self.loadoutPrimaryCamo );

	// fix changing from a riotshield class to a riotshield class during grace period not giving a shield
	if ( primaryName == "riotshield_mp" && level.inGracePeriod )
		self notify ( "weapon_change", "riotshield_mp" );

	if ( self hasPerk( "specialty_extraammo", true ) )
		self giveMaxAmmo( primaryName );

	if (isSpawn) self setSpawnWeapon( primaryName );
	else self SwitchToWeapon(primaryName);

	primaryTokens = strtok( primaryName, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];

	// Primary Offhand was given by givePerk (it's your perk1)

	// Secondary Offhand
	offhandSecondaryWeapon = loadout.offhand + "_mp";
	if ( loadout.offhand == "flash_grenade" )
		self SetOffhandSecondaryClass( "flash" );
	else
		self SetOffhandSecondaryClass( "smoke" );

	self giveWeapon( offhandSecondaryWeapon );
	if( loadout.offhand == "smoke_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	else if( loadout.offhand == "flash_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else if( loadout.offhand == "concussion_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );

	self.primaryWeapon = primaryName;
	self.secondaryWeapon = secondaryName;

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );
	self.isSniper = (weaponClass( self.primaryWeapon ) == "sniper");

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();

	if (getdvarint("randomizer_infinite_ammo"))
	{
		self SetWeaponAmmoStockToClipsize(primaryName);
		self SetWeaponAmmoStockToClipsize(secondaryName);
	}

	self notify ( "changed_kit" );
	self notify ( "giveLoadout" );
}

initDvars()
{
	d = [];
	d["randomizer"] = 0;
	d["randomizer_interval"] = 0;
	d["randomizer_secondary_chance"] = 33;
	d["randomizer_special_chance"] = 5;
	d["randomizer_infinite_ammo"] = 0;
	d["randomizer_perk_streaks"] = 0;

	foreach (key, value in d) setDvarIfUninitialized(key, value);
}

init()
{
	initDvars();

	enabled = false;
	if (getdvarint("randomizer")) enabled = true;

	level.randomizer = spawnstruct();
	level.randomizer.enabled = enabled;

	if (!enabled) return;

	level.randomizer.loadout = getRandomLoadout();

	level.randomizer.text = createServerFontString("objective", 1.25);
	level.randomizer.text setPoint("TOPRIGHT", "TOPRIGHT", -8, 4);
	level.randomizer.text.color = (1, 1, 1);
	level.randomizer.text.glowColor = (0.3, 0.6, 0.3);
	level.randomizer.text.glowAlpha = 1;
	level.randomizer.text.foreground = false;
	level.randomizer.text.hidewheninmenu = true;
	level.randomizer.text.archived = false;
	level.randomizer.text setText("Randomizer Mode");

	thread OnPrematchOver();
	thread OnPlayerConnect();
	thread OnGameEnd();
}

OnPrematchOver()
{
	level endon("game_ended");

	level waittill("prematch_over");

	interval = getdvarint("randomizer_interval");
	if (!interval) return;

	level.randomizer.timer = createServerFontString("big", 1.15);
	level.randomizer.timer setPoint("TOPRIGHT", "TOPRIGHT", -8, 20);
	level.randomizer.timer.color = (1, 1, 1);
	level.randomizer.timer.foreground = false;
	level.randomizer.timer.hidewheninmenu = true;
	level.randomizer.timer.archived = false;

	level.randomizer.timerSoon = createServerFontString("hudbig", 1);
	level.randomizer.timerSoon setPoint("CENTER", "CENTER", 0, 50);
	level.randomizer.timerSoon.color = (1, 1, 1);
	level.randomizer.timerSoon.glowColor = (0.3, 0.3, 0.85);
	level.randomizer.timerSoon.glowAlpha = 1;
	level.randomizer.timerSoon.foreground = false;
	level.randomizer.timerSoon.hidewheninmenu = true;

	restInterval = interval;

	for(;;)
	{
		restMinutes = int(restInterval / 60);
		restSeconds = (restInterval % 60);
		if (restSeconds < 10) restSeconds = "0" + restSeconds;
		level.randomizer.timer setText("New loadout in " + restMinutes + ":" + restSeconds);
		if (restInterval <= 5)
		{
			level.randomizer.timerSoon setText("" + restInterval);
			foreach (player in level.players) player playLocalSound("mouse_over");
		}
		else if (restInterval == interval) level.randomizer.timerSoon setText(undefined);

		wait(1);
		restInterval--;

		if (restInterval > 0) continue;

		level.randomizer.loadout = getRandomLoadout();

		foreach (player in level.players)
		{
			//player playLocalSound("mouse_click");
			player playLocalSound("mp_suitcase_pickup");
			if (isAlive(player)) player thread SwitchRandomizerLoadout();
		}

		restInterval = interval;
	}
}

OnGameEnd()
{
	level waittill("game_ended");

	level.randomizer.text destroyElem();
	if (level.randomizer.timer) level.randomizer.timer destroyElem();
	if (level.randomizer.timerSoon) level.randomizer.timerSoon destroyElem();
}

OnPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player thread OnPlayerSpawn();
	}
}

OnPlayerSpawn()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		self thread OnPlayerReload();
		self thread OnPlayerKilledEnemy();
	}
}

OnPlayerReload()
{
	level endon("game_ended");

	for(;;)
	{
		self waittill("reload");

		if (getdvarint("randomizer_infinite_ammo"))
		{
			weapon = self getCurrentWeapon();
			self SetWeaponAmmoStockToClipsize(weapon);
		}
	}
}

OnPlayerKilledEnemy()
{
	for (;;)
	{
		self waittill("killed_enemy");

		self GivePerkStreakRewards(true);
	}
}

SwitchRandomizerLoadout()
{
	self endon( "disconnect" );

	reshowPerks = (!getdvarint("randomizer_perk_streaks"));

	self _disableWeapon();
	self _disableOffhandWeapons();
	self _disableUsability();
	if (reshowPerks) self openMenu("perk_hide");
	wait(1);
	self _enableWeapon();
	self _enableOffhandWeapons();
	self _enableUsability();
	self giveRandomizerLoadout(self.team, self.class, level.randomizer.loadout, false);
	if (reshowPerks) self openMenu("perk_display");
}

SetWeaponAmmoStockToClipsize(weapon)
{
	maxClipSize = weaponClipSize(weapon);
	if (issubstr(weapon, "_akimbo")) maxClipSize *= 2;
	self SetWeaponAmmoStock(weapon, maxClipSize);
}

GivePerkStreakRewards(showPerkMenu)
{
	if (!isDefined(showPerkMenu)) showPerkMenu = false;

	currentKillstreak = self.pers["cur_kill_streak"];
	rewardTier = self.pers["cur_kill_streak"];
	if (rewardTier > 3) rewardTier = 3;
	switch(rewardTier)
	{
		case 3:
			self maps\mp\perks\_perks::givePerk("specialty_heartbreaker");
			self maps\mp\perks\_perks::givePerk(maps\mp\gametypes\_class::getPerkUpgrade("specialty_heartbreaker"));
		case 2:
			self maps\mp\perks\_perks::givePerk("specialty_fastreload");
			self maps\mp\perks\_perks::givePerk(maps\mp\gametypes\_class::getPerkUpgrade("specialty_fastreload"));
		case 1:
			self maps\mp\perks\_perks::givePerk("specialty_lightweight");
			self maps\mp\perks\_perks::givePerk(maps\mp\gametypes\_class::getPerkUpgrade("specialty_lightweight"));
			if (showPerkMenu && currentKillstreak < 4) self openMenu("perk_display");
	}
}
