init()
{
	setDvarIfUninitialized("scr_scoreboard_reshows_perks", false);

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

		thread OnScoreboardClose();
	}
}

OnScoreboardClose()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("reshow_perks", "-scores");

	for (;;)
	{
		self waittill("reshow_perks");

		if (!getDvarInt("scr_scoreboard_reshows_perks")) continue;
		self openMenu("perks_hidden");
		wait(0.1);
		self openMenu("perk_display");
	}
}
