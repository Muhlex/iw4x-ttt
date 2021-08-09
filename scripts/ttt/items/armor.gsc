#include scripts\ttt\_util;

init()
{
	armor = spawnStruct();
	armor.name = "ARMOR";
	armor.description = "^3Passive Item\n^7Reduces incoming bullet damage\nby ^2" + ((1 - level.ttt.armorDamageMultiplier) * 100) + " percent^7.\n\nDefault equipment for detectives.";
	armor.icon = "cardicon_vest_1";
	armor.onBuy = ::OnBuy;
	armor.getIsAvailable = scripts\ttt\items::getIsAvailablePassive;
	armor.unavailableHint = &"^1Already wearing armor";
	armor.passiveDisplay = true;

	scripts\ttt\items::registerItem(armor, "traitor");
	scripts\ttt\items::registerItem(armor, "detective");
	scripts\ttt\items::registerItem(armor, undefined, "armor"); // used to set it as a starting item
}

OnBuy()
{
	mods = [];
	mods[0] = "MOD_PISTOL_BULLET";
	mods[1] = "MOD_RIFLE_BULLET";
	self addDamageMultiplier("armor", level.ttt.armorDamageMultiplier, mods, "in");
}
