init()
{
	precacheModel("thed");

	thread OnPrematchOver();
	thread OnPlayerConnect();
}

OnPrematchOver()
{
	level waittill("prematch_over");

	thedRain = getDvarFloat("thed_rain");
	if (thedRain > 0) thread rainTheDs(thedRain, 30);
}

OnPlayerConnect()
{
	level endon("game_ended");

	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerSpawn();
	}
}

OnPlayerSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		if (getDvarInt("thed_players") && !level.intermission) self attachPlayerD(!!getDvarInt("thed_players_damage"));
	}
}

attachPlayerD(damageable)
{
	if (!isDefined(damageable)) damageable = false;

	angles = combineAngles(self getTagAngles("pelvis"), (0, 90, 90));
	origin = self getTagOrigin("pelvis");
	origin += anglesToForward(angles) * 5;
	origin += anglesToUp(angles) * -3;

	thed = spawn("script_model", origin);
	thed.angles = angles;
	thed linkTo(self, "pelvis");
	thed.owner = self;
	thed setModel("thed");

	if (damageable)
	{
		thed setCanDamage(true);
		thed.maxhealth = 99999999;
		thed.health = thed.maxhealth;
		thed thread OnDDamage();
	}

	thed thread OnDPlayerDeath();
}

OnDDamage()
{
	self endon("death");
	self.owner endon("death");
	self.owner endon("disconnect");

	for (;;)
	{
		self waittill("damage", damage, attacker, direction, point, type, modelName, tagName, partName, flags);
		if (!isDefined(self.owner)) break;

		if (type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET") type = "MOD_HEAD_SHOT";

		self.owner thread [[level.callbackPlayerDamage]](
			attacker, // eInflictor The entity that causes the damage. ( e.g. a turret )
			attacker, // eAttacker The entity that is attacking.
			damage, // iDamage Integer specifying the amount of damage done
			flags, // iDFlags Integer specifying flags that are to be applied to the damage
			type, // sMeansOfDeath Integer specifying the method of death
			"none", // sWeapon The weapon number of the weapon used to inflict the damage
			point, // vPoint The point the damage is from?
			direction, // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
		);
	}
}

OnDPlayerDeath()
{
	self endon("death");

	self.owner waittill("death");
	wait 30;
	self delete();
}

getLevelAirstrikeHeight()
{
	heightEnt = getEnt("airstrikeheight", "targetname");

	if (isDefined(heightEnt))
		return heightEnt.origin[2];
	else if (isDefined(level.airstrikeHeightScale))
		return 850 * level.airstrikeHeightScale;
	else
		return 850;
}

deleteDelayed(delay)
{
	wait delay;
	self delete();
}

rainTheDs(delay, liveTime, amount)
{
	infinite = false;
	if (!isDefined(delay)) delay = 0.5;
	if (!isDefined(amount))
	{
		amount = 0;
		infinite = true;
	}

	height = getLevelAirstrikeHeight() + 300;

	for (i = 0; (i < amount) || infinite; i++)
	{
		rainSingleD(height, liveTime);
		wait delay;
	}
}

rainSingleD(height, liveTime)
{
	origin = [];
	for (i = 0; i <= 1; i++) origin[i] = randomFloatRange(level.spawnMins[i], level.spawnMaxs[i]);
	origin = (origin[0], origin[1], height);

	thed = spawn("script_model", origin);
	thed setModel("thed");
	thed physicsLaunchServer(thed.origin, (randomFloatRange(-20, 20), randomFloatRange(-20, 20), randomFloat(30)));

	if (isDefined(liveTime)) thed thread deleteDelayed(liveTime);
}
