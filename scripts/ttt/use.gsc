#include common_scripts\utility;

init() {
	level.ttt.use = spawnStruct();
	level.ttt.use.ents = [];
}

initPlayer()
{
	self.ttt.use = spawnStruct();
	self.ttt.use.availableEnt = undefined;
}

makeUsableCustom(onUse, onAvailable, onAvailableEnd, useRange, useAngle, useThroughSolids)
{
	if (!isDefined(onUse)) return;
	if (!isDefined(useRange)) useRange = 128;
	if (!isDefined(useAngle)) useAngle = 45;
	if (!isDefined(useThroughSolids)) useThroughSolids = false;

	self.onUse = onUse;
	self.onAvailable = onAvailable;
	self.onAvailableEnd = onAvailableEnd;
	self.useRange = useRange;
	self.useAngle = useAngle;
	self.useThroughSolids = useThroughSolids;

	level.ttt.use.ents[level.ttt.use.ents.size] = self;
	self thread OnUseEntDeath();
}

getAvailableUseEnt()
{
	lowestAngle = undefined;
	result = undefined;

	foreach (ent in level.ttt.use.ents)
	{
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
			tracedPos = physicsTrace(playerEyeOrigin, targetPos);
			if (tracedPos != targetPos) continue;
		}

		if (!isDefined(lowestAngle) || lowestAngle > angleFromView)
		{
			result = ent;
			lowestAngle = angleFromView;
		}
	}

	return result;
}

OnUseEntDeath()
{
	self waittill("death");

	foreach (player in level.players)
	{
		if (self == player.ttt.use.availableEnt) player unsetPlayerAvailableUseEnt();
	}
	array_remove(level.ttt.use.ents, self);
}

playerUseEntsThink()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		wait(0.1);

		if (self.ttt.inBuyMenu) continue;

		useEnt = self getAvailableUseEnt();
		if (useEnt != self.ttt.use.availableEnt)
		{
			if (isDefined(self.ttt.use.availableEnt)) self unsetPlayerAvailableUseEnt();

			if (isDefined(useEnt))
			{
				self.ttt.use.availableEnt = useEnt;
				thread [[useEnt.onAvailable]](useEnt, self);
			}
		}
	}
}

unsetPlayerAvailableUseEnt()
{
	thread [[self.ttt.use.availableEnt.onAvailableEnd]](self.ttt.use.availableEnt, self);
	self.ttt.use.availableEnt = undefined;
}

OnPlayerUse()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("activate", "+activate");

	for (;;)
	{
		self waittill("activate");
		if (self.ttt.inBuyMenu) continue;

		useEnt = self getAvailableUseEnt();
		if (isDefined(useEnt)) thread [[useEnt.onUse]](useEnt, self);
	}
}
