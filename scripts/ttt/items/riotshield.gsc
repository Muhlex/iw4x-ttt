init()
{
	riotshield = spawnStruct();
	riotshield.name = "RIOT SHIELD";
	riotshield.description = "^3Exclusive weapon\n^2Blocks bullets^7, even when it is\non your back.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	riotshield.icon = "weapon_riotshield";
	riotshield.iconWidth = 64;
	riotshield.iconHeight = 32;
	riotshield.iconOffsetX = -16;
	riotshield.onBuy = ::OnBuy;
	riotshield.onPickup = ::OnPickup;
	riotshield.onDrop = ::OnDrop;
	riotshield.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	riotshield.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	riotshield.weaponName = "riotshield_mp";

	scripts\ttt\items::registerItem(riotshield, "detective");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item);
	self OnPickup();
}
OnPickup()
{
	self.hasRiotShield = true;
	self AttachShieldModel("weapon_riot_shield_mp", "tag_shield_back");
}
OnDrop()
{
	self.hasRiotShield = false;
	self DetachShieldModel("weapon_riot_shield_mp", "tag_shield_back");
}
