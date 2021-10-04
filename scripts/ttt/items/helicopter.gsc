init()
{
	helicopter = spawnStruct();
	helicopter.name = "ATTACK HELICOPTER";
	helicopter.description = "^3Air Support\n^2Attack helicopter^7 that targets ^1anyone^7.\nStays for ^31 ^7minute. Can be ^1shot down^7.";
	helicopter.icon = "specialty_helicopter_support_crate";
	helicopter.onBuy = ::OnBuy;
	helicopter.getIsAvailable = ::getIsAvailable;
	helicopter.unavailableHint = &"^1Air space too crowded";

	scripts\ttt\items::registerItem(helicopter, "traitor");
}

OnBuy()
{
	level.heli_target_spawnprotection = 8;
	level.heli_turretClipSize = 32; // helicopter only gets accurate after ~20 shots
	livingPlayersCount = level.aliveCount["allies"] + level.aliveCount["axis"];
	level.heli_maxhealth = 200 + min(livingPlayersCount, 6) * 100;
	self maps\mp\killstreaks\_helicopter::startHelicopter(-1);
}

getIsAvailable()
{
	return !isDefined(level.chopper);
}
