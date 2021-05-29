init()
{
	radar = spawnStruct();
	radar.name = "RADAR";
	radar.description = "^3Passive item\n^7Periodically shows the ^2location\nof all players ^7on the minimap.";
	radar.icon = "specialty_uav";
	radar.onBuy = ::OnBuy;
	radar.getIsAvailable = scripts\ttt\items::getIsAvailablePassive;
	radar.unavailableHint = &"^1Radar already active";

	scripts\ttt\items::registerItem(radar, "traitor");
}

OnBuy()
{
	self endon("disconnect");
	self endon("death");

	self.isRadarBlocked = false;
	RADAR_INTERVAL = 10;

	for (;;)
	{
		self.hasRadar = true;
		wait(4);
		self.hasRadar = false;
		wait(RADAR_INTERVAL - 4);
	}
}
