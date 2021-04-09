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
	armor.description = "^3Passive item\n^7Reduces incoming damage by\n30 percent.";
	armor.icon = "cardicon_vest_1";
	armor.onBuy = ::OnBuyArmor;
	armor.getIsAvailable = ::GetIsAvailablePassive;

	level.ttt.items["traitor"][0] = armor;

	level.ttt.items["traitor"][1] = spawnStruct();
	level.ttt.items["traitor"][1].name = "RADAR";
	level.ttt.items["traitor"][1].description = "^3Passive item\n^7Periodically shows the location\nof all players on the minimap.";
	level.ttt.items["traitor"][1].icon = "specialty_uav";
	level.ttt.items["traitor"][1].onBuy = ::OnBuyRadar;
	level.ttt.items["traitor"][1].getIsAvailable = ::GetIsAvailablePassive;

	level.ttt.items["traitor"][2] = spawnStruct();
	level.ttt.items["traitor"][2].name = "RANGER SHOTGUN";
	level.ttt.items["traitor"][2].description = "^3Exclusive weapon\n^7Strong close-range shotgun\nwhich can fire two shells at once.";
	level.ttt.items["traitor"][2].icon = "weapon_ranger";
	level.ttt.items["traitor"][2].iconWidth = 48;
	level.ttt.items["traitor"][2].iconHeight = 24;
	level.ttt.items["traitor"][2].iconOffsetX = -1;
	level.ttt.items["traitor"][2].onBuy = ::OnBuyRanger;
	level.ttt.items["traitor"][2].getIsAvailable = ::GetIsAvailableRanger;

	level.ttt.items["traitor"][3] = spawnStruct();
	level.ttt.items["traitor"][3].name = "ROCKET LAUNCHER";
	level.ttt.items["traitor"][3].description = "^3Exclusive weapon\n^7RPG-7 explosive launcher.\nHolds 2 rockets. Can't pick up ammo.";
	level.ttt.items["traitor"][3].icon = "weapon_rpg7";
	level.ttt.items["traitor"][3].iconWidth = 44;
	level.ttt.items["traitor"][3].iconHeight = 22;
	level.ttt.items["traitor"][3].iconOffsetX = 1;
	level.ttt.items["traitor"][3].onBuy = ::OnBuyRPG;
	level.ttt.items["traitor"][3].getIsAvailable = ::GetIsAvailableRPG;

	level.ttt.items["detective"][0] = armor;

	level.ttt.items["detective"][1] = spawnStruct();
	level.ttt.items["detective"][1].name = "RIOT SHIELD";
	level.ttt.items["detective"][1].description = "^3Exclusive weapon\n^7Blocks bullets,\neven when it is on your back.";
	level.ttt.items["detective"][1].icon = "weapon_riotshield";
	level.ttt.items["detective"][1].iconWidth = 64;
	level.ttt.items["detective"][1].iconHeight = 32;
	level.ttt.items["detective"][1].iconOffsetX = -16;
	level.ttt.items["detective"][1].onBuy = ::OnBuyRiot;
	level.ttt.items["detective"][1].getIsAvailable = ::GetIsAvailableRiot;

	level.ttt.items["detective"][2] = spawnStruct();
	level.ttt.items["detective"][2].name = "SPAS-12 SHOTGUN";
	level.ttt.items["detective"][2].description = "^3Exclusive weapon\n^7Versatile shotgun with good\nperformance up to medium range.";
	level.ttt.items["detective"][2].icon = "weapon_spas12";
	level.ttt.items["detective"][2].iconWidth = 48;
	level.ttt.items["detective"][2].iconHeight = 24;
	level.ttt.items["detective"][2].iconOffsetX = 1;
	level.ttt.items["detective"][2].onBuy = ::OnBuySpas;
	level.ttt.items["detective"][2].getIsAvailable = ::GetIsAvailableSpas;

	foreach (roleItems in level.ttt.items) foreach (item in roleItems) precacheShader(item.icon);
}

initPlayer()
{
	self.ttt.items = spawnStruct();
	self.ttt.items.selectedIndex = 0;
	self.ttt.items.credits = 0;
	self.ttt.items.inventory = [];
}

setStartingCredits()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "traitor") self.ttt.items.credits = getDvarInt("ttt_traitor_start_credits");
	if (self.ttt.role == "detective") self.ttt.items.credits = getDvarInt("ttt_detective_start_credits");
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

tryBuyItem(item)
{
	if (![[item.getIsAvailable]](item)) return;
	if (self.ttt.items.credits < 1) return;

	self thread [[item.onBuy]]();
	self.ttt.items.credits--;
	self.ttt.items.inventory[self.ttt.items.inventory.size] = item;
	self iPrintLn("^3" + item.name + "^7 received");

	self scripts\ttt\ui::updateBuyMenu(self.ttt.role);
}

GetIsAvailablePassive(item)
{
	return !isInArray(self.ttt.items.inventory, item);
}

OnBuyArmor()
{
	self.ttt.incomingDamageMultiplier = 0.7;
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

GetIsAvailableRanger()
{
	WEAPON_NAME = "ranger_mp";
	return !self hasWeapon(WEAPON_NAME);
}

OnBuyRPG()
{
	WEAPON_NAME = "rpg_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoStock(WEAPON_NAME, 1);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
}

GetIsAvailableRPG()
{
	WEAPON_NAME = "rpg_mp";
	return !self hasWeapon(WEAPON_NAME);
}

OnBuyRiot()
{
	WEAPON_NAME = "riotshield_mp";
	self giveWeapon(WEAPON_NAME);
	self.hasRiotShield = true;
	self AttachShieldModel("weapon_riot_shield_mp", "tag_shield_back");
}

GetIsAvailableRiot()
{
	WEAPON_NAME = "riotshield_mp";
	return !self hasWeapon(WEAPON_NAME);
}

OnBuySpas()
{
	WEAPON_NAME = "spas12_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoStock(WEAPON_NAME, 0);
	self setWeaponAmmoClip(WEAPON_NAME, 8);
}

GetIsAvailableSpas()
{
	WEAPON_NAME = "spas12_mp";
	return !self hasWeapon(WEAPON_NAME);
}
