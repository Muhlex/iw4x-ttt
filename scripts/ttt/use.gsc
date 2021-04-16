#include common_scripts\utility;

init() {
	level.ttt.use = spawnStruct();
	level.ttt.use.ents = [];
}

makeUsableCustom(onUse, useRange, useAngle, useThroughSolids)
{
	if (!isDefined(onUse)) return;
	if (!isDefined(useRange)) useRange = 128;
	if (!isDefined(useAngle)) useAngle = 70;
	if (!isDefined(useThroughSolids)) useThroughSolids = false;

	self.useRange = useRange;
	self.useAngle = useAngle;
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

		lowestAngle = undefined;
		useEnt = undefined;

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
				useEnt = ent;
				lowestAngle = angleFromView;
			}
		}

		if (!isDefined(useEnt)) continue;
		[[useEnt.onUse]](useEnt, self);
	}
}
