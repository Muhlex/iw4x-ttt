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
	level.ttt.effects.smokeGrenade = loadFX("props/american_smoke_grenade_mp");

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

	scripts\ttt\items\armor::init();

	scripts\ttt\items\radar::init();
	scripts\ttt\items\helicopter::init();
	scripts\ttt\items\bomb::init();
	scripts\ttt\items\rpg::init();
	scripts\ttt\items\ranger::init();
	scripts\ttt\items\throwingknife::init();
	scripts\ttt\items\claymore::init();
	scripts\ttt\items\flash::init();
	scripts\ttt\items\smoke::init();

	scripts\ttt\items\speed::init();
	scripts\ttt\items\lethaldrop::init();
	scripts\ttt\items\riotshield::init();
	scripts\ttt\items\spas12::init();
	scripts\ttt\items\concussion::init();
	scripts\ttt\items\healthstation::init();
	scripts\ttt\items\camera::init();
	scripts\ttt\items\smell::init();

	foreach (roleItems in level.ttt.items) foreach (item in roleItems)
	{
		precacheShader(item.icon);
		if (level.ttt.modEnabled) precacheItem(item.weaponName);
	}
}

registerItem(item, role, id)
{
	key = role;
	if (!isDefined(role)) key = "internal";
	if (!isDefined(id)) id = level.ttt.items[key].size;
	if (isDefined(role)) item.role = role;

	level.ttt.items[key][id] = item;
}

getUnavailableHint(type)
{
	switch (type)
	{
		case "roleitem": return &"^1Item inventory ^7[ [{+actionslot 3}] ]^1 is occupied";
		case "equipment": return &"^1Already carrying equipment ^7[ [{+frag}] ]^1";
		case "offhand": return &"^1Already carrying special grenade ^7[ [{+smoke}] ]^1";
	}
}

initPlayer()
{
	self.ttt.items = spawnStruct();
	self.ttt.items.inBuyMenu = false;
	self.ttt.items.selectedIndex = 0;
	self.ttt.items.rowsScrolled = 0;
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
	self scripts\ttt\ui::destroyBombHud();
	self scripts\ttt\ui::destroyBuyMenu();
	self scripts\ttt\ui::displayBuyMenu(self.ttt.role);
	self thread buyMenuThink();
	self thread buyMenuThinkLaptop(LAPTOP_WEAPON);
	self thread OnPlayerBuyMenuEsc();
}

OnPlayerBuyMenuEsc()
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_buymenu_toggle");
	self endon("ttt_buymenu_close");

	for (;;)
	{
		self waittill("menuresponse", menu, response);

		if (response != "ttt_esc_menu_blocked") continue;

		if (self.ttt.items.inBuyMenu) self thread unsetPlayerBuyMenu(true);
	}
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

	if (isAlive(self))
	{
		self scripts\ttt\ui::displayHeadIcons();
		self scripts\ttt\ui::displayBombHud();
	}
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
		else if (scripts\ttt\pickups::isWeaponDroppable(self getCurrentWeapon())) self giveRoleWeapon();
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

setStartingCredits()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "traitor") self.ttt.items.credits = getDvarInt("ttt_traitor_start_credits");
	if (self.ttt.role == "detective") self.ttt.items.credits = getDvarInt("ttt_detective_start_credits");
}

setStartingItems()
{
	if (!isDefined(self.ttt.role)) return;
	if (self.ttt.role == "detective") self giveItem(level.ttt.items["internal"]["armor"]);
}

awardCredits(amount)
{
	if (amount < 1) return;

	self.ttt.items.credits += amount;
	feedback = "You received ^1" + amount + "^7 shop credits";
	if (amount == 1) feedback = "You received ^1" + amount + "^7 shop credit";
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

awardBodyInspectCredits(bodyEnt)
{
	if (!isDefined(self.ttt.role) || !isDefined(bodyEnt.ownerData["role"])) return;

	if (self.ttt.role == "detective" && bodyEnt.credits > 0)
	{
		self awardCredits(bodyEnt.credits);
		bodyEnt.credits = 0;
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

resetPlayerEquipment()
{
	// Make anyone able to pick up throwing knives:
	self giveWeapon("throwingknife_mp");
	self setWeaponAmmoClip("throwingknife_mp", 0); // remove the '1' ammo from the throwing knife weapon
	self SetOffhandPrimaryClass("throwingknife"); // set throwing knife as 'active' equipment so it can be used once picked up
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
