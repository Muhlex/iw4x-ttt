#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	level.ttt.items = [];
	level.ttt.items["traitor"] = [];
	level.ttt.items["detective"] = [];

	level.ttt.items["traitor"][0] = spawnStruct();
	level.ttt.items["traitor"][0].name = "ARMOR";
	level.ttt.items["traitor"][0].description = "^3Passive item\n^7Reduces incoming damage by\n30 percent.";
	level.ttt.items["traitor"][0].icon = "cardicon_vest_1";
	level.ttt.items["traitor"][0].onBuy = ::OnBuyArmor;

	level.ttt.items["traitor"][1] = spawnStruct();
	level.ttt.items["traitor"][1].name = "RADAR";
	level.ttt.items["traitor"][1].description = "^3Passive item\n^7Periodically shows the location\nof all players on the minimap.";
	level.ttt.items["traitor"][1].icon = "specialty_uav";
	level.ttt.items["traitor"][1].onBuy = ::OnBuyRadar;

	level.ttt.items["detective"][0] = spawnStruct();
	level.ttt.items["detective"][0].name = "ARMOR";
	level.ttt.items["detective"][0].description = "^3Passive item\n^7Reduces incoming damage by\n30 percent.";
	level.ttt.items["detective"][0].icon = "cardicon_vest_1";
	level.ttt.items["detective"][0].onBuy = ::OnBuyArmor;

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
	if (isInArray(self.ttt.items.inventory, item)) return;
	if (self.ttt.items.credits < 1) return;

	self [[item.onBuy]]();
	self.ttt.items.credits--;
	self.ttt.items.inventory[self.ttt.items.inventory.size] = item;
	self iPrintLn("^3" + item.name + "^7 received");

	self scripts\ttt\ui::updateBuyMenu(self.ttt.role);
}

OnBuyArmor()
{
	self.ttt.incomingDamageMultiplier = 0.7;
}

OnBuyRadar()
{
	self.isRadarBlocked = false;
	self.hasRadar = true;
}
