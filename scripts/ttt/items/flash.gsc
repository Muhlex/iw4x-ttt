init()
{
	flash = spawnStruct();
	flash.name = "2x FLASHBANG";
	flash.description = "^3Offhand Grenade\n^2Blinds ^7anyone who is caught in\nor looking at the explosion.\n\nPress [ ^3[{+smoke}]^7 ] to throw.";
	flash.icon = "weapon_flashbang";
	flash.onBuy = ::OnBuy;
	flash.getIsAvailable = scripts\ttt\items::getIsAvailableOffhand;
	flash.unavailableHint = scripts\ttt\items::getUnavailableHint("offhand");

	scripts\ttt\items::registerItem(flash, "traitor");
}

OnBuy()
{
	WEAPON_NAME = "flash_grenade_mp";
	self setOffhandSecondaryClass("flash");
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 2);
}
