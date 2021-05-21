#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	level.ttt.effects.bombBlink = loadFX("misc/aircraft_light_red_blink");
	level.ttt.effects.bombExplosion = loadFX("explosions/tanker_explosion");
	level.ttt.effects.bombOuterExplosion = loadFX("explosions/aerial_explosion_large");
	level.ttt.effects.cameraIdle = loadFX("misc/aircraft_light_wingtip_green");
	level.ttt.effects.cameraActive = loadFX("misc/aircraft_light_red_blink");

	precacheModel("prop_suitcase_bomb");
	precacheModel("sentry_minigun");

	if (level.ttt.modEnabled)
	{
		precacheModel("com_security_camera_tilt_animated");
		precacheModel("com_security_camera_tilt_animated_bombsquad");
		precacheModel("com_security_camera_d_tilt_animated");
		precacheMPAnim("security_camera_idle");
		precacheMPAnim("security_camera_destroy");
		level.ttt.effects.cameraExplosion = loadFX("props/security_camera_explosion_moving");
	}
	else
	{
		precacheModel("weapon_c4");
		precacheModel("weapon_c4_bombsquad");
	}

	level.ttt.bombs = [];

	level.ttt.items = [];
	level.ttt.items["traitor"] = [];
	level.ttt.items["detective"] = [];
	level.ttt.items["internal"] = [];

	armor = spawnStruct();
	armor.name = "ARMOR";
	armor.description = "^3Passive item\n^7Reduces incoming bullet damage\nby ^220 percent^7.\n\nDefault equipment for detectives.";
	armor.icon = "cardicon_vest_1";
	armor.onBuy = ::OnBuyArmor;
	armor.getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["traitor"][0] = armor;

	level.ttt.items["traitor"][1] = spawnStruct();
	level.ttt.items["traitor"][1].name = "RADAR";
	level.ttt.items["traitor"][1].description = "^3Passive item\n^7Periodically shows the ^2location\nof all players ^7on the minimap.";
	level.ttt.items["traitor"][1].icon = "specialty_uav";
	level.ttt.items["traitor"][1].onBuy = ::OnBuyRadar;
	level.ttt.items["traitor"][1].getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["traitor"][2] = spawnStruct();
	level.ttt.items["traitor"][2].name = "ATTACK HELICOPTER";
	level.ttt.items["traitor"][2].description = "^3Air support\n^2Attack helicopter^7 that targets ^1anyone^7.\nStays for ^31 ^7minute. Can be ^1shot down^7.";
	level.ttt.items["traitor"][2].icon = "specialty_helicopter_support_crate";
	level.ttt.items["traitor"][2].onBuy = ::OnBuyHelicopter;
	level.ttt.items["traitor"][2].getIsAvailable = ::getIsAvailableHelicopter;

	level.ttt.items["traitor"][3] = spawnStruct();
	level.ttt.items["traitor"][3].name = "BOMB";
	level.ttt.items["traitor"][3].description = "^3Deployable item\n^7Causes a ^2huge explosion ^7after ^3" + getDvarInt("ttt_bomb_timer") + " ^7s.\nCan be ^1defused^7. Emits a ^1sound^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["traitor"][3].activateHint = &"Hold [ ^3[{+attack}]^7 ] to ^3plant ^7the bomb";
	level.ttt.items["traitor"][3].icon = "hud_suitcase_bomb";
	level.ttt.items["traitor"][3].onBuy = ::OnBuyBomb;
	level.ttt.items["traitor"][3].onActivate = ::OnActivateBomb;
	level.ttt.items["traitor"][3].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["traitor"][3].weaponName = "onemanarmy_mp";
	if (level.ttt.modEnabled)
		level.ttt.items["traitor"][3].weaponName = "oma_bomb_mp";

	level.ttt.items["traitor"][4] = spawnStruct();
	level.ttt.items["traitor"][4].name = "ROCKET LAUNCHER";
	level.ttt.items["traitor"][4].description = "^3Exclusive weapon\n^7RPG-7 explosive launcher.\nHolds ^31 ^7rocket. ^1Can't pick up ammo^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["traitor"][4].icon = "weapon_rpg7";
	level.ttt.items["traitor"][4].iconWidth = 44;
	level.ttt.items["traitor"][4].iconHeight = 22;
	level.ttt.items["traitor"][4].iconOffsetX = 1;
	level.ttt.items["traitor"][4].onBuy = ::OnBuyRPG;
	level.ttt.items["traitor"][4].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["traitor"][4].weaponName = "rpg_mp";

	level.ttt.items["traitor"][5] = spawnStruct();
	level.ttt.items["traitor"][5].name = "RANGER SHOTGUN";
	level.ttt.items["traitor"][5].description = "^3Exclusive weapon\n^7Strong close-range shotgun\nwhich can fire ^2two shells at once^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["traitor"][5].icon = "weapon_ranger";
	level.ttt.items["traitor"][5].iconWidth = 48;
	level.ttt.items["traitor"][5].iconHeight = 24;
	level.ttt.items["traitor"][5].iconOffsetX = -1;
	level.ttt.items["traitor"][5].onBuy = ::OnBuyRanger;
	level.ttt.items["traitor"][5].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["traitor"][5].weaponName = "ranger_mp";

	level.ttt.items["traitor"][6] = spawnStruct();
	level.ttt.items["traitor"][6].name = "THROWING KNIFE";
	level.ttt.items["traitor"][6].description = "^3Exclusive equipment\n^7Kills ^2silently^7. Can be ^2picked up\n^7by anyone if it doesn't kill.\n\nPress [ ^3[{+frag}]^7 ] to throw.";
	level.ttt.items["traitor"][6].icon = "equipment_throwing_knife";
	level.ttt.items["traitor"][6].iconOffsetX = 1;
	level.ttt.items["traitor"][6].onBuy = ::OnBuyKnife;
	level.ttt.items["traitor"][6].getIsAvailable = ::getIsAvailableEquipment;

	level.ttt.items["traitor"][7] = spawnStruct();
	level.ttt.items["traitor"][7].name = "CLAYMORE";
	level.ttt.items["traitor"][7].description = "^3Exclusive equipment\n^7Triggers for anyone ^1including yourself^7.\n^2Highlighted ^7to other traitors.\n\nPress [ ^3[{+frag}]^7 ] to set down.";
	level.ttt.items["traitor"][7].icon = "equipment_claymore";
	level.ttt.items["traitor"][7].iconOffsetX = 1;
	level.ttt.items["traitor"][7].onBuy = ::OnBuyClaymore;
	level.ttt.items["traitor"][7].getIsAvailable = ::getIsAvailableEquipment;

	level.ttt.items["traitor"][8] = spawnStruct();
	level.ttt.items["traitor"][8].name = "FLASHBANG";
	level.ttt.items["traitor"][8].description = "^3Exclusive special grenade\n^2Blinds ^7anyone who is caught in\nor looking at the explosion.\n\nPress [ ^3[{+smoke}]^7 ] to throw.";
	level.ttt.items["traitor"][8].icon = "weapon_flashbang";
	level.ttt.items["traitor"][8].onBuy = ::OnBuyFlash;
	level.ttt.items["traitor"][8].getIsAvailable = ::getIsAvailableOffhand;

	level.ttt.items["detective"][0] = armor;

	level.ttt.items["detective"][1] = spawnStruct();
	level.ttt.items["detective"][1].name = "RIOT SHIELD";
	level.ttt.items["detective"][1].description = "^3Exclusive weapon\n^2Blocks bullets^7, even when it is\non your back.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["detective"][1].icon = "weapon_riotshield";
	level.ttt.items["detective"][1].iconWidth = 64;
	level.ttt.items["detective"][1].iconHeight = 32;
	level.ttt.items["detective"][1].iconOffsetX = -16;
	level.ttt.items["detective"][1].onBuy = ::OnBuyRiot;
	level.ttt.items["detective"][1].onPickup = ::OnPickupRiot;
	level.ttt.items["detective"][1].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["detective"][1].weaponName = "riotshield_mp";

	level.ttt.items["detective"][2] = spawnStruct();
	level.ttt.items["detective"][2].name = "SPAS-12 SHOTGUN";
	level.ttt.items["detective"][2].description = "^3Exclusive weapon\n^7Versatile shotgun with good\nperformance ^2up to medium range^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["detective"][2].icon = "weapon_spas12";
	level.ttt.items["detective"][2].iconWidth = 48;
	level.ttt.items["detective"][2].iconHeight = 24;
	level.ttt.items["detective"][2].iconOffsetX = 1;
	level.ttt.items["detective"][2].onBuy = ::OnBuySpas;
	level.ttt.items["detective"][2].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["detective"][2].weaponName = "spas12_mp";

	level.ttt.items["detective"][3] = spawnStruct();
	level.ttt.items["detective"][3].name = "STUN GRENADE";
	level.ttt.items["detective"][3].description = "^3Exclusive special grenade\n^2Disorients ^7and ^2slows ^7targets\ncaught in the explosion.\n\nPress [ ^3[{+smoke}]^7 ] to throw.";
	level.ttt.items["detective"][3].icon = "weapon_concgrenade";
	level.ttt.items["detective"][3].onBuy = ::OnBuyConcussion;
	level.ttt.items["detective"][3].getIsAvailable = ::getIsAvailableOffhand;

	level.ttt.items["detective"][4] = spawnStruct();
	level.ttt.items["detective"][4].name = "HEALTH STATION";
	level.ttt.items["detective"][4].description = "^3Deployable item\n^7Slowly ^2regenerates health ^7on use.\nCan be placed anywhere.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["detective"][4].activateHint = &"Press [ ^3[{+attack}]^7 ] to ^3place ^7the health station";
	level.ttt.items["detective"][4].icon = "hint_health";
	level.ttt.items["detective"][4].onBuy = ::OnBuyHealthStation;
	level.ttt.items["detective"][4].onActivate = ::OnActivateHealthStation;
	level.ttt.items["detective"][4].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["detective"][4].weaponName = "onemanarmy_mp";
	if (level.ttt.modEnabled)
		level.ttt.items["detective"][4].weaponName = "oma_healthstation_mp";

	level.ttt.items["detective"][5] = spawnStruct();
	level.ttt.items["detective"][5].name = "INSANE BICEPS";
	level.ttt.items["detective"][5].description = "^3Passive item\n^7Drop weapons with ^2deadly velocity^7.\nDeal ^2more damage ^7at far distances.\n\nPress [ ^3[{+actionslot 1}]^7 ] to throw a weapon.";
	level.ttt.items["detective"][5].icon = "specialty_onemanarmy_upgrade";
	level.ttt.items["detective"][5].onBuy = ::OnBuyLob;
	level.ttt.items["detective"][5].getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["detective"][6] = spawnStruct();
	level.ttt.items["detective"][6].name = "CAMERA";
	level.ttt.items["detective"][6].description = "^3Deployable item\n^7Place on walls to ^2remotely observe an\narea^7. Equip the receiver once placed.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["detective"][6].activateHint = &"Press [ ^3[{+attack}]^7 ] ^3on a wall ^7to place the camera";
	level.ttt.items["detective"][6].icon = "cardicon_binoculars_1";
	level.ttt.items["detective"][6].onBuy = ::OnBuyCamera;
	level.ttt.items["detective"][6].onEquip = ::OnEquipCamera;
	level.ttt.items["detective"][6].onUnequip = ::OnUnequipCamera;
	level.ttt.items["detective"][6].onActivate = ::OnActivateCamera;
	level.ttt.items["detective"][6].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["detective"][6].weaponName = "onemanarmy_mp";
	if (level.ttt.modEnabled)
		level.ttt.items["detective"][6].weaponName = "oma_camera_mp";

	level.ttt.items["internal"]["camera_receiver"] = spawnStruct();
	level.ttt.items["internal"]["camera_receiver"].name = "CAMERA RECEIVER";
	level.ttt.items["internal"]["camera_receiver"].onBuy = ::OnBuyCamReceiver;
	level.ttt.items["internal"]["camera_receiver"].onEquip = ::OnEquipCamReceiver;
	level.ttt.items["internal"]["camera_receiver"].onStartUnequip = ::OnStartUnequipCamReceiver;
	level.ttt.items["internal"]["camera_receiver"].onUnequip = ::OnUnequipCamReceiver;
	level.ttt.items["internal"]["camera_receiver"].weaponName = "killstreak_ac130_mp";

	foreach (roleItems in level.ttt.items) foreach (item in roleItems)
	{
		precacheShader(item.icon);
		if (level.ttt.modEnabled) precacheItem(item.weaponName);
	}
}

initPlayer()
{
	self.ttt.items = spawnStruct();
	self.ttt.items.inBuyMenu = false;
	self.ttt.items.selectedIndex = 0;
	self.ttt.items.credits = 0;
	self.ttt.items.boughtItems = [];
	self resetRoleInventory();
}

OnPlayerBuyMenu()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("ttt_buymenu_toggle", "+actionslot 2");
	self notifyOnPlayerCommand("ttt_buymenu_close", "weapnext");
	self notifyOnPlayerCommand("ttt_buymenu_close", "weapprev");

	for (;;)
	{
		eventName = self waittill_any_return("ttt_buymenu_toggle", "ttt_buymenu_close");

		if (!self.ttt.items.inBuyMenu && eventName == "ttt_buymenu_close") continue;
		if (!isAlive(self) || !isDefined(self.ttt.role) || (self.ttt.role != "traitor" && self.ttt.role != "detective")) continue;

		if (self.ttt.items.inBuyMenu) self thread unsetPlayerBuyMenu(true);
		else self thread setPlayerBuyMenu();
	}
}

OnPlayerBuyMenuEsc()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		self waittill("menuresponse", menu, response);

		if (response != "ttt_esc_menu_blocked") continue;

		if (self.ttt.items.inBuyMenu) self thread unsetPlayerBuyMenu(true);
	}
}

setPlayerBuyMenu()
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_buymenu_toggle");
	self endon("ttt_buymenu_close");

	LAPTOP_WEAPON = "killstreak_harrier_airstrike_mp";

	self giveWeapon(LAPTOP_WEAPON);
	self switchToWeapon(LAPTOP_WEAPON);

	TIMEOUT = 1.5 * 1000;
	startTime = getTime();
	while (self getCurrentWeapon() != LAPTOP_WEAPON || !self isOnGround())
	{
		wait(0.05);
		if (startTime + TIMEOUT < getTime())
		{
			self switchToLastWeapon();
			self playLaptopSound();
			return;
		}
	}

	self.ttt.items.inBuyMenu = true;
	self setClientDvar("ui_ttt_block_esc_menu", true);

	self setBlurForPlayer(6, 1.5);
	self freezePlayer();
	self scripts\ttt\ui::destroyHeadIcons();
	self scripts\ttt\ui::destroyBuyMenu();
	self scripts\ttt\ui::displayBuyMenu(self.ttt.role);
	self thread buyMenuThink();
	self thread buyMenuThinkLaptop(LAPTOP_WEAPON);
}

unsetPlayerBuyMenu(switchToLastWeapon)
{
	if (!isDefined(switchToLastWeapon)) switchToLastWeapon = false;

	self.ttt.items.inBuyMenu = false;
	self setClientDvar("ui_ttt_block_esc_menu", false);

	self unfreezePlayer();
	if (switchToLastWeapon)
	{
		self switchToLastWeapon();
		self playLaptopSound();
	}
	self setBlurForPlayer(0, 0.75);
	self scripts\ttt\ui::destroyBuyMenu();

	if (isAlive(self)) self scripts\ttt\ui::displayHeadIcons();
}

playLaptopSound()
{
	/**
	 * Stowing the laptop makes a distinct sound that only other players can hear.
	 * We recreate this sound for the local player here.
	 */
	if (!level.ttt.modEnabled)
		self playSoundToPlayer("weap_c4detpack_safety_plr", self);
}

buyMenuThinkLaptop(weaponName)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_buymenu_toggle");
	self endon("ttt_buymenu_close");

	for (;;)
	{
		if (self getCurrentWeapon() != weaponName) self notify("ttt_buymenu_close");
		wait(0.2);
	}
}

buyMenuThink()
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_buymenu_toggle");
	self endon("ttt_buymenu_close");

	self notifyOnPlayerCommand("ttt_menu_up", "+forward");
	self notifyOnPlayerCommand("ttt_menu_down", "+back");
	self notifyOnPlayerCommand("ttt_menu_left", "+moveleft");
	self notifyOnPlayerCommand("ttt_menu_right", "+moveright");
	self notifyOnPlayerCommand("ttt_menu_activate", "+activate");
	self notifyOnPlayerCommand("ttt_menu_activate", "+attack");
	self notifyOnPlayerCommand("ttt_menu_activate", "+gostand");

	for (;;)
	{
		eventName = self waittill_any_return("ttt_menu_up", "ttt_menu_down", "ttt_menu_left", "ttt_menu_right", "ttt_menu_activate");
		moveDown = 0;
		moveRight = 0;
		if (eventName == "ttt_menu_up") moveDown = -1;
		else if (eventName == "ttt_menu_down") moveDown = 1;
		else if (eventName == "ttt_menu_left") moveRight = -1;
		else if (eventName == "ttt_menu_right") moveRight = 1;

		if (moveDown != 0 || moveRight != 0)
			self scripts\ttt\ui::updateBuyMenu(self.ttt.role, moveDown, moveRight);

		if (eventName == "ttt_menu_activate")
			self scripts\ttt\items::tryBuyItem(level.ttt.items[self.ttt.role][self.ttt.items.selectedIndex]);
	}
}

resetRoleInventory()
{
	self.ttt.items.roleInventory = spawnStruct();
}
setRoleInventory(item, ammoClip, ammoStock, data)
{
	if (!isDefined(item)) return;
	if (!isDefined(ammoClip)) ammoClip = 1;
	if (!isDefined(ammoStock)) ammoStock = 0;
	if (!isDefined(data)) data = spawnStruct();

	inv = self.ttt.items.roleInventory;
	inv.item = item;
	inv.ammoClip = ammoClip;
	inv.ammoStock = ammoStock;
	inv.data = data;
}
isRoleWeapon(weaponName)
{
	foreach (roleItems in level.ttt.items)
		foreach (item in roleItems)
			if (isDefined(item.weaponName) && item.weaponName == weaponName) return true;

	return false;
}
hasRoleWeapon(weaponName)
{
	hasAnyRoleWeapon = isDefined(self.ttt.items.roleInventory.item.weaponName);
	if (!isDefined(weaponName)) return hasAnyRoleWeapon;
	else return hasAnyRoleWeapon && self.ttt.items.roleInventory.item.weaponName == weaponName;
}
isRoleWeaponOnPlayer()
{
	return self hasRoleWeapon() && self hasWeapon(self.ttt.items.roleInventory.item.weaponName);
}
isRoleWeaponCurrent()
{
	return self isRoleWeaponOnPlayer() && self getCurrentWeapon() == self.ttt.items.roleInventory.item.weaponName;
}
giveRoleWeapon()
{
	if (self isRoleWeaponOnPlayer()) return;
	if (!maps\mp\gametypes\_weapons::mayDropWeapon(self getCurrentWeapon())) return;

	inv = self.ttt.items.roleInventory;
	if (!isDefined(inv.item.weaponName)) return;

	self giveWeapon(inv.item.weaponName);
	self setWeaponAmmoClip(inv.item.weaponName, inv.ammoClip);
	self setWeaponAmmoStock(inv.item.weaponName, inv.ammoStock);
	self switchToWeapon(inv.item.weaponName);

	self thread OnPlayerRoleWeaponInterrupt(inv.item, inv.data, false);
	self thread OnPlayerRoleWeaponCancelEquip(inv.item, inv.data);
	if (isDefined(inv.item.onStartEquip)) self thread [[inv.item.onStartEquip]](inv.item, inv.data);

	return inv.item.weaponName;
}
takeRoleWeapon()
{
	if (!self isRoleWeaponOnPlayer()) return;

	weaponName = self.ttt.items.roleInventory.item.weaponName;

	self.ttt.items.roleInventory.ammoClip = self getWeaponAmmoClip(weaponName);
	self.ttt.items.roleInventory.ammoStock = self getWeaponAmmoStock(weaponName);
	self takeWeapon(weaponName);
	self thread maps\mp\gametypes\_weapons::stowedWeaponsRefresh();

	return weaponName;
}

OnPlayerRoleWeaponToggle()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("ttt_roleweapon_toggle", "+actionslot 3");

	for (;;)
	{
		self waittill("ttt_roleweapon_toggle");
		if (!self hasRoleWeapon()) continue;

		if (self isRoleWeaponOnPlayer()) self switchToLastWeapon();
		else self giveRoleWeapon();
	}
}

OnPlayerRoleWeaponCancelEquip(item, data)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_roleweapon_equipped");
	self endon("ttt_roleweapon_unequipped");

	self waittill_any("ttt_weapon_switch_canceled");

	self takeRoleWeapon();

	if (isDefined(item.onCancelEquip)) self thread [[item.onCancelEquip]](item, data);
}

OnPlayerRoleWeaponEquip()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		self waittill("weapon_change", weaponName);
		if (!isRoleWeapon(weaponName))
		{
			// The player might have cycled over the role weapon and equipped something else instead:
			if (weaponName != "none" && self isRoleWeaponOnPlayer()) self takeRoleWeapon();
			continue;
		};

		self notify("ttt_roleweapon_equipped");

		inv = self.ttt.items.roleInventory;
		self thread OnPlayerRoleWeaponStartUnequip(inv.item, inv.data);
		self thread OnPlayerRoleWeaponUnequip(inv.item, inv.data);
		self thread OnPlayerRoleWeaponInterrupt(inv.item, inv.data, true);
		self displayRoleWeaponActivateHint(inv.item);
		if (isDefined(inv.item.onEquip)) self thread [[inv.item.onEquip]](inv.item, inv.data);
	}
}

OnPlayerRoleWeaponStartUnequip(item, data)
{
	self endon("ttt_roleweapon_unequipped");

	for (;;)
	{
		self waittill("weapon_switch_started", switchToWeaponName);

		if (isDefined(item.onStartUnequip)) self thread [[item.onStartUnequip]](item, data, switchToWeaponName);
	}
}

OnPlayerRoleWeaponUnequip(item, data)
{
	self endon("disconnect");
	self endon("death");

	while (self getCurrentWeapon() == item.weaponName) wait(0.05);

	self notify("ttt_roleweapon_unequipped");

	self destroyRoleWeaponActivateHint();
	if (isDefined(item.onUnequip)) self thread [[item.onUnequip]](item, data);

	if (self getCurrentWeapon() != "none") self takeRoleWeapon();
}

OnPlayerRoleWeaponInterrupt(item, data, wasEquipped)
{
	self endon("ttt_roleweapon_equipped"); // is re-hooked after equip with wasEquipped set to true
	self endon("ttt_roleweapon_unequipped");

	self waittill_any("disconnect", "death");

	if (wasEquipped)
	{
		self destroyRoleWeaponActivateHint();
		if (isDefined(item.onUnequip)) self thread [[item.onUnequip]](item, data);
		self notify("ttt_roleweapon_unequipped");
	}
	else
		if (isDefined(item.onCancelEquip)) self thread [[item.onCancelEquip]](item, data);
}

displayRoleWeaponActivateHint(item)
{
	if (isDefined(item) && isDefined(item.activateHint))
	{
		self scripts\ttt\ui::destroyActivateHint();
		self scripts\ttt\ui::displayActivateHint(item.name, item.activateHint);
	}
}
destroyRoleWeaponActivateHint()
{
	self scripts\ttt\ui::destroyActivateHint();
}

OnPlayerRoleWeaponActivate()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("ttt_roleweapon_activate", "+attack");

	for (;;)
	{
		self waittill("ttt_roleweapon_activate");
		if (!self isRoleWeaponCurrent()) continue;

		self notify("ttt_roleweapon_activated");

		inv = self.ttt.items.roleInventory;
		if (!isDefined(inv.item.onActivate)) continue;
		self thread [[inv.item.onActivate]](inv.item, inv.data);
	}
}

resetPlayerEquipment()
{
	// Make anyone able to pick up throwing knives:
	self giveWeapon("throwingknife_mp");
	self setWeaponAmmoClip("throwingknife_mp", 0); // remove the '1' ammo from the throwing knife weapon
	self SetOffhandPrimaryClass("throwingknife"); // set throwing knife as 'active' equipment so it can be used once picked up
}

setStartingCredits()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "traitor") self.ttt.items.credits = getDvarInt("ttt_traitor_start_credits");
	if (self.ttt.role == "detective") self.ttt.items.credits = getDvarInt("ttt_detective_start_credits");
}

setStartingItems()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "detective") self giveItem(level.ttt.items["detective"][0]);
}

awardCredits(amount)
{
	if (amount < 1) return;

	self.ttt.items.credits += amount;
	feedback = "You received ^1" + amount + "^7 store credits";
	if (amount == 1) feedback = "You received ^1" + amount + "^7 store credit";
	self iPrintLn(feedback);
}

awardKillCredits(victim)
{
	if (!isDefined(self.ttt.role) || !isDefined(victim.ttt.role)) return;

	if (self.ttt.role == "traitor" && victim.ttt.role != "traitor")
		self scripts\ttt\items::awardCredits(getDvarInt("ttt_traitor_kill_credits"));
	else if (self.ttt.role == "detective" && victim.ttt.role == "traitor")
		self scripts\ttt\items::awardCredits(getDvarInt("ttt_detective_kill_credits"));
}

awardBodyInspectCredits(victim)
{
	if (!isDefined(self.ttt.role) || !isDefined(victim.ttt.role)) return;

	if (self.ttt.role == "detective" && victim.ttt.items.credits > 0 && isPlayer(victim))
	{
		self awardCredits(victim.ttt.items.credits);
		victim.ttt.items.credits = 0;
	}
}

giveItem(item, data)
{
	self.ttt.items.boughtItems[self.ttt.items.boughtItems.size] = item;
	self thread [[item.onBuy]](item, data);
	self iPrintLn("^3" + item.name + "^7 received");
}

tryBuyItem(item)
{
	if (!self [[item.getIsAvailable]](item)) return;
	if (self.ttt.items.credits < 1) return;

	self giveItem(item);
	self.ttt.items.credits--;
	logPrint("TTT_ITEM_BOUGHT;" + self.guid + ";" + self.name + ";" + self.ttt.role + ";" + item.name + "\n");

	self scripts\ttt\ui::updateBuyMenu(self.ttt.role, undefined, undefined, true);
}

getIsAvailablePassive(item)
{
	return !isInArray(self.ttt.items.boughtItems, item);
}

getIsAvailableRoleItem(item)
{
	return !self hasRoleWeapon();
}

getIsAvailableEquipment()
{
	EQUIPMENT_ITEMS = [];
	EQUIPMENT_ITEMS[0] = "frag_grenade_mp";
	EQUIPMENT_ITEMS[1] = "semtex_mp";
	EQUIPMENT_ITEMS[2] = "throwingknife_mp";
	EQUIPMENT_ITEMS[3] = "specialty_tacticalinsertion";
	EQUIPMENT_ITEMS[4] = "specialty_blastshield";
	EQUIPMENT_ITEMS[5] = "claymore_mp";
	EQUIPMENT_ITEMS[6] = "c4_mp";

	foreach (equipment in EQUIPMENT_ITEMS)
	{
		if (!self hasWeapon(equipment)) continue;
		if (self getWeaponAmmoClip(equipment) > 0) return false;
	}

	return true;
}

getIsAvailableOffhand()
{
	OFFHAND_ITEMS = [];
	OFFHAND_ITEMS[0] = "smoke_grenade_mp";
	OFFHAND_ITEMS[1] = "flash_grenade_mp";
	OFFHAND_ITEMS[2] = "concussion_grenade_mp";

	foreach (offhand in OFFHAND_ITEMS)
	{
		if (!self hasWeapon(offhand)) continue;
		if (self getWeaponAmmoClip(offhand) > 0) return false;
	}

	return true;
}

OnBuyArmor()
{
	self.ttt.incomingDamageMultiplier = 0.8;
	self scripts\ttt\ui::updatePlayerArmorDisplay();
}

OnBuyRadar()
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

OnBuyRanger(item)
{
	self setRoleInventory(item, 2, 0);
}

OnBuyRPG(item)
{
	self setRoleInventory(item, 1, 0);
}

OnBuyKnife()
{
	WEAPON_NAME = "throwingknife_mp";
	self setWeaponAmmoClip(WEAPON_NAME, 1);
}

OnBuyClaymore()
{
	self endon("disconnect");
	self endon("death");

	WEAPON_NAME = "claymore_mp";

	self takeWeapon("throwingknife_mp");
	self setOffhandPrimaryClass("other");
	self maps\mp\perks\_perks::givePerk(WEAPON_NAME);

	for (;;)
	{
		self waittill("grenade_fire", claymore, grenadeWeaponName);
		if (grenadeWeaponName != WEAPON_NAME) continue;
		self resetPlayerEquipment();
	}
}

OnBuyFlash()
{
	WEAPON_NAME = "flash_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self SetOffhandSecondaryClass("flash");
}

OnBuyBomb(item)
{
	self setRoleInventory(item);
}

OnActivateBomb()
{
	self endon("disconnect");
	self endon("death");

	self notify("ttt_planting_bomb");
	self endon("ttt_planting_bomb");

	BOMB_WEAPON = "briefcase_bomb_mp";

	self giveWeapon(BOMB_WEAPON);
	self setWeaponAmmoClip(BOMB_WEAPON, 0);
	self setWeaponAmmoStock(BOMB_WEAPON, 0);
	self switchToWeapon(BOMB_WEAPON);

	self thread OnBombInteractionInterrupt();

	TIMEOUT = 1.5 * 1000;
	startTime = getTime();
	while (self getCurrentWeapon() != BOMB_WEAPON || !self isOnGround())
	{
		wait(0.05);
		if (startTime + TIMEOUT < getTime())
		{
			if (self getCurrentWeapon() == BOMB_WEAPON) switchToLastWeapon();
			self notify("ttt_bomb_interaction_canceled");
			return;
		}
	}

	// self playSound("mp_bomb_plant");
	self freezePlayer();
	self thread attachBombModel();

	self thread activateBombThink();
}

activateBombThink()
{
	self endon("disconnect");
	self endon("death");

	BOMB_WEAPON = "briefcase_bomb_mp";
	PLANT_TIME = 4.0 * 1000;
	plantStartTime = getTime();

	for (;;)
	{
		wait(0.05);

		if (self getCurrentWeapon() != BOMB_WEAPON || (!self attackButtonPressed() && !self useButtonPressed()))
		{
			self stopBombInteraction();
			return;
		}

		if (plantStartTime + PLANT_TIME > getTime()) continue;

		self notify("ttt_planted_bomb");

		self stopBombInteraction(true, BOMB_WEAPON);

		bombEnt = spawn("script_model", self.origin);
		bombEnt.angles = self.angles + (0, -90, 0);
		bombEnt setModel("prop_suitcase_bomb");
		bombEnt.owner = self;
		bombEnt.killCamEnt = spawn("script_model", self.origin + (0, 0, maps\mp\killstreaks\_airdrop::getFlyHeightOffset(self.origin)));
		bombEnt.objectName = "ttt_bomb";

		bombEnt showBomb();

		level.ttt.bombs[level.ttt.bombs.size] = bombEnt;
		scripts\ttt\ui::updateBombHuds();

		self takeRoleWeapon();
		self switchToLastWeapon();
		self resetRoleInventory();

		bombEnt thread OnBombDeath();
		bombEnt thread bombThink(self);

		return;
	}
}

OnDefuseBomb(bombEnt)
{
	self endon("disconnect");
	self endon("death");
	bombEnt endon("death");

	if (isDefined(bombEnt.interactingPlayer)) return;

	self notify("ttt_defusing_bomb");
	self endon("ttt_defusing_bomb");

	BOMB_WEAPON = "briefcase_bomb_defuse_mp";

	if (!maps\mp\gametypes\_weapons::mayDropWeapon(self getCurrentWeapon())) return;

	self giveWeapon(BOMB_WEAPON);
	self setWeaponAmmoClip(BOMB_WEAPON, 0);
	self setWeaponAmmoStock(BOMB_WEAPON, 0);
	self switchToWeapon(BOMB_WEAPON);

	bombEnt hideBomb(self);

	self thread OnBombInteractionInterrupt(bombEnt);

	TIMEOUT = 1.5 * 1000;
	startTime = getTime();
	while (self getCurrentWeapon() != BOMB_WEAPON || !self isOnGround())
	{
		wait(0.05);
		if (startTime + TIMEOUT < getTime())
		{
			if (self getCurrentWeapon() == BOMB_WEAPON) switchToLastWeapon();
			bombEnt showBomb();
			self notify("ttt_bomb_interaction_canceled");
			return;
		}
	}

	self playSound("mp_bomb_defuse");
	self freezePlayer();
	self thread attachBombModel();

	self thread defuseBombThink(bombEnt);
}

defuseBombThink(bombEnt)
{
	self endon("disconnect");
	self endon("death");
	bombEnt endon("death");

	BOMB_WEAPON = "briefcase_bomb_defuse_mp";
	DEFUSE_TIME = 4.0 * 1000;
	defuseStartTime = getTime();

	for (;;)
	{
		wait(0.05);

		if (self getCurrentWeapon() != BOMB_WEAPON || (!self attackButtonPressed() && !self useButtonPressed()))
		{
			self stopBombInteraction();
			bombEnt showBomb();
			return;
		}

		if (defuseStartTime + DEFUSE_TIME > getTime()) continue;

		if (randomFloat(1.0) < getDvarFloat("ttt_bomb_defuse_failure_pct"))
		{
			bombEnt thread explodeBomb();
			return;
		}

		self notify("ttt_defused_bomb");

		self stopBombInteraction(true, BOMB_WEAPON);

		bombEnt.killCamEnt delete();
		bombEnt.fxEnt delete();
		bombEnt delete();

		return;
	}
}

showBomb()
{
	self show();
	self.interactingPlayer = undefined;
	self.fxEnt = spawnFX(level.ttt.effects.bombBlink, self.origin + (0, 0, 2) + anglesToRight(self.angles) * 3);
	triggerFx(self.fxEnt);
	self scripts\ttt\use::makeUsableCustom(
		::OnDefuseBomb,
		::OnBombEntAvailable,
		::OnBombEntAvailableEnd
	);
}

hideBomb(player)
{
	self.interactingPlayer = player;
	self hide();
	self.fxEnt delete();
	self scripts\ttt\use::makeUnusableCustom();
}

stopBombInteraction(isDone, bombWeaponName)
{
	if (!isDefined(isDone)) isDone = false;

	self notify("ttt_bomb_interaction_canceled");

	self unfreezePlayer();
	self thread detachBombModel();
	if (isDone)
	{
		self setWeaponAmmoClip(bombWeaponName, 1);
		self setWeaponAmmoStock(bombWeaponName, 1);
	}
	if (isAlive(self)) self switchToLastWeapon();
}

OnBombInteractionInterrupt(bombEnt)
{
	self endon("ttt_planted_bomb");
	self endon("ttt_defused_bomb");
	self endon("ttt_bomb_interaction_canceled");

	self waittill_any("disconnect", "death");

	self stopBombInteraction();
	if (isDefined(bombEnt)) bombEnt showBomb();
}

attachBombModel()
{
	self endon("death");
	self endon("disconnect");
	self endon("ttt_bomb_interaction_canceled");

	self thread detachBombModel();

	wait(0.4);

	self attach("prop_suitcase_bomb", "tag_inhand", true);
}
detachBombModel()
{
	self endon("death");
	self endon("disconnect");

	wait(0.15);

	self detach("prop_suitcase_bomb", "tag_inhand");
}

OnBombEntAvailable(bombEnt)
{
	label = &"Hold [ ^3[{+activate}] ^7] to ^3defuse^7 the bomb\n\n^7Explodes in: ^1";
	if (getDvarFloat("ttt_bomb_defuse_failure_pct") > 0.0)
		label = &"Hold [ ^3[{+activate}] ^7] to ^3risk defusing^7 the bomb\n\n^7Explodes in: ^1";
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(
		label,
		undefined,
		getBombSecondsRemaining(bombEnt)
	);
}
OnBombEntAvailableEnd(bombEnt)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

getBombSecondsRemaining(bombEnt)
{
	return max(0, ceil(getDvarInt("ttt_bomb_timer") - (getTime() - bombEnt.birthtime) / 1000));
}

OnBombDeath()
{
	self waittill("death");

	level.ttt.bombs = array_remove(level.ttt.bombs, self);
	scripts\ttt\ui::updateBombHuds();
	if (isDefined(self.interactingPlayer)) self.interactingPlayer stopBombInteraction();
}

bombThink()
{
	self endon("death");

	TICK_SOUND = "weap_fraggrenade_pin";
	if (level.ttt.modEnabled) TICK_SOUND = "bomb_tick_world";

	for (;;)
	{
		wait(1.0);

		scripts\ttt\ui::updateBombHuds();

		secondsRemaining = getBombSecondsRemaining(self);
		self playSound(TICK_SOUND);
		if (secondsRemaining <= 10) self thread playSoundDelayed(TICK_SOUND, 0.5);
		if (secondsRemaining <= 5)
		{
			self thread playSoundDelayed(TICK_SOUND, 0.25);
			self thread playSoundDelayed(TICK_SOUND, 0.75);
		}

		foreach (player in scripts\ttt\use::getUseEntAvailablePlayers(self))
			player scripts\ttt\ui::updateUseAvailableHint(undefined, undefined, secondsRemaining);

		if (secondsRemaining > 0) continue;

		self thread explodeBomb();
	}
}

explodeBomb()
{
	RADIUS = getDvarInt("ttt_bomb_radius");

	foreach (player in getLivingPlayers())
	{
		distance = distance(self.origin, player.origin);
		damageNormalized = 1 - distance / RADIUS;
		if (damageNormalized <= 0) continue;
		damage = int(damageNormalized * level.ttt.maxhealth * 3);

		player thread [[level.callbackPlayerDamage]](
			self, // eInflictor The entity that causes the damage. ( e.g. a turret )
			self.owner, // eAttacker The entity that is attacking.
			damage, // iDamage Integer specifying the amount of damage done
			level.iDFLAGS_RADIUS, // iDFlags Integer specifying flags that are to be applied to the damage
			"MOD_EXPLOSIVE", // sMeansOfDeath Integer specifying the method of death
			"none", // sWeapon The weapon number of the weapon used to inflict the damage
			self.origin, // vPoint The point the damage is from?
			vectorNormalize(player.origin - self.origin), // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
		);
	}

	damageableEnts = [];
	damageableEnts = array_combine(getEntArray("grenade", "classname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("misc_turret", "classname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("ttt_destructible_item", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("destructible_toy", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("destructible_vehicle", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("explodable_barrel", "targetname"), damageableEnts);
	damageableEnts = array_combine(getEntArray("vending_machine", "targetname"), damageableEnts);

	foreach (ent in damageableEnts)
	{
		distance = distance(self.origin, ent.origin);
		damageNormalized = 1 - distance / RADIUS;
		if (damageNormalized <= 0) continue;
		damage = int(damageNormalized * 1000);

		ent notify(
			"damage",
			damage, // damage
			self.owner, // attacker
			vectorNormalize(ent.origin - self.origin), // direction_vec
			self.origin, // point
			"MOD_EXPLOSIVE", // type
			"", // modelName
			"", // tagName
			"", // partName
			level.iDFLAGS_RADIUS // iDFlags
		);
	}

	scriptVehicles = getEntArray("script_vehicle", "classname");

	foreach (vehicle in scriptVehicles)
	{
		distance = distance(self.origin, vehicle.origin);
		damageNormalized = 1 - distance / (RADIUS * 1.5);
		if (damageNormalized <= 0) continue;
		damage = int(damageNormalized * 2000);

		if (vehicle.damageTaken + damage >= vehicle.maxhealth) vehicle.largeProjectileDamage = true;
		vehicle maps\mp\gametypes\_callbacksetup::CodeCallback_VehicleDamage(
			self,
			self.owner,
			damage,
			0,
			"MOD_EXPLOSIVE",
			"none",
			self.origin,
			vehicle.origin - self.origin,
			"none",
			0,
			0,
			""
		);
	}

	/*
	foreach (player in level.players)
	{
		player thread drawDebugLine(self.origin - (RADIUS, 0, 0), self.origin + (RADIUS, 0, 0), (1, 0, 0), 120);
		player thread drawDebugLine(self.origin - (0, RADIUS, 0), self.origin + (0, RADIUS, 0), (0, 1, 0), 120);
		player thread drawDebugLine(self.origin - (0, 0, RADIUS), self.origin + (0, 0, RADIUS), (0, 0, 1), 120);

		player thread drawDebugCircle(self.origin, RADIUS / 1.5, (1, 0.5, 0.5), 600);
		player thread drawDebugCircle(self.origin, RADIUS, (1, 1, 1), 600);
	}
	*/

	glassRadiusDamage(self.origin + (0, 0, 24), RADIUS, 300, 20);
	physicsExplosionSphere(self.origin, RADIUS + 512, RADIUS, 2.5);
	earthquake(0.75, 2.0, self.origin, RADIUS * 2);
	self playSound("exp_suitcase_bomb_main");
	playFX(level.ttt.effects.bombExplosion, self.origin);

	if (RADIUS >= 640)
	{
		FX_COUNT = 8;
		for (i = 0; i < FX_COUNT; i++)
		{
			forward = anglesToForward(combineAngles((0, 360 / FX_COUNT * i, 0), (0, randomFloatRange(-10, 10), 0)));
			thread playFXDelayed(
				level.ttt.effects.bombOuterExplosion,
				self.origin + forward * (RADIUS - 800) + (0, 0, randomIntRange(-128, 384)),
				randomFloatRange(0.05, 0.8)
			);
		}
	}

	self.killCamEnt delete();
	self.fxEnt delete();
	self delete();
}

OnBuyHelicopter()
{
	level.heli_target_spawnprotection = 8;
	level.heli_turretClipSize = 32; // helicopter only gets accurate after ~20 shots
	level.heli_maxhealth = 500;
	self maps\mp\killstreaks\_helicopter::startHelicopter(-1);
}

getIsAvailableHelicopter()
{
	return !isDefined(level.chopper);
}

OnBuyRiot(item)
{
	self setRoleInventory(item);
	self OnPickupRiot();
}
OnPickupRiot(item)
{
	self.hasRiotShield = true;
	self AttachShieldModel("weapon_riot_shield_mp", "tag_shield_back");
}

OnBuySpas(item)
{
	self setRoleInventory(item, 8, 0);
}

OnBuyConcussion()
{
	WEAPON_NAME = "concussion_grenade_mp";
	self giveWeapon(WEAPON_NAME);
	self setWeaponAmmoClip(WEAPON_NAME, 1);
	self SetOffhandSecondaryClass("smoke");
}

OnBuyLob()
{
	self.ttt.pickups.dropVelocity = 512;
	self.ttt.pickups.dropCanDamage = true;
}

OnBuyHealthStation(item)
{
	self setRoleInventory(item);
}

OnActivateHealthStation(item)
{
	eyePos = self getEye();
	spawnPos = physicsTrace(eyePos, eyePos + anglesToForward(self.angles) * 64);
	spawnPos -= anglesToForward(self.angles) * 16;
	spawnPos = physicsTrace(spawnPos, spawnPos - (0, 0, self getPlayerViewHeight())) + (0, 0, 16);

	spawnPosLeft = spawnPos + anglesToRight(self.angles) * -20;
	spawnPosRight = spawnPos + anglesToRight(self.angles) * 20;
	if (positionWouldTelefrag(spawnPos) || positionWouldTelefrag(spawnPosLeft) || positionWouldTelefrag(spawnPosRight))
	{
		self iPrintLnBold("You cannot place a health station here");
		return;
	}

	self takeRoleWeapon();
	self switchToLastWeapon();
	self resetRoleInventory();

	healthStation = spawn("script_model", spawnPos);
	healthStation.targetname = "ttt_destructible_item";
	healthStation setModel("com_plasticcase_friendly");
	healthStation.angles = self.angles + (0, 90, 0);
	healthStation cloneBrushmodelToScriptmodel(level.airDropCrateCollision);
	healthStation physicsLaunchServer();
	healthStation.hp = int(level.ttt.maxhealth * 2);
	healthStation.lastDispenseTime = 0;
	healthStation.inUse = false;

	healthStation setCanDamage(true);
	healthStation.maxhealth = 500;
	healthStation.health = healthStation.maxhealth;
	healthStation.damageTaken = 0;
	healthStation thread OnHealthStationDamage();
	healthStation thread OnHealthStationDeath();

	healthStation scripts\ttt\use::makeUsableCustom(
		::OnHealthStationTrigger,
		::OnHealthStationAvailable,
		::OnHealthStationAvailableEnd, 80, 45, 0, true
	);
}

OnHealthStationDamage()
{
	self endon("death");

	for (;;)
	{
		self waittill("damage", damage, attacker);

		self.damageTaken += damage;

		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
		playFX(level._effect["sentry_smoke_mp"], self.origin);
		self playSound("bullet_ap_crate");

		if (self.damageTaken > self.maxhealth) self notify("death");
	}
}

OnHealthStationDeath()
{
	self waittill("death", attacker);

	attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
	playFX(level._effect["sentry_explode_mp"], self.origin);
	self playSound("sentry_explode");
	wait(4);
	self delete();
}

OnHealthStationTrigger(healthStation)
{
	if (healthStation.inUse) return;

	healthStation.inUse = true;
	self thread healthStationUseThink(healthStation);
}

healthStationUseThink(healthStation)
{
	healthStation endon("death");

	ticksUsed = 0;

	while (isAlive(self) && self useButtonPressed() && self scripts\ttt\use::isUseEntAvailable(healthStation))
	{
		if (healthStation.lastDispenseTime <= getTime() - 100 && healthStation.hp > 0 && self.health < level.ttt.maxhealth)
		{
			self.health++;
			self.maxhealth = self.health;
			healthStation.hp--;
			healthStation.lastDispenseTime = getTime();

			if (healthStation.hp <= 0) healthStation notify("death");

			if (ticksUsed == 0) healthStation playSound("intelligence_pickup");
			else if (ticksUsed % 2 == 1) healthStation playSound("gear_rattle_sprint");

			foreach (player in scripts\ttt\use::getUseEntAvailablePlayers(healthStation))
				player scripts\ttt\ui::updateUseAvailableHint(undefined, undefined, healthStation.hp);

			ticksUsed++;
		}

		wait(0.05);
	}

	healthStation.inUse = false;
}

OnHealthStationAvailable(healthStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
	self scripts\ttt\ui::displayUseAvailableHint(
		&"Hold [ ^3[{+activate}] ^7] to ^3heal^7 yourself\n\nAvailable health: ^2",
		undefined,
		healthStation.hp
	);
}
OnHealthStationAvailableEnd(healthStation)
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

OnBuyCamera(item)
{
	self setRoleInventory(item);
}

OnEquipCamera(item, data)
{
	cameraEnt = spawn("script_model", self.origin);
	cameraEnt notSolid();
	cameraEnt hide();
	cameraEnt showToPlayer(self);
	cameraEnt.placed = false;
	cameraEnt.validPosition = false;
	data.cameraEnt = cameraEnt;

	if (level.ttt.modEnabled) cameraEnt scriptModelPlayAnim("security_camera_idle");

	self thread cameraPlacementThink(cameraEnt);
}

cameraPlacementThink(cameraEnt)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_camera_placed");
	self endon("ttt_roleweapon_unequipped");

	for (i = 0; ; i++)
	{
		eyePos = self getEye();
		forward = anglesToForward(self getPlayerAngles());

		trace = bulletTrace(eyePos, eyePos + forward * 128, false, cameraEnt);
		normal = trace["normal"];
		position = trace["position"];
		if (!level.ttt.modEnabled) position += normal * 1.6;

		// If a surface is hit, flip the normal to have the correct orientation:
		if (trace["fraction"] == 1.0) normal *= -1;
		surfaceAngle = vectorToAngles(normal)[0];

		if (trace["fraction"] < 1.0 && (surfaceAngle < 40 || surfaceAngle > 360 - 40))
		{
			cameraEnt.validPosition = true;

			if (level.ttt.modEnabled)
				cameraEnt setModel("com_security_camera_tilt_animated");
			else
				cameraEnt setModel("weapon_c4");
		}
		else
		{
			cameraEnt.validPosition = false;

			if (level.ttt.modEnabled)
				cameraEnt setModel("com_security_camera_tilt_animated_bombsquad");
			else
				cameraEnt setModel("weapon_c4_bombsquad");
		}

		angles = vectorToAngles(normal);
		if (level.ttt.modEnabled)
			angles = combineAngles(angles, (0, 90, 0));
		else
			angles = combineAngles(angles, (90, 0, 0));

		if (i == 0)
		{
			cameraEnt.origin = position;
			cameraEnt.angles = angles;
		}
		else
		{
			cameraEnt moveTo(position, 0.05);
			cameraEnt rotateTo(angles, 0.05);
		}

		wait(0.05);

		cameraEnt.origin = position;
		cameraEnt.angles = angles;
	}
}

OnUnequipCamera(item, data)
{
	if (!isDefined(data.cameraEnt.placed) || !data.cameraEnt.placed) data.cameraEnt delete();
}

OnActivateCamera(item, data)
{
	cameraEnt = data.cameraEnt;
	if (cameraEnt.placed) return;

	if (!isDefined(cameraEnt.validPosition) || !cameraEnt.validPosition)
	{
		self iPrintLnBold("Camera needs to be placed on a wall");
		return;
	}

	cameraEnt.placed = true;

	angles = cameraEnt.angles;
	if (level.ttt.modEnabled)
		angles = combineAngles(angles, (0, -90, 0));
	else
		angles = combineAngles(angles, (-90, 0, 0));
	cameraEnt.viewTargetEnt = spawn("script_model", cameraEnt.origin + anglesToForward(angles) * 32 + anglesToUp(angles) * -48);
	cameraEnt.viewTargetEnt.angles = angles;
	cameraEnt.viewTargetEnt setModel("sentry_minigun");
	cameraEnt.viewTargetEnt linkTo(cameraEnt);
	cameraEnt.viewTargetEnt hide();

	offset = (-3.5, 2, -3);
	if (level.ttt.modEnabled) offset = (-0.5, 7, 0.75);
	cameraEnt.fxTargetIdle = spawn(
		"script_model",
		cameraEnt.origin + anglesToRight(angles) * offset[0] + anglesToForward(angles) * offset[1] + anglesToUp(angles) * offset[2]
	);
	cameraEnt.fxTargetIdle setModel("tag_origin");
	cameraEnt.fxTargetIdle linkTo(cameraEnt);
	// It's necessary to wait for the entity to be networked to players or something.
	// Waiting a single tick isn't always enough:
	thread playFxOnTagDelayed(level.ttt.effects.cameraIdle, cameraEnt.fxTargetIdle, "tag_origin", 0.25);

	cameraEnt.fxTargetActive = spawn(
		"script_model",
		cameraEnt.fxTargetIdle.origin + anglesToRight(angles) * 2.5
	);
	cameraEnt.fxTargetActive setModel("tag_origin");
	cameraEnt.fxTargetActive linkTo(cameraEnt);

	cameraEnt.targetname = "ttt_destructible_item";
	cameraEnt solid();
	cameraEnt setCanDamage(true);
	cameraEnt.maxhealth = 300;
	cameraEnt.health = cameraEnt.maxhealth;
	cameraEnt.damageTaken = 0;
	cameraEnt.destroyed = false;
	cameraEnt.usingPlayer = undefined;
	cameraEnt thread OnCameraDamage();
	cameraEnt thread OnCameraDeath(data);

	self notify("ttt_camera_placed");
	cameraEnt show();

	self takeRoleWeapon();
	self switchToLastWeapon();
	self resetRoleInventory();

	receiverData = spawnStruct();
	receiverData.beingUsed = false;
	receiverData.cameraEnt = cameraEnt;
	self giveItem(level.ttt.items["internal"]["camera_receiver"], receiverData);
}

OnCameraDamage()
{
	self endon("death");

	for (;;)
	{
		self waittill("damage", damage, attacker);

		self.damageTaken += damage;

		attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
		playFX(level._effect["sentry_smoke_mp"], self.origin);
		self playSound("bullet_ap_crate");

		if (self.damageTaken > self.maxhealth) self notify("death");
	}
}

OnCameraDeath(data)
{
	self waittill("death", attacker);

	self.destroyed = true;

	attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("ttt_item");
	self.viewTargetEnt delete(); // automatically disconnects the player's view
	self.fxTargetIdle delete();
	self.fxTargetActive delete();

	self notify("destroyed");

	if (level.ttt.modEnabled)
	{
		self scriptModelClearAnim();
		self setModel("com_security_camera_d_tilt_animated");
		self scriptModelPlayAnim("security_camera_destroy");
		self playSound("security_camera_sparks");
		thread playFxOnTagDelayed(level.ttt.effects.cameraExplosion, self, "tag_fx", 0.1);
	}
	else
	{
		self playSound("sentry_explode");
		playFX(level._effect["sentry_explode_mp"], self.origin);

		wait(4);

		self delete();
	}
}

OnBuyCamReceiver(item, data)
{
	self setRoleInventory(item, 1, 0, data);
}

OnEquipCamReceiver(item, data)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_roleweapon_unequipped");
	self endon("ttt_cam_receiver_unequip_started");

	self scripts\ttt\ui::destroySelfHud();

	wait (1.1);

	self thread trySetPlayerToCamera(data);
	self thread OnCamReceiverEsc(data);
}

OnCamReceiverEsc(data)
{
	self endon("ttt_roleweapon_unequipped");

	for (;;)
	{
		self waittill("menuresponse", menu, response);
		if (response != "ttt_esc_menu_blocked") continue;

		self notify("ttt_roleweapon_toggle");
		break;
	}
}

OnStartUnequipCamReceiver(item, data, switchToWeaponName)
{
	if (switchToWeaponName == "none") return;

	self thread tryUnsetPlayerFromCamera(data);
	self notify("ttt_cam_receiver_unequip_started");
}

OnUnequipCamReceiver(item, data)
{
	if (isAlive(self))
	{
		self scripts\ttt\ui::destroySelfHud();
		self scripts\ttt\ui::displaySelfHud();
	}
	self thread tryUnsetPlayerFromCamera(data);

	if (self getCurrentWeapon() == "none") self switchToLastWeapon();
}

trySetPlayerToCamera(data)
{
	if (data.beingUsed) return;
	data.beingUsed = true;

	cameraEnt = data.cameraEnt;
	cameraValid = isDefined(cameraEnt) && !cameraEnt.destroyed;

	if (cameraValid) cameraEnt.usingPlayer = self;
	self.ttt.use.canUse = false;
	self.ttt.pickups.canDropWeapons = false;
	self setClientDvar("ui_ttt_block_esc_menu", true);

	if (cameraValid)
		playFxOnTag(level.ttt.effects.cameraActive, cameraEnt.fxTargetActive, "tag_origin");

	self visionSetNakedForPlayer("black_bw", 0.25);

	wait(0.25);

	// Camera view could have been unset in the meantime, so don't continue in that case:
	if (!data.beingUsed) return;

	self visionSetThermalForPlayer("black_bw", 0);
	self visionSetThermalForPlayer(game["thermal_vision"], 0.25);
	self thermalVisionOn();
	self visionSetNakedForPlayer(getDvar("mapname"), 0);

	/**
	 * The killstreak weapons have very low a ADS FoV of 26. When the player's view is linked to
	 * an external entity, the ADS FoV of the current weapon is used. To increase and customize the
	 * FoV, the min FoV on the client is forced with this dvar:
	 */
	self setClientDvar("cg_fovMin", 60);

	self _disableOffhandWeapons();
	self scripts\ttt\ui::displayCameraHud(cameraEnt);

	if (cameraValid)
	{
		self playerLinkWeaponviewToDelta(cameraEnt.viewTargetEnt, "tag_player", 1.0, 60, 60, 25, 25);
		self setPlayerAngles(cameraEnt.viewTargetEnt.angles);
	}
}

tryUnsetPlayerFromCamera(data)
{
	if (!data.beingUsed) return;
	data.beingUsed = false;

	cameraEnt = data.cameraEnt;
	cameraValid = isDefined(cameraEnt) && !cameraEnt.destroyed;

	if (cameraValid) cameraEnt.usingPlayer = undefined;
	self setClientDvar("ui_ttt_block_esc_menu", false);

	stopFxOnTag(level.ttt.effects.cameraActive, cameraEnt.fxTargetActive, "tag_origin");

	if (isAlive(self))
	{
		self visionSetThermalForPlayer("black_bw", 0.25);

		wait (0.25);
	}

	self.ttt.use.canUse = true;
	self.ttt.pickups.canDropWeapons = true;

	self visionSetNakedForPlayer("black_bw", 0);
	self visionSetNakedForPlayer(getDvar("mapname"), 0.25);
	self thermalVisionOff();
	self visionSetThermalForPlayer(game["thermal_vision"], 0);

	self setClientDvar("cg_fovMin", 1);

	self _enableOffhandWeapons();
	self unlink();
	self scripts\ttt\ui::destroyCameraHud();
}
