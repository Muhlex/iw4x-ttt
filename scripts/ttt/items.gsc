#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	level.ttt.effects.bombBlink = loadFX("misc/aircraft_light_red_blink");
	level.ttt.effects.bombExplosion = loadFX("explosions/tanker_explosion");
	level.ttt.effects.bombOuterExplosion = loadFX("explosions/aerial_explosion_large");

	precacheModel("prop_suitcase_bomb");

	level.ttt.bombs = [];

	level.ttt.items = [];
	level.ttt.items["traitor"] = [];
	level.ttt.items["detective"] = [];

	armor = spawnStruct();
	armor.name = "ARMOR";
	armor.description = "^3Passive item\n^7Reduces incoming bullet damage\nby ^220 percent^7.\n\nDefault equipment for detectives.";
	armor.icon = "cardicon_vest_1";
	armor.onBuy = ::OnBuyArmor;
	armor.getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["traitor"][0] = armor;

	level.ttt.items["traitor"][1] = spawnStruct();
	level.ttt.items["traitor"][1].name = "RADAR";
	level.ttt.items["traitor"][1].description = "^3Passive item\n^7Periodically shows the location\nof all players on the minimap.";
	level.ttt.items["traitor"][1].icon = "specialty_uav";
	level.ttt.items["traitor"][1].onBuy = ::OnBuyRadar;
	level.ttt.items["traitor"][1].getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["traitor"][2] = spawnStruct();
	level.ttt.items["traitor"][2].name = "RANGER SHOTGUN";
	level.ttt.items["traitor"][2].description = "^3Exclusive weapon\n^7Strong close-range shotgun\nwhich can fire ^2two shells at once^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["traitor"][2].icon = "weapon_ranger";
	level.ttt.items["traitor"][2].iconWidth = 48;
	level.ttt.items["traitor"][2].iconHeight = 24;
	level.ttt.items["traitor"][2].iconOffsetX = -1;
	level.ttt.items["traitor"][2].onBuy = ::OnBuyRanger;
	level.ttt.items["traitor"][2].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["traitor"][2].weaponName = "ranger_mp";

	level.ttt.items["traitor"][3] = spawnStruct();
	level.ttt.items["traitor"][3].name = "ROCKET LAUNCHER";
	level.ttt.items["traitor"][3].description = "^3Exclusive weapon\n^7RPG-7 explosive launcher.\nHolds 1 rocket. ^1Can't pick up ammo^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["traitor"][3].icon = "weapon_rpg7";
	level.ttt.items["traitor"][3].iconWidth = 44;
	level.ttt.items["traitor"][3].iconHeight = 22;
	level.ttt.items["traitor"][3].iconOffsetX = 1;
	level.ttt.items["traitor"][3].onBuy = ::OnBuyRPG;
	level.ttt.items["traitor"][3].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["traitor"][3].weaponName = "rpg_mp";

	level.ttt.items["traitor"][4] = spawnStruct();
	level.ttt.items["traitor"][4].name = "THROWING KNIFE";
	level.ttt.items["traitor"][4].description = "^3Exclusive equipment\n^7Kills ^2silently^7. Can be ^2picked up\n^7by anyone if it doesn't kill.";
	level.ttt.items["traitor"][4].icon = "equipment_throwing_knife";
	level.ttt.items["traitor"][4].iconOffsetX = 1;
	level.ttt.items["traitor"][4].onBuy = ::OnBuyKnife;
	level.ttt.items["traitor"][4].getIsAvailable = ::getIsAvailableEquipment;

	level.ttt.items["traitor"][5] = spawnStruct();
	level.ttt.items["traitor"][5].name = "CLAYMORE";
	level.ttt.items["traitor"][5].description = "^3Exclusive equipment\n^7Triggers for anyone (^1for yourself too^7).\n^2Highlighted to other traitors^7.";
	level.ttt.items["traitor"][5].icon = "equipment_claymore";
	level.ttt.items["traitor"][5].iconOffsetX = 1;
	level.ttt.items["traitor"][5].onBuy = ::OnBuyClaymore;
	level.ttt.items["traitor"][5].getIsAvailable = ::getIsAvailableEquipment;

	level.ttt.items["traitor"][6] = spawnStruct();
	level.ttt.items["traitor"][6].name = "FLASHBANG";
	level.ttt.items["traitor"][6].description = "^3Exclusive special grenade\n^2Blinds ^7anyone who is caught in\nor looking at the explosion.";
	level.ttt.items["traitor"][6].icon = "weapon_flashbang";
	level.ttt.items["traitor"][6].onBuy = ::OnBuyFlash;
	level.ttt.items["traitor"][6].getIsAvailable = ::getIsAvailableOffhand;

	level.ttt.items["traitor"][7] = spawnStruct();
	level.ttt.items["traitor"][7].name = "BOMB";
	level.ttt.items["traitor"][7].description = "^3Deployable item\n^7Causes a ^2huge explosion ^7after ^3" + getDvarInt("ttt_bomb_timer") + "^7s.\nCan be ^1defused^7. Emits a ^1sound^7.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["traitor"][7].icon = "hud_suitcase_bomb";
	level.ttt.items["traitor"][7].onBuy = ::OnBuyBomb;
	level.ttt.items["traitor"][7].onActivate = ::OnActivateBomb;
	level.ttt.items["traitor"][7].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["traitor"][7].weaponName = "onemanarmy_mp";

	// level.ttt.items["traitor"][8] = spawnStruct();
	// level.ttt.items["traitor"][8].name = "SILENT DISGUISE";
	// level.ttt.items["traitor"][8].description = "^3Passive item\n^2Removes ^7your nametag.\n^2Silences ^7your footsteps.";
	// level.ttt.items["traitor"][8].icon = "specialty_quieter_upgrade";
	// level.ttt.items["traitor"][8].onBuy = ::OnBuyDisguise;
	// level.ttt.items["traitor"][8].getIsAvailable = ::getIsAvailablePassive;

	level.ttt.items["detective"][0] = armor;

	level.ttt.items["detective"][1] = spawnStruct();
	level.ttt.items["detective"][1].name = "RIOT SHIELD";
	level.ttt.items["detective"][1].description = "^3Exclusive weapon\n^2Blocks bullets^7, even when\nit is on your back.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
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
	level.ttt.items["detective"][3].description = "^3Exclusive special grenade\n^2Disorients ^7and ^2slows ^7targets\ncaught in the explosion.";
	level.ttt.items["detective"][3].icon = "weapon_concgrenade";
	level.ttt.items["detective"][3].onBuy = ::OnBuyConcussion;
	level.ttt.items["detective"][3].getIsAvailable = ::getIsAvailableOffhand;

	level.ttt.items["detective"][4] = spawnStruct();
	level.ttt.items["detective"][4].name = "HEALTH STATION";
	level.ttt.items["detective"][4].description = "^3Deployable item\n^7Slowly ^2regenerates health ^7on use.\nCan be placed anywhere.\n\nPress [ ^3[{+actionslot 3}]^7 ] to equip.";
	level.ttt.items["detective"][4].icon = "hint_health";
	level.ttt.items["detective"][4].onBuy = ::OnBuyHealthStation;
	level.ttt.items["detective"][4].onActivate = ::OnActivateHealthStation;
	level.ttt.items["detective"][4].getIsAvailable = ::getIsAvailableRoleItem;
	level.ttt.items["detective"][4].weaponName = "onemanarmy_mp";

	level.ttt.items["detective"][5] = spawnStruct();
	level.ttt.items["detective"][5].name = "INSANE BICEPS";
	level.ttt.items["detective"][5].description = "^3Passive item\n^7Drop weapons with ^2deadly velocity^7.\nDeal ^2more damage ^7at far distances.\n\nPress [ ^3[{+actionslot 1}]^7 ] to drop a weapon.";
	level.ttt.items["detective"][5].icon = "specialty_onemanarmy_upgrade";
	level.ttt.items["detective"][5].onBuy = ::OnBuyLob;
	level.ttt.items["detective"][5].getIsAvailable = ::getIsAvailablePassive;

	foreach (roleItems in level.ttt.items) foreach (item in roleItems) precacheShader(item.icon);
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

	self notifyOnPlayerCommand("buymenu_toggle", "+actionslot 2");
	self notifyOnPlayerCommand("buymenu_close", "weapnext");
	self notifyOnPlayerCommand("buymenu_close", "weapprev");

	for (;;)
	{
		eventName = self waittill_any_return("buymenu_toggle", "buymenu_close");

		if (!self.ttt.items.inBuyMenu && eventName == "buymenu_close") continue;
		if (!isAlive(self) || !isDefined(self.ttt.role) || (self.ttt.role != "traitor" && self.ttt.role != "detective")) continue;

		if (self.ttt.items.inBuyMenu) self thread unsetPlayerBuyMenu(true);
		else self thread setPlayerBuyMenu();
	}
}

setPlayerBuyMenu()
{
	self endon("disconnect");
	self endon("death");
	self endon("buymenu_toggle");
	self endon("buymenu_close");

	LAPTOP_WEAPON = "killstreak_ac130_mp";

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

	self setBlurForPlayer(6, 1.5);
	self freezePlayer();
	self scripts\ttt\ui::destroySelfHud();
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

	self unfreezePlayer();
	if (switchToLastWeapon)
	{
		self switchToLastWeapon();
		self playLaptopSound();
	}
	self setBlurForPlayer(0, 0.75);
	self scripts\ttt\ui::destroyBuyMenu();

	if (isAlive(self))
	{
		self scripts\ttt\ui::displaySelfHud();
		self scripts\ttt\ui::displayHeadIcons();
	}
}

playLaptopSound()
{
	/**
	 * Stowing the laptop makes a distinct sound that only other players can hear.
	 * We recreate this sound for the local player here.
	 */
	self playSoundToPlayer("weap_c4detpack_safety_plr", self);
}

buyMenuThinkLaptop(weaponName)
{
	self endon("disconnect");
	self endon("death");
	self endon("buymenu_toggle");
	self endon("buymenu_close");

	for (;;)
	{
		if (self getCurrentWeapon() != weaponName) self notify("buymenu_close");
		wait(0.2);
	}
}

buyMenuThink()
{
	self endon("disconnect");
	self endon("death");
	self endon("buymenu_toggle");
	self endon("buymenu_close");

	self notifyOnPlayerCommand("menu_up", "+forward");
	self notifyOnPlayerCommand("menu_down", "+back");
	self notifyOnPlayerCommand("menu_left", "+moveleft");
	self notifyOnPlayerCommand("menu_right", "+moveright");
	self notifyOnPlayerCommand("menu_activate", "+activate");
	self notifyOnPlayerCommand("menu_activate", "+attack");
	self notifyOnPlayerCommand("menu_activate", "+gostand");

	for (;;)
	{
		eventName = self waittill_any_return("menu_up", "menu_down", "menu_left", "menu_right", "menu_activate");
		moveDown = 0;
		moveRight = 0;
		if (eventName == "menu_up") moveDown = -1;
		else if (eventName == "menu_down") moveDown = 1;
		else if (eventName == "menu_left") moveRight = -1;
		else if (eventName == "menu_right") moveRight = 1;

		if (moveDown != 0 || moveRight != 0)
			self scripts\ttt\ui::updateBuyMenu(self.ttt.role, moveDown, moveRight);

		if (eventName == "menu_activate")
			self scripts\ttt\items::tryBuyItem(level.ttt.items[self.ttt.role][self.ttt.items.selectedIndex]);
	}
}

resetRoleInventory()
{
	self.ttt.items.roleInventory = spawnStruct();
}
setRoleInventory(item, ammoClip, ammoStock)
{
	if (!isDefined(item)) return;
	if (!isDefined(ammoClip)) ammoClip = 1;
	if (!isDefined(ammoStock)) ammoStock = 0;

	self.ttt.items.roleInventory.item = item;
	self.ttt.items.roleInventory.ammoClip = ammoClip;
	self.ttt.items.roleInventory.ammoStock = ammoStock;
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
isRoleWeaponEquipped()
{
	return self hasRoleWeapon() && self hasWeapon(self.ttt.items.roleInventory.item.weaponName);
}
isRoleWeaponCurrent()
{
	return self isRoleWeaponEquipped() && self getCurrentWeapon() == self.ttt.items.roleInventory.item.weaponName;
}
giveRoleWeapon()
{
	inv = self.ttt.items.roleInventory;
	if (!isDefined(inv.item.weaponName)) return;

	self giveWeapon(inv.item.weaponName);
	self setWeaponAmmoClip(inv.item.weaponName, inv.ammoClip);
	self setWeaponAmmoStock(inv.item.weaponName, inv.ammoStock);

	return inv.item.weaponName;
}
takeRoleWeapon()
{
	weaponName = self.ttt.items.roleInventory.item.weaponName;
	if (!self isRoleWeaponEquipped()) return;

	self.ttt.items.roleInventory.ammoClip = self getWeaponAmmoClip(weaponName);
	self.ttt.items.roleInventory.ammoStock = self getWeaponAmmoStock(weaponName);
	self takeWeapon(weaponName);

	self thread maps\mp\gametypes\_weapons::stowedWeaponsRefresh();
	self notify("role_weapon_taken");

	return weaponName;
}

OnPlayerRoleWeaponToggle()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("roleweapon_toggle", "+actionslot 3");

	for (;;)
	{
		self waittill("roleweapon_toggle");
		if (!self hasRoleWeapon()) continue;

		if (self isRoleWeaponEquipped()) self switchFromRoleWeapon();
		else self equipRoleWeapon();
	}
}

switchFromRoleWeapon()
{
	if (!self isRoleWeaponEquipped()) return;

	switchToWeaponName = getLastWeapon();
	if (!isDefined(switchToWeaponName) || switchToWeaponName == self.ttt.items.roleInventory.item.weaponName)
		switchToWeaponName = self getWeaponsListPrimaries()[0];

	self switchToWeapon(switchToWeaponName);
}

equipRoleWeapon()
{
	if (self isRoleWeaponEquipped()) return;
	if (!maps\mp\gametypes\_weapons::mayDropWeapon(self getCurrentWeapon())) return;

	weaponName = self giveRoleWeapon();
	self switchToWeapon(weaponName);
	self thread OnRoleWeaponEquipCancel();
	self thread OnRoleWeaponStow();
}

OnRoleWeaponEquipCancel()
{
	self endon("disconnect");
	self endon("death");
	self endon("weapon_change");
	self endon("role_weapon_taken");

	self waittill("weapon_switch_cancelled");

	self takeRoleWeapon();
}

OnRoleWeaponStow()
{
	self endon("disconnect");
	self endon("death");
	self endon("role_weapon_taken");

	for (;;)
	{
		self waittill("weapon_change", newWeaponName);
		if (newWeaponName == self.ttt.items.roleInventory.item.weaponName || newWeaponName == "none") continue;

		self takeRoleWeapon();
		break;
	}
}

OnPlayerRoleWeaponActivate()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("roleweapon_activate", "+attack");

	for (;;)
	{
		self waittill("roleweapon_activate");
		if (!self isRoleWeaponCurrent()) continue;

		item = self.ttt.items.roleInventory.item;
		if (!isDefined(item.onActivate)) continue;
		self thread [[item.onActivate]](item);
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

	if (self.ttt.role == "detective" && victim.ttt.role == "traitor")
	{
		self awardCredits(victim.ttt.items.credits);
		victim.ttt.items.credits = 0;
	}
}

giveItem(item)
{
	self.ttt.items.boughtItems[self.ttt.items.boughtItems.size] = item;
	self thread [[item.onBuy]](item);
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

	self notify("ttt_defusing_bomb");
	self endon("ttt_defusing_bomb");

	BOMB_WEAPON = "briefcase_bomb_defuse_mp";

	if (!maps\mp\gametypes\_weapons::mayDropWeapon(self getCurrentWeapon())) return;

	self giveWeapon(BOMB_WEAPON);
	self setWeaponAmmoClip(BOMB_WEAPON, 0);
	self setWeaponAmmoStock(BOMB_WEAPON, 0);
	self switchToWeapon(BOMB_WEAPON);

	bombEnt hideBomb();

	self thread OnBombInteractionInterrupt(bombEnt);

	TIMEOUT = 1.5 * 1000;
	startTime = getTime();
	while (self getCurrentWeapon() != BOMB_WEAPON || !self isOnGround())
	{
		wait(0.05);
		if (startTime + TIMEOUT < getTime())
		{
			bombEnt showBomb();
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

hideBomb()
{
	self.interactingPlayer = self;
	self hide();
	self.fxEnt delete();
	self scripts\ttt\use::makeUnusableCustom();
}

stopBombInteraction(isDone, bombWeaponName)
{
	if (!isDefined(isDone)) isDone = false;

	self notify("ttt_bomb_interaction_stopped");

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

	self waittill_any("disconnect", "death");

	self stopBombInteraction();
	if (isDefined(bombEnt)) bombEnt showBomb();
}

attachBombModel()
{
	self endon("death");
	self endon("disconnect");
	self endon("ttt_bomb_interaction_stopped");

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

	for (;;)
	{
		wait(1.0);

		scripts\ttt\ui::updateBombHuds();

		secondsRemaining = getBombSecondsRemaining(self);
		self playSound("weap_fraggrenade_pin");
		playFXOnTag("tag_origin", self, level.ttt.effects.bombBlink);
		if (secondsRemaining <= 10) self thread playSoundDelayed("weap_fraggrenade_pin", 0.5);
		if (secondsRemaining <= 5)
		{
			self thread playSoundDelayed("weap_fraggrenade_pin", 0.25);
			self thread playSoundDelayed("weap_fraggrenade_pin", 0.75);
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
	// radiusDamage(self.origin, RADIUS, level.ttt.maxhealth * 2, 0, attacker);
	foreach (player in getLivingPlayers())
	{
		distance = distance(self.origin, player.origin);
		damageNormalized = 1 - distance / RADIUS;
		damage = int(damageNormalized * level.ttt.maxhealth * 3);
		if (damage <= 0) continue;
		player thread [[level.callbackPlayerDamage]](
			self, // eInflictor The entity that causes the damage. ( e.g. a turret )
			self.owner, // eAttacker The entity that is attacking.
			damage, // iDamage Integer specifying the amount of damage done
			0, // iDFlags Integer specifying flags that are to be applied to the damage
			"MOD_EXPLOSIVE", // sMeansOfDeath Integer specifying the method of death
			"none", // sWeapon The weapon number of the weapon used to inflict the damage
			self.origin, // vPoint The point the damage is from?
			player.origin - self.origin, // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
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

	physicsExplosionSphere(self.origin, RADIUS, int(RADIUS / 3), 2.5);
	earthquake(0.75, 2.0, self.origin, RADIUS * 2);
	self playSound("exp_suitcase_bomb_main");
	playFX(level.ttt.effects.bombExplosion, self.origin);
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

	self.killCamEnt delete();
	self.fxEnt delete();
	self delete();
}

OnBuyDisguise()
{
	self maps\mp\perks\_perks::givePerk("specialty_quieter");
	self maps\mp\perks\_perks::givePerk("specialty_spygame");
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
		self iPrintLnBold("You cannot place a health station here.");
		return;
	}

	self takeRoleWeapon();
	self switchToLastWeapon();
	self resetRoleInventory();

	healthStation = spawn("script_model", spawnPos);
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
		self waittill("damage");

		playFX(level._effect["sentry_smoke_mp"], self.origin);
		self playSound("bullet_ap_crate");
	}
}

OnHealthStationDeath()
{
	self waittill("death");

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
