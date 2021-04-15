#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	level.ttt.items = [];
	level.ttt.items["traitor"] = [];
	level.ttt.items["detective"] = [];

	armor = spawnStruct();
	armor.name = "ARMOR";
	armor.description = "^3Passive item\n^7Reduces incoming bullet damage\nby ^220 percent^7.\n\nDefault equipment for detectives.";
	armor.icon = "cardicon_vest_1";
	armor.onBuy = ::OnBuyArmor;
	armor.getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["traitor"][0] = armor;

	level.ttt.items["traitor"][1] = spawnStruct();
	level.ttt.items["traitor"][1].name = "RADAR";
	level.ttt.items["traitor"][1].description = "^3Passive item\n^7Periodically shows the location\nof all players on the minimap.";
	level.ttt.items["traitor"][1].icon = "specialty_uav";
	level.ttt.items["traitor"][1].onBuy = ::OnBuyRadar;
	level.ttt.items["traitor"][1].getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["traitor"][2] = spawnStruct();
	level.ttt.items["traitor"][2].name = "RANGER SHOTGUN";
	level.ttt.items["traitor"][2].description = "^3Exclusive weapon\n^7Strong close-range shotgun\nwhich can fire ^2two shells at once^7.";
	level.ttt.items["traitor"][2].icon = "weapon_ranger";
	level.ttt.items["traitor"][2].iconWidth = 48;
	level.ttt.items["traitor"][2].iconHeight = 24;
	level.ttt.items["traitor"][2].iconOffsetX = -1;
	level.ttt.items["traitor"][2].onBuy = ::OnBuyRanger;
	level.ttt.items["traitor"][2].getIsAvailable = ::getIsAvailableRanger;

	level.ttt.items["traitor"][3] = spawnStruct();
	level.ttt.items["traitor"][3].name = "ROCKET LAUNCHER";
	level.ttt.items["traitor"][3].description = "^3Exclusive weapon\n^7RPG-7 explosive launcher.\nHolds 1 rocket. ^1Can't pick up ammo^7.";
	level.ttt.items["traitor"][3].icon = "weapon_rpg7";
	level.ttt.items["traitor"][3].iconWidth = 44;
	level.ttt.items["traitor"][3].iconHeight = 22;
	level.ttt.items["traitor"][3].iconOffsetX = 1;
	level.ttt.items["traitor"][3].onBuy = ::OnBuyRPG;
	level.ttt.items["traitor"][3].getIsAvailable = ::getIsAvailableRPG;

	level.ttt.items["traitor"][4] = spawnStruct();
	level.ttt.items["traitor"][4].name = "THROWING KNIFE";
	level.ttt.items["traitor"][4].description = "^3Exclusive equipment\n^7Kills ^2silently^7. Can be ^2picked up\n^7by anyone after throwing.";
	level.ttt.items["traitor"][4].icon = "equipment_throwing_knife";
	level.ttt.items["traitor"][4].iconOffsetX = 1;
	level.ttt.items["traitor"][4].onBuy = ::OnBuyKnife;
	level.ttt.items["traitor"][4].getIsAvailable = ::getIsAvailableEquipment;

	level.ttt.items["traitor"][5] = spawnStruct();
	level.ttt.items["traitor"][5].name = "CLAYMORE";
	level.ttt.items["traitor"][5].description = "^3Exclusive equipment\n^7Triggers for anyone (^1for yourself too^7).\n^2Highlighted to other traitors^7.";
	level.ttt.items["traitor"][5].icon = "equipment_claymore";
	level.ttt.items["traitor"][5].iconOffsetX = 1;
	level.ttt.items["traitor"][5].onBuy = ::OnBuyClaymore;
	level.ttt.items["traitor"][5].getIsAvailable = ::getIsAvailableEquipment;

	level.ttt.items["traitor"][6] = spawnStruct();
	level.ttt.items["traitor"][6].name = "FLASHBANG";
	level.ttt.items["traitor"][6].description = "^3Exclusive special grenade\n^2Blinds ^7anyone who is caught in\nor looking at the explosion.";
	level.ttt.items["traitor"][6].icon = "weapon_flashbang";
	level.ttt.items["traitor"][6].onBuy = ::OnBuyFlash;
	level.ttt.items["traitor"][6].getIsAvailable = ::getIsAvailableOffhand;

	level.ttt.items["detective"][0] = armor;

	level.ttt.items["detective"][1] = spawnStruct();
	level.ttt.items["detective"][1].name = "RIOT SHIELD";
	level.ttt.items["detective"][1].description = "^3Exclusive weapon\n^2Blocks bullets^7, even when\nit is on your back.";
	level.ttt.items["detective"][1].icon = "weapon_riotshield";
	level.ttt.items["detective"][1].iconWidth = 64;
	level.ttt.items["detective"][1].iconHeight = 32;
	level.ttt.items["detective"][1].iconOffsetX = -16;
	level.ttt.items["detective"][1].onBuy = ::OnBuyRiot;
	level.ttt.items["detective"][1].getIsAvailable = ::getIsAvailableRiot;

	level.ttt.items["detective"][2] = spawnStruct();
	level.ttt.items["detective"][2].name = "SPAS-12 SHOTGUN";
	level.ttt.items["detective"][2].description = "^3Exclusive weapon\n^7Versatile shotgun with good\nperformance ^2up to medium range^7.";
	level.ttt.items["detective"][2].icon = "weapon_spas12";
	level.ttt.items["detective"][2].iconWidth = 48;
	level.ttt.items["detective"][2].iconHeight = 24;
	level.ttt.items["detective"][2].iconOffsetX = 1;
	level.ttt.items["detective"][2].onBuy = ::OnBuySpas;
	level.ttt.items["detective"][2].getIsAvailable = ::getIsAvailableSpas;

	level.ttt.items["detective"][3] = spawnStruct();
	level.ttt.items["detective"][3].name = "STUN GRENADE";
	level.ttt.items["detective"][3].description = "^3Exclusive special grenade\n^2Disorients ^7and ^2slows ^7targets\ncaught in the explosion.";
	level.ttt.items["detective"][3].icon = "weapon_concgrenade";
	level.ttt.items["detective"][3].onBuy = ::OnBuyConcussion;
	level.ttt.items["detective"][3].getIsAvailable = ::getIsAvailableOffhand;

	level.ttt.items["detective"][4] = spawnStruct();
	level.ttt.items["detective"][4].name = "INSANE BICEPS";
	level.ttt.items["detective"][4].description = "^3Passive item\n^7Allows you to ^2lob weapons\n^7like crazy.";
	level.ttt.items["detective"][4].icon = "specialty_onemanarmy_upgrade";
	level.ttt.items["detective"][4].onBuy = ::OnBuyLob;
	level.ttt.items["detective"][4].getIsAvailable = ::getIsAvailablePassive;

	foreach (roleItems in level.ttt.items) foreach (item in roleItems) precacheShader(item.icon);
}

initPlayer()
{
	self.ttt.items = spawnStruct();
	self.ttt.items.selectedIndex = 0;
	self.ttt.items.credits = 0;
	self.ttt.items.inventory = [];
}

resetPlayerEquipment()
{
	// Make anyone able to pick up throwing knives:
	self giveWeapon("throwingknife_mp");
	self setWeaponAmmoClip("throwingknife_mp", 0); // remove the '1' ammo from the throwing knife weapon
	self SetOffhandPrimaryClass("throwingknife"); // set throwing knife as 'active' equipment so it can be used once picked up
}

setStartingCredits()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "traitor") self.ttt.items.credits = getDvarInt("ttt_traitor_start_credits");
	if (self.ttt.role == "detective") self.ttt.items.credits = getDvarInt("ttt_detective_start_credits");
}

setStartingItems()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "detective") self giveItem(level.ttt.items["detective"][0]);
}

awardCredits(amount)
{
	if (amount < 1) return;

	self.ttt.items.credits += amount;
	feedback = "You received ^1" + amount + "^7 store credits";
	if (amount == 1) feedback = "You received ^1" + amount + "^7 store credit";
	self iPrintLn(feedback);
}

awardKillCredits(victim)
{
	if (!isDefined(self.ttt.role) || !isDefined(victim.ttt.role)) return;

	if (self.ttt.role == "traitor" && victim.ttt.role != "traitor")
		self scripts\ttt\items::awardCredits(getDvarInt("ttt_traitor_kill_credits"));
	else if (self.ttt.role == "detective" && victim.ttt.role == "traitor")
		self scripts\ttt\items::awardCredits(getDvarInt("ttt_detective_kill_credits"));
}

awardBodyInspectCredits(victim)
{
	if (!isDefined(self.ttt.role) || !isDefined(victim.ttt.role)) return;

	if (self.ttt.role == "detective" && victim.ttt.role == "traitor")
	{
		self awardCredits(victim.ttt.items.credits);
		victim.ttt.items.credits = 0;
	}
}

giveItem(item)
{
	self thread [[item.onBuy]]();
	self.ttt.items.inventory[self.ttt.items.inventory.size] = item;
	self iPrintLn("^3" + item.name + "^7 received");
}

tryBuyItem(item)
{
	if (![[item.getIsAvailable]](item)) return;
	if (self.ttt.items.credits < 1) return;

	self giveItem(item);
	self.ttt.items.credits--;

	self scripts\ttt\ui::updateBuyMenu(self.ttt.role, undefined, undefined, true);
}

getIsAvailablePassive(item)
{
	return !isInArray(self.ttt.items.inventory, item);
}

getCanPlayerBuyWeapons()
{
	return self getWeaponsListPrimaries().size < 3;
}

getIsAvailableEquipment()
{
	EQUIPMENT_ITEMS = [];
	EQUIPMENT_ITEMS[0] = "frag_grenade_mp";
	EQUIPMENT_ITEMS[1] = "semtex_mp";
	EQUIPMENT_ITEMS[2] = "throwingknife_mp";
	EQUIPMENT_ITEMS[3] = "specialty_tacticalinsertion";
	EQUIPMENT_ITEMS[4] = "specialty_blastshield";
	EQUIPMENT_ITEMS[5] = "claymore_mp";
	EQUIPMENT_ITEMS[6] = "c4_mp";

	foreach (equipment in EQUIPMENT_ITEMS)
	{
		if (!self hasWeapon(equipment)) continue;
		if (self getWeaponAmmoClip(equipment) > 0) return false;
	}

	return true;
}

getIsAvailableOffhand()
{
	OFFHAND_ITEMS = [];
	OFFHAND_ITEMS[0] = "smoke_grenade_mp";
	OFFHAND_ITEMS[1] = "flash_grenade_mp";
	OFFHAND_ITEMS[2] = "concussion_grenade_mp";

	foreach (offhand in OFFHAND_ITEMS)
	{
		if (!self hasWeapon(offhand)) continue;
		if (self getWeaponAmmoClip(offhand) > 0) return false;
	}

	return true;
}

OnBuyArmor()
{
	self.ttt.incomingDamageMultiplier = 0.8;
}

OnBuyRadar()
{
	self endon("disconnect");
	self endon("death");

	self.isRadarBlocked = false;
	RADAR_INTERVAL = 10;

	for (;;)
	{
		self.hasRadar = true;
		wait(4);
		self.hasRadar = false;
		wait(RADAR_INTERVAL - 4);
	}
}

OnBuyRanger()
{
	WEAPON_NAME = "ranger_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoStock(WEAPON_NAME, 0);
	self setWeaponAmmoClip(WEAPON_NAME, 2);
}

getIsAvailableRanger()
{
	return self getCanPlayerBuyWeapons() && !self hasWeapon("ranger_mp");
}

OnBuyRPG()
{
	WEAPON_NAME = "rpg_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoStock(WEAPON_NAME, 0);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
}

getIsAvailableRPG()
{
	return self getCanPlayerBuyWeapons() && !self hasWeapon("rpg_mp");
}

OnBuyKnife()
{
	WEAPON_NAME = "throwingknife_mp";
	self setWeaponAmmoClip(WEAPON_NAME, 1);
}

OnBuyClaymore()
{
	self endon("disconnect");
	self endon("death");

	WEAPON_NAME = "claymore_mp";

	self takeWeapon("throwingknife_mp");
	self setOffhandPrimaryClass("other");
	self maps\mp\perks\_perks::givePerk(WEAPON_NAME);

	for (;;)
	{
		self waittill("grenade_fire", claymore, grenadeWeaponName);
		if (grenadeWeaponName != WEAPON_NAME) continue;
		self resetPlayerEquipment();
	}
}

OnBuyFlash()
{
	WEAPON_NAME = "flash_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self SetOffhandSecondaryClass("flash");
}

OnBuyRiot()
{
	WEAPON_NAME = "riotshield_mp";
	self giveWeapon(WEAPON_NAME);
	self.hasRiotShield = true;
	self AttachShieldModel("weapon_riot_shield_mp", "tag_shield_back");
}

getIsAvailableRiot()
{
	return self getCanPlayerBuyWeapons() && !self hasWeapon("riotshield_mp");
}

OnBuySpas()
{
	WEAPON_NAME = "spas12_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoStock(WEAPON_NAME, 0);
	self setWeaponAmmoClip(WEAPON_NAME, 8);
}

getIsAvailableSpas()
{
	return self getCanPlayerBuyWeapons() && !self hasWeapon("spas12_mp");
}

OnBuyConcussion()
{
	WEAPON_NAME = "concussion_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self SetOffhandSecondaryClass("smoke");
}

OnBuyLob()
{
	self.ttt.dropVelocity = 512;
}
