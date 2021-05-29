init()
{
	spas12 = spawnStruct();
	spas12.name = "SPAS-12 SHOTGUN";
	spas12.description = "^3Exclusive weapon\n^7Versatile shotgun with good\nperformance ^2up to medium range^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	spas12.icon = "weapon_spas12";
	spas12.iconWidth = 48;
	spas12.iconHeight = 24;
	spas12.iconOffsetX = 1;
	spas12.onBuy = ::OnBuy;
	spas12.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	spas12.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	spas12.weaponName = "spas12_mp";

	scripts\ttt\items::registerItem(spas12, "detective");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item, 8, 0);
}
