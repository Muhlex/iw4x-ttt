init()
{
	armor = spawnStruct();
	armor.name = "ARMOR";
	armor.description = "^3Passive item\n^7Reduces incoming bullet damage\nby ^220 percent^7.\n\nDefault equipment for detectives.";
	armor.icon = "cardicon_vest_1";
	armor.onBuy = ::OnBuy;
	armor.getIsAvailable = scripts\ttt\items::getIsAvailablePassive;
	armor.unavailableHint = &"^1Already wearing armor";

	scripts\ttt\items::registerItem(armor, "traitor");
	scripts\ttt\items::registerItem(armor, "detective");
	scripts\ttt\items::registerItem(armor, undefined, "armor"); // used to be set as a starting item
}

OnBuy()
{
	self.ttt.incomingDamageMultiplier = 0.8;
	self scripts\ttt\ui::updatePlayerArmorDisplay();
}
