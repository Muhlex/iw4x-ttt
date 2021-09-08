init()
{
	heartbeat = spawnStruct();
	heartbeat.name = "M4A1 HEARTBEAT SENSOR";
	heartbeat.description = "^3Active Item\n^7Assault rifle with attached ^2heartbeat\nsensor^7. Reveals ^3nearby ^7enemies.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	heartbeat.icon = "cardicon_heartbeatsensor";
	heartbeat.onBuy = ::OnBuy;
	heartbeat.getIsAvailable = scripts\ttt\items::getIsAvailableRoleItem;
	heartbeat.unavailableHint = scripts\ttt\items::getUnavailableHint("roleitem");
	heartbeat.weaponName = "m4_heartbeat_mp";
	heartbeat.camo = "blue_tiger";

	scripts\ttt\items::registerItem(heartbeat, "detective");
}

OnBuy(item)
{
	self scripts\ttt\items::setRoleInventory(item, 30, 0);
}
