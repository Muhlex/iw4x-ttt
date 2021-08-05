init()
{
	radar = spawnStruct();
	radar.name = "RADAR";
	radar.description = "^3Passive item\n^7Periodically shows the ^2location\nof all players ^7on the minimap.";
	radar.icon = "specialty_uav";
	radar.onBuy = ::OnBuy;
	radar.getIsAvailable = scripts\ttt\items::getIsAvailablePassive;
	radar.unavailableHint = &"^1Radar already active";
	radar.passiveDisplay = true;

	scripts\ttt\items::registerItem(radar, "traitor");

	makeDvarServerInfo("compassRadarPingFadeTime", 8);
	makeDvarServerInfo("compassRadarUpdateTime", 4);
}

OnBuy()
{
	self endon("disconnect");
	self endon("death");

	self.isRadarBlocked = false;
	RADAR_INTERVAL = 10;
	WAIT_TIME = getDvarFloat("compassRadarUpdateTime");

	for (;;)
	{
		self.hasRadar = true;
		wait(WAIT_TIME);
		self.hasRadar = false;
		wait(RADAR_INTERVAL - WAIT_TIME);
	}
}
