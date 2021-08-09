init()
{
	ranger = spawnStruct();
	ranger.name = "RANGER SHOTGUN";
	ranger.description = "^3Active Item\n^7Strong close-range shotgun\nwhich can fire ^2two shells at once^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	ranger.icon = "weapon_ranger";
	ranger.iconWidth = 48;
	ranger.iconHeight = 24;
	ranger.iconOffsetX = -1;
	ranger.onBuy = ::OnBuy;
	ranger.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	ranger.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	ranger.weaponName = "ranger_mp";

	scripts\ttt\items::registerItem(ranger, "traitor");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item, 2, 0);
}
