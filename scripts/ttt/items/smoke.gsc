init()
{
	smoke = spawnStruct();
	smoke.name = "NINJA SMOKE BOMB";
	smoke.description = "^3Exclusive special grenade\n^2Fast-thrown^7, ^2cluster ^7smoke grenade.\nDetonates ^2instantly ^7on impact.\n\nPress [ ^3[{+smoke}]^7 ] to throw.";
	smoke.icon = "weapon_smokegrenade";
	smoke.onBuy = ::OnBuy;
	smoke.getIsAvailable = scripts\ttt\items::getIsAvailableOffhand;
	smoke.unavailableHint = scripts\ttt\items::getUnavailableHint("offhand");

	scripts\ttt\items::registerItem(smoke, "traitor");
}

OnBuy()
{
	WEAPON_NAME = "smoke_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self SetOffhandSecondaryClass("smoke");

	self thread OnSmokeThrow();
}

OnSmokeThrow()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		self waittill("grenade_fire", grenade, weaponName);
		if (weaponName != "smoke_grenade_mp") continue;

		grenade thread OnSmokeExplode(self.angles);
		break;
	}
}

OnSmokeExplode(throwAngles)
{
	self endon("end_explode");

	self waittill("explode", origin);

	EFFECTS_COUNT = 6;

	for (i = 0; i < EFFECTS_COUNT; i++)
	{
		wait(0.1);

		forwardVector = anglesToForward(combineAngles(throwAngles, (0, 360 / EFFECTS_COUNT * i, 0)));
		// move up
		effectOrigin = physicsTrace(origin, origin + (0, 0, 64));
		// save resulting pos and how far it was moved upwards
		horizTraceStartMovedUp = effectOrigin[2] - origin[2];
		horizTraceStartOrigin = effectOrigin;
		// move horizontally
		effectOrigin = physicsTrace(effectOrigin, effectOrigin + forwardVector * 512);
		// don't spawn if smoke would be inside/behind the origin (not enough space)
		if (distance(horizTraceStartOrigin, effectOrigin) < 128) continue;
		effectOrigin -= forwardVector * 128;
		// move back down
		effectOrigin = physicsTrace(effectOrigin, effectOrigin - (0, 0, horizTraceStartMovedUp));

		playFX(level.ttt.effects.smokeGrenade, effectOrigin);
		playSoundAtPos(effectOrigin, "smokegrenade_explode_default");

	}
}
