init()
{
	flash = spawnStruct();
	flash.name = "FLASHBANG";
	flash.description = "^3Exclusive special grenade\n^2Blinds ^7anyone who is caught in\nor looking at the explosion.\n\nPress [ ^3[{+smoke}]^7 ] to throw.";
	flash.icon = "weapon_flashbang";
	flash.onBuy = ::OnBuy;
	flash.getIsAvailable = scripts\ttt\items::getIsAvailableOffhand;
	flash.unavailableHint = scripts\ttt\items::getUnavailableHint("offhand");

	scripts\ttt\items::registerItem(flash, "traitor");
}

OnBuy()
{
	WEAPON_NAME = "flash_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self SetOffhandSecondaryClass("flash");
}
