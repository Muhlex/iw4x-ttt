#include common_scripts\utility;

init()
{
	throwingknife = spawnStruct();
	throwingknife.name = "THROWING KNIFE";
	throwingknife.description = "^3Equipment\n^7Kills ^2silently^7. Can be ^2picked up\n^7by anyone if it doesn't kill.\n\nPress [ ^3[{+frag}]^7 ] to throw.";
	throwingknife.icon = "equipment_throwing_knife";
	throwingknife.iconOffsetX = 1;
	throwingknife.onBuy = ::OnBuy;
	throwingknife.getIsAvailable = scripts\ttt\items::getIsAvailableEquipment;
	throwingknife.unavailableHint = scripts\ttt\items::getUnavailableHint("equipment");

	scripts\ttt\items::registerItem(throwingknife, "traitor");
	thread OnThrowingKnifePlayerHit();
}

OnBuy()
{
	WEAPON_NAME = "throwingknife_mp";
	self setWeaponAmmoClip(WEAPON_NAME, 1);
}

OnThrowingKnifePlayerHit()
{
	for (;;)
	{
		level waittill("player_damage", eVictim, eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

		if (sWeapon != "throwingknife_mp") continue;
		eInflictor makeUnusable();
	}
}
