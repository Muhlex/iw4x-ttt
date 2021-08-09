init()
{
	claymore = spawnStruct();
	claymore.name = "CLAYMORE";
	claymore.description = "^3Equipment\n^7Triggers on anyone ^1including yourself^7.\nArms ^3" + getDvarFloat("ttt_claymore_delay") + " ^7sec after placement.\n\nPress [ ^3[{+frag}]^7 ] to set down.";
	claymore.icon = "equipment_claymore";
	claymore.iconOffsetX = 1;
	claymore.onBuy = ::OnBuy;
	claymore.getIsAvailable = scripts\ttt\items::getIsAvailableEquipment;
	claymore.unavailableHint = scripts\ttt\items::getUnavailableHint("equipment");

	scripts\ttt\items::registerItem(claymore, "traitor");
}

OnBuy()
{
	self endon("disconnect");
	self endon("death");

	WEAPON_NAME = "claymore_mp";

	self takeWeapon("throwingknife_mp");
	self setOffhandPrimaryClass("other");
	self maps\mp\perks\_perks::givePerk(WEAPON_NAME);

	for (;;)
	{
		self waittill("grenade_fire", claymore, grenadeWeaponName);
		if (grenadeWeaponName != WEAPON_NAME) continue;
		self scripts\ttt\items::resetPlayerEquipment();
	}
}
