init()
{
	lehtaldrop = spawnStruct();
	lehtaldrop.name = "INSANE BICEPS";
	lehtaldrop.description = "^3Passive item\n^7Drop weapons with ^2deadly velocity^7.\nDeal ^2more damage ^7at far distances.\n\nPress [ ^3[{+actionslot 1}]^7 ] to throw a weapon.";
	lehtaldrop.icon = "specialty_onemanarmy_upgrade";
	lehtaldrop.onBuy = ::OnBuy;
	lehtaldrop.getIsAvailable = scripts\ttt\items::getIsAvailablePassive;
	lehtaldrop.unavailableHint = &"^1You can't get more muscular than this";

	scripts\ttt\items::registerItem(lehtaldrop, "detective");
}

OnBuy()
{
	self.ttt.pickups.dropVelocity = 512;
	self.ttt.pickups.dropCanDamage = true;
}
