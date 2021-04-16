#include common_scripts\utility;

init() {
	level.ttt.use = spawnStruct();
	level.ttt.use.ents = [];
}

makeUsableCustom(onUse, useRange, useThroughSolids)
{
	if (!isDefined(onUse)) return;
	if (!isDefined(useRange)) useRange = 128;
	if (!isDefined(useThroughSolids)) useThroughSolids = false;

	self.useRange = useRange;
	self.useThroughSolids = useThroughSolids;
	self.onUse = onUse;

	level.ttt.use.ents[level.ttt.use.ents.size] = self;
	self thread OnUseEntDeath();
}

OnUseEntDeath()
{
	self waittill("death");
	array_remove(level.ttt.use.ents, self);
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

		closestEnt = undefined;
		closestDistanceSq = undefined;

		foreach (ent in level.ttt.use.ents)
		{
			playerEyeOrigin = self getEye();
			distanceSq = distanceSquared(ent.origin, playerEyeOrigin);

			if (distanceSq > ent.useRange * ent.useRange) continue;
			if (!ent.useThroughSolids)
			{
				targetPos = ent.origin + (0, 0, 4);
				tracedPos = physicsTrace(playerEyeOrigin, targetPos);
				if (tracedPos != targetPos) continue;
			}

			if (!isDefined(closestDistanceSq) || closestDistanceSq > distanceSq)
			{
				closestEnt = ent;
				closestDistanceSq = distanceSq;
			}
		}

		if (!isDefined(closestEnt)) continue;
		[[closestEnt.onUse]](closestEnt, self);
	}
}
