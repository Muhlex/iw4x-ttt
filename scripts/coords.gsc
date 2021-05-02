init()
{
	if (!getDvarInt("dev_log_coords")) return;

	thread OnPlayerConnect();
}

OnPlayerConnect()
{
	level endon("game_ended");

	for (;;)
	{
		level waittill("connected", player);

		player thread OnPlayerLogCoords();
	}
}

OnPlayerLogCoords()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("log_coords", "+actionslot 3");

	for (;;)
	{
		self waittill("log_coords");

		map = getDvar("mapname");
		pos = (int(self.origin[0]), int(self.origin[1]), int(self.origin[2]));
		self iPrintLnBold("Logged position: ", pos);
		logPrint("coords_" + map + ": (" + pos[0] + ", " + pos[1] + ", " + pos[2] + ")\n");
	}
}
