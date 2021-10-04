#include common_scripts\utility;
#include maps\mp\_utility;

init() {
	level.ttt.use = spawnStruct();
	level.ttt.use.ents = [];
}

initPlayer()
{
	self.ttt.use = spawnStruct();
	self.ttt.use.canUse = true;
	self.ttt.use.availableEnt = undefined;
}

makeUsableCustom(onUse, onAvailable, onAvailableEnd, useRange, useAngle, usePriority, useThroughSolids)
{
	if (!isDefined(onUse)) return;
	if (!isDefined(useRange)) useRange = 128;
	if (!isDefined(useAngle)) useAngle = 45;
	if (!isDefined(usePriority)) usePriority = 0;
	if (!isDefined(useThroughSolids)) useThroughSolids = false;

	self.onUse = onUse;
	self.onAvailable = onAvailable;
	self.onAvailableEnd = onAvailableEnd;
	self.useRange = useRange;
	self.useAngle = useAngle;
	self.usePriority = usePriority;
	self.useThroughSolids = useThroughSolids;

	level.ttt.use.ents[level.ttt.use.ents.size] = self;
	self thread OnUseEntDeath();
}

OnUseEntDeath()
{
	self waittill("death");

	self makeUnusableCustom();
}

makeUnusableCustom()
{
	foreach (player in level.players)
		if (self == player.ttt.use.availableEnt) player unsetPlayerAvailableUseEnt();

	level.ttt.use.ents = array_remove(level.ttt.use.ents, self);
}

isUseEntAvailable(ent)
{
	return isDefined(self.ttt.use.availableEnt) && self.ttt.use.availableEnt == ent;
}

getUseEntAvailablePlayers(ent)
{
	result = [];
	foreach (player in getLivingPlayers())
		if (player isUseEntAvailable(ent))
			result[result.size] = player;
	return result;
}

getAvailableUseEnt()
{
	highestPriority = undefined;
	lowestAngle = undefined;
	result = undefined;

	foreach (ent in level.ttt.use.ents)
	{
		if (!self.ttt.use.canUse) continue;

		playerEyeOrigin = self getEye();
		vecEntPlayer = ent.origin - playerEyeOrigin;
		distanceSq = lengthSquared(vecEntPlayer);

		if (distanceSq > ent.useRange * ent.useRange) continue;

		dirEntPlayer = vectorNormalize(vecEntPlayer);
		angleFromView = lengthSquared(dirEntPlayer - anglesToForward(self getPlayerAngles())) * 45;

		if (angleFromView > ent.useAngle) continue;

		if (!ent.useThroughSolids)
		{
			targetPos = ent.origin + (0, 0, 4); // make sure the position is never below the ground
			if (!bulletTracePassed(playerEyeOrigin, targetPos, false, self)) continue;
		}

		if (!isDefined(highestPriority) || highestPriority < ent.usePriority)
		{
			highestPriority = ent.usePriority;
			lowestAngle = angleFromView;
			result = ent;
		}

		if ((!isDefined(lowestAngle) || lowestAngle > angleFromView) && highestPriority == ent.usePriority)
		{
			lowestAngle = angleFromView;
			result = ent;
		}
	}

	return result;
}

playerUseEntsThink()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		wait(0.1);

		if (self isInKillcam()) continue;
		if (self.ttt.items.inBuyMenu) continue;

		useEnt = self getAvailableUseEnt();
		if (useEnt != self.ttt.use.availableEnt)
		{
			if (isDefined(self.ttt.use.availableEnt)) self unsetPlayerAvailableUseEnt();

			if (isDefined(useEnt))
			{
				self.ttt.use.availableEnt = useEnt;
				self thread [[useEnt.onAvailable]](useEnt);
			}
		}
	}
}

unsetPlayerAvailableUseEnt()
{
	self thread [[self.ttt.use.availableEnt.onAvailableEnd]](self.ttt.use.availableEnt);
	self.ttt.use.availableEnt = undefined;
}

OnPlayerUse()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("ttt_activate", "+activate");

	for (;;)
	{
		self waittill("ttt_activate");
		if (self isInKillcam()) continue;
		if (self.ttt.items.inBuyMenu) continue;

		useEnt = self getAvailableUseEnt();
		if (isDefined(useEnt)) self thread [[useEnt.onUse]](useEnt);
	}
}
