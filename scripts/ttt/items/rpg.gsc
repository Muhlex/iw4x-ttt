init()
{
	rpg = spawnStruct();
	rpg.name = "ROCKET LAUNCHER";
	rpg.description = "^3Active Item\n^7RPG-7 explosive launcher.\nHolds ^31 ^7rocket. ^1Can't pick up ammo^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	rpg.icon = "weapon_rpg7";
	rpg.iconWidth = 44;
	rpg.iconHeight = 22;
	rpg.iconOffsetX = 1;
	rpg.onBuy = ::OnBuy;
	rpg.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	rpg.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	rpg.weaponName = "rpg_mp";

	scripts\ttt\items::registerItem(rpg, "traitor");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item, 1, 0);
}
