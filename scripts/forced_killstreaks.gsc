#include maps\mp\_utility;

init()
{
	setDvarIfUninitialized("scr_forced_killstreaks", "");

	thread OnPlayerConnect();
}

OnPlayerConnect()
{
	level endon("game_ended");

	for(;;)
	{
		level waittill("connected", player);

		player thread OnPlayerSpawn();
	}
}

OnPlayerSpawn()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if (level.killstreakRewards) self replacePlayerKillstreaks();
	}
}

replacePlayerKillstreaks()
{
	modifier = 0;
	if (self _hasPerk("specialty_hardline") && (getDvarInt("scr_classic") != 1))
		modifier = -1;

	rawData = strTok(getDvar("scr_forced_killstreaks"), ",");

	if (rawData.size == 0 || rawData.size % 2) return; // needs to be pairs of streak numbers and reward names

	streaks = [];
	// map e.g. ["3", "uav", "4", "counter_uav"] to streaks[3] = "uav"; streaks[4] = "counter_uav"
	for (i = 0; i < rawData.size; i += 2)
		streaks[int(rawData[i]) + modifier] = rawData[i + 1];

	self.killStreaks = streaks;
}
