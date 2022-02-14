// TODO:
// - make sure script_gameobjectname = "bombzone" isnt a problem
// - make it work with scavenger
// - extinguish on existing smoke (track smokes and extinguish when incen intersects)

#include common_scripts\utility;

init()
{
	setDvarIfUninitialized("scr_incendiary_duration", 6.0);
	setDvarIfUninitialized("scr_incendiary_radius", 176.0);
	setDvarIfUninitialized("scr_incendiary_damage", 50);
	setDvarIfUninitialized("scr_incendiary_flame_radius", 72);
	setDvarIfUninitialized("scr_incendiary_flame_height", 96);

	level.incendiary = spawnStruct();
	level.incendiary.effects = [];
	level.incendiary.effects["flying"] = loadFX("fire/firelp_small_pm_a");
	level.incendiary.effects["drip"] = loadFX("fire/fire_smoke_trail_m");
	level.incendiary.effects["explosion"] = loadFX("explosions/artillery_flash");
	level.incendiary.effects["fire_scorch"] = loadFX("explosions/tanker_explosion_child");
	level.incendiary.effects["fire_ground"] = loadFX("fire/tank_fire_turret_small");
	level.incendiary.effects["fire_center"] = loadFX("fire/jet_afterburner");
	level.incendiary.effects["fire_dynlight"] = loadFX("misc/outdoor_motion_light");
	// misc/glow_stick_glow_red // red glow and light
	// misc/flares_cobra // huge but nice falling flare thingys
	level.incendiary.models = [];
	level.incendiary.models["projectile"] = "projectile_at4";

	level.incendiary.fires = [];

	foreach (model in level.incendiary.models)
		precacheModel(model);

	precacheShader("hud_burningbarrelicon");

	waittillframeend;

	level.incendiary.origFuncs = spawnStruct();
	level.incendiary.origFuncs.callbackPlayerConnect = level.callbackPlayerConnect;
	level.incendiary.origFuncs.callbackPlayerDamage = level.callbackPlayerDamage;
	level.incendiary.origFuncs.callbackPlayerKilled = level.callbackPlayerKilled;
	level.incendiary.origFuncs.getSpawnPoint = level.getSpawnPoint;
	level.callbackPlayerConnect = ::OnPlayerConnect;
	level.callbackPlayerDamage = ::OnPlayerDamage;
	level.callbackPlayerKilled = ::OnPlayerKilled;
	level.getSpawnPoint = ::getSpawnPoint;
}

// ##### START PUBLIC #####

giveIncendiary()
{
	self.hasIncendiary = true;

	self takeWeapon("flash_grenade_mp");
	self takeWeapon("smoke_grenade_mp");
	self takeWeapon("concussion_grenade_mp");

	WEAPON_NAME = "concussion_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self setOffhandSecondaryClass("smoke");
	self setWeaponHudIconOverride("secondaryoffhand", "hud_burningbarrelicon");
}

takeIncendiary()
{
	self.hasIncendiary = false;

	self takeWeapon("concussion_grenade_mp");
	self setWeaponHudIconOverride("secondaryoffhand", "none");
}

// giveSmoke()
// {
// 	self takeWeapon("flash_grenade_mp");
// 	self takeWeapon("smoke_grenade_mp");
// 	self takeWeapon("concussion_grenade_mp");

// 	WEAPON_NAME = "smoke_grenade_mp";
// 	self giveWeapon(WEAPON_NAME);
// 	self setWeaponAmmoClip(WEAPON_NAME, 1);
// 	self setOffhandSecondaryClass("smoke");
// }

spawnFire(position, radius, duration, owner, killCamEnt)
{
	points = getFirePoints(position, radius);
	origins = [];

	foreach (point in points)
	{
		if (point.inAir)
		{
			// Don't spawn a flame mid-air. Hint at placement failure:
			playFX(level.incendiary.effects["fire_scorch"], point.origin);
			playSoundAtPos(point.origin, "fire_drip_splash");
			continue;
		}

		origins[origins.size] = point.origin;
		point delete();
	}

	if (origins.size < 1) return;

	fire = spawn("script_origin", origins[0]);
	fire.owner = owner;
	fire.radius = radius;
	fire.duration = duration;
	fire.flameRadius = getDvarInt("scr_incendiary_flame_radius");
	fire.flameHeight = getDvarInt("scr_incendiary_flame_radius");
	// fire.birthtime = getTime();
	fire.triggers = [];
	fire.players = [];
	fire.extinguishQueued = false;
	fire.killCamEnt = killCamEnt;
	fire.script_gameobjectname = "bombzone"; // this forces killCamEnt to be used and hopefully has no side effects

	foreach (origin in origins)
	{
		trigger = spawn("trigger_radius", origin, 0, fire.flameRadius, fire.flameHeight);
		fire.triggers[fire.triggers.size] = trigger;
		trigger thread OnFireTriggerTouch(fire);
		trigger thread OnFireTriggerThink(fire);
	}

	playFX(level.incendiary.effects["explosion"], origins[0] + (0, 0, 16));
	fire thread playFireFXCenter(origins[0]);
	fire thread playFireFXScorch(origins[0]);

	for (i = 1; i < origins.size; i++)
	{
		fire thread playFireFXScorch(origins[i]);
		fire thread playFireFXGround(origins[i]);
	}

	if (isDefined(duration)) fire thread OnFireDurationEnd();

	level.incendiary.fires[level.incendiary.fires.size] = fire;

	return fire;
}

deleteFire()
{
	foreach (trigger in self.triggers)
		trigger delete();
	foreach (playerdata in self.players)
		playerdata delete();

	self.killCamEnt delete();

	level.incendiary.fires = array_remove(level.incendiary.fires, self);
	self delete();
}

// ##### END PUBLIC #####

OnPlayerConnect()
{
	self [[level.incendiary.origFuncs.callbackPlayerConnect]]();

	self.hasIncendiary = false;
	self thread OnPlayerSpawn();
	self thread OnPlayerIncendiaryThrow();
}

OnPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// Prevent stun effect from being applied (and anything else a stun grenade does to players).
	if (isDefined(eInflictor.isIncendiary) && eInflictor.isIncendiary && sMeansOfDeath == "MOD_GRENADE_SPLASH")
		return;

	self [[level.incendiary.origFuncs.callbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

OnPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self [[level.incendiary.origFuncs.callbackPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);

	if (self.hasIncendiary)
	{
		self setWeaponHudIconOverride("secondaryoffhand", "none");
		self.hasIncendiary = false;
	}
}

OnPlayerSpawn()
{
	// self endon("disconnect");

	// for (;;)
	// {
	// 	self waittill("spawned_player");

	// 	self giveIncendiary();
	// }
}

OnPlayerIncendiaryThrow()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("grenade_fire", grenade, weaponName);
		// if (weaponName == "smoke_grenade_mp") self giveIncendiary();
		if (weaponName != "concussion_grenade_mp") continue;
		if (!self.hasIncendiary) continue;

		grenade.isIncendiary = true;
		killCamEnt = grenade createKillcamEnt(); // used for flame kills only (not grenade impact kills)
		grenade thread OnIncendiaryExplode(self, killCamEnt);
		grenade thread createProjectileVisuals();
		self setWeaponHudIconOverride("secondaryoffhand", "none");

		// self giveSmoke();
	}
}

OnIncendiaryProjectileThink()
{
	self endon("death");

	wait 0.1;

	for (i = 0; true; i++)
	{
		self thread playDripFX(i);
		wait 0.05;
	}
}

OnIncendiaryExplode(owner, killCamEnt)
{
	self waittill("explode", position);

	self thread deleteProjectileVisuals();
	killCamEnt unlink();
	spawnFire(
		position,
		getDvarFloat("scr_incendiary_radius"),
		getDvarFloat("scr_incendiary_duration"),
		owner,
		killCamEnt
	);
}

OnFireDurationEnd()
{
	self endon("death");

	wait self.duration;

	self deleteFire();
}

OnFireTriggerTouch(fire)
{
	self endon("death");

	for (;;)
	{
		self waittill("trigger", player);
		playerdata = fire.players[player.guid];

		if (!isDefined(playerdata))
		{
			playerdata = spawnStruct();
			playerdata.lastTouchTime = -1000000;
			fire.players[player.guid] = playerdata;
		}

		time = getTime();

		if ((time - playerdata.lastTouchTime) / 1000 < 0.25) continue;

		timeAlive = (time - fire.birthtime) / 1000;
		timeAliveScale = min(timeAlive / 6.0 + 0.4, 1);
		distance = distance(player.origin, fire.origin);
		minDamageDistance = fire.radius + 128;
		distanceScale = 1 - min(distance / minDamageDistance, 1);
		damage = int(timeAliveScale * distanceScale * getDvarInt("scr_incendiary_damage"));

		player thread [[level.callbackPlayerDamage]](
			fire, // eInflictor The entity that causes the damage. ( e.g. a turret )
			fire.owner, // eAttacker The entity that is attacking.
			damage, // iDamage Integer specifying the amount of damage done
			level.iDFLAGS_RADIUS | level.iDFLAGS_NO_KNOCKBACK, // iDFlags Integer specifying flags that are to be applied to the damage
			"MOD_TRIGGER_HURT", // sMeansOfDeath Integer specifying the method of death
			"nuke_mp", // sWeapon The weapon number of the weapon used to inflict the damage
			fire.origin, // vPoint The point the damage is from?
			vectorNormalize(player.origin - fire.origin), // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
		);

		if (timeAlive > 1.2) player shellShock("frag_grenade_mp", damage * 0.04);

		playerdata.lastTouchTime = time;
		fire.players[player.guid] = playerdata;
	}
}

OnFireTriggerThink(fire)
{
	self endon("death");

	triggerRadiusSq = fire.flameRadius * fire.flameRadius;

	for (i = 0; true; i++)
	{
		grenades = getEntArray("grenade", "classname");
		foreach (grenade in grenades)
		{
			if (grenade.model != "projectile_us_smoke_grenade") continue;
			if (fire.extinguishQueued) continue;
			if (distanceSquared(self.origin, grenade.origin) > triggerRadiusSq) continue;

			fire.extinguishQueued = true;
			grenade thread OnSmokeFireExtinguish(fire);
		}

		if (i % 5 != 0) continue;

		foreach (ent in getDamageableEnts())
		{
			if (distanceSquared(self.origin, ent.origin) > triggerRadiusSq) continue;

			ent notify(
				"damage",
				50, // damage
				fire.owner, // attacker
				vectorNormalize(ent.origin - fire.origin), // direction_vec
				fire.origin, // point
				"MOD_TRIGGER_HURT", // type
				"", // modelName
				"", // tagName
				"", // partName
				level.iDFLAGS_RADIUS | level.iDFLAGS_NO_KNOCKBACK // iDFlags
			);
		}

		wait 0.1;
	}
}

OnSmokeFireExtinguish(fire)
{
	self waittill("explode", position);

	wait 0.4;

	fire playSound("veh_tire_deflate_decay");
	fire deleteFire();
}

getSpawnPoint()
{
	spawnPoint = undefined;

	for (i = 0; i < 3; i++)
	{
		spawnpoint = [[level.incendiary.origFuncs.getSpawnPoint]]();
		inFire = false;

		foreach (fire in level.incendiary.fires)
		{
			if (!(fire getPositionIsInFire(spawnPoint.origin))) continue;

			inFire = true;

			// Put in fake values for the spawnpoint to make it as unlikely to be picked as possible.
			// These are updated per tick, so no worries about resetting the values.
			if (level.teambased)
			{
				spawnPoint.sights["axis"] = 10;
				spawnPoint.sights["allies"] = 10;
			}
			else
				spawnPoint.sights = 10;

			spawnpoint.minDist["all"] = 0;
			spawnpoint.minDist["allies"] = 0;
			spawnpoint.minDist["axis"] = 0;

			break;
		}

		if (!inFire) break;
	}

	return spawnPoint;
}

getPositionIsInFire(position)
{
	foreach (trigger in self.triggers)
	{
		radius = self.flameRadius + 32;
		if (distanceSquared(position * (1, 1, 0), trigger.origin * (1, 1, 0)) < radius * radius)
			return true;
	}

	return false;
}

createKillcamEnt()
{
	ent = spawn("script_model", self.origin);
	ent setModel("tag_origin");
	ent linkTo(self);
	return ent;
}

createProjectileVisuals()
{
	self hide();
	vismodel = spawn("script_model", self.origin);
	vismodel setModel(level.incendiary.models["projectile"]);
	vismodel linkTo(self);
	vismodel thread OnIncendiaryProjectileThink();
	self.vismodel = vismodel;

	wait 0.05;
	playFXOnTag(level.incendiary.effects["flying"], self.vismodel, "tag_origin");
}

deleteProjectileVisuals()
{
	stopFXOnTag(level.incendiary.effects["flying"], self.vismodel, "tag_origin");
	self.vismodel delete();
}

playDripFX(index)
{
	if (index % 5 == 0 || index % 4 == 1)
		self playSound("fire_drip_splash");

	playFX(level.incendiary.effects["drip"], self.origin);
}

playFireFXCenter(origin)
{
	fxAnchor = spawn("script_model", origin);
	fxAnchor.angles = (-90, 0, 0);
	fxAnchor setModel("tag_origin");

	fxAnchor playSound("flashbang_explode_layer");
	for (i = 0; i < 3; i++) fxAnchor playSound("fire_drip_splash");
	fxAnchor playLoopSound("fire_wood_large");

	self thread playFireFXCenter_playFxOnTag(fxAnchor);

	self waittill("death"); // cannot have a wait before this!!

	stopFXOnTag(level.incendiary.effects["fire_center"], fxAnchor, "tag_origin");
	stopFXOnTag(level.incendiary.effects["fire_dynlight"], fxAnchor, "tag_origin");

	wait 0.1;

	fxAnchor stopLoopSound();

	fxAnchor delete();
}
playFireFXCenter_playFxOnTag(fxAnchor)
{
	self endon("death");

	wait 0.05;

	playFXOnTag(level.incendiary.effects["fire_center"], fxAnchor, "tag_origin");
	playFXOnTag(level.incendiary.effects["fire_dynlight"], fxAnchor, "tag_origin");
}

playFireFXScorch(origin)
{
	self endon("death");

	FX_DURATION = 0.25;
	for (;;)
	{
		playFX(level.incendiary.effects["fire_scorch"], origin + (0, 0, 12));
		wait FX_DURATION;
	}
}

playFireFXGround(origin)
{
	self endon("death");

	FX_DURATION = 2.1;
	for (;;)
	{
		playFX(level.incendiary.effects["fire_ground"], origin);
		wait FX_DURATION;
	}
}

getFirePoints(position, radius)
{
	SPACING = 64;
	count = int((radius / SPACING) * (radius / SPACING));
	vertRadius = radius * 0.75;

	origins = [];
	origins[0] = position;

	points = [];

	foreach (i, origin in getSunflowerPattern(position, count, SPACING))
	{
		bestTraceOut = [];
		bestTraceOut["fraction"] = 0.0;

		for (j = vertRadius; j >= 0; j -= int(vertRadius / 16))
		{
			traceUp = bulletTrace(position, position + (0, 0, j), false);
			traceOut = bulletTrace(traceUp["position"], origin, false);

			if (traceOut["fraction"] > bestTraceOut["fraction"])
			{
				bestTraceOut = traceOut;
				if (traceOut["fraction"] == 1.0) break;
			};
		}

		traceNormal = bulletTrace(
			bestTraceOut["position"],
			bestTraceOut["position"] + bestTraceOut["normal"] * 16,
			false
		);

		origins[origins.size] = traceNormal["position"];
	}

	foreach (origin in origins)
	{
		point = spawnStruct();

		traceDown = bulletTrace(origin + (0, 0, 4), origin - (0, 0, radius * 0.8), false);
		point.origin = traceDown["position"];
		point.inAir = (traceDown["fraction"] == 1.0);

		points[points.size] = point;
	}

	return points;
}

getSunflowerPattern(position, count, spacing)
{
	PHI = 1.6180339887;
	PI = 3.1415926536;
	THETA = 2 * PI / (PHI * PHI);
	TO_DEG = 180 / PI;
	BASE_ANGLE = randomInt(360);

	result = [];

	for (i = 1; i <= count; i++)
	{
		angle = i * THETA * TO_DEG;
		radius = sqrt(i) * spacing;

		result[i - 1] = position + anglesToForward((0, BASE_ANGLE + angle, 0)) * radius;
	}

	return result;
}

drawDebugPoint(pos, color, ticks)
{
	thread scripts\ttt\_util::drawDebugLine((pos[0] + 1, pos[1] + 1, pos[2] + 1), (pos[0] - 1, pos[1] - 1, pos[2] - 1), color, ticks);
	thread scripts\ttt\_util::drawDebugLine((pos[0] - 1, pos[1] + 1, pos[2] + 1), (pos[0] + 1, pos[1] - 1, pos[2] - 1), color, ticks);
	thread scripts\ttt\_util::drawDebugLine((pos[0] + 1, pos[1] - 1, pos[2] + 1), (pos[0] - 1, pos[1] + 1, pos[2] - 1), color, ticks);
	thread scripts\ttt\_util::drawDebugLine((pos[0] - 1, pos[1] - 1, pos[2] + 1), (pos[0] + 1, pos[1] + 1, pos[2] - 1), color, ticks);
}

getDamageableEnts()
{
	ents = [];
	ents = array_combine(getEntArray("grenade", "classname"), ents);
	ents = array_combine(getEntArray("misc_turret", "classname"), ents);
	ents = array_combine(getEntArray("ttt_destructible_item", "targetname"), ents);
	ents = array_combine(getEntArray("destructible_toy", "targetname"), ents);
	ents = array_combine(getEntArray("destructible_vehicle", "targetname"), ents);
	ents = array_combine(getEntArray("explodable_barrel", "targetname"), ents);
	ents = array_combine(getEntArray("vending_machine", "targetname"), ents);
	return ents;
}
