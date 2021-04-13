#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	level.ttt = spawnStruct();
	level.ttt.enabled = !!getDvarInt("ttt");
	if (!level.ttt.enabled) return;

	level.ttt.maxhealth = getDvarInt("scr_player_maxhealth");
	level.ttt.headshotMultiplier = getDvarFloat("ttt_headshot_multiplier");
	level.ttt.headshotMultiplierSniper = getDvarFloat("ttt_headshot_multiplier_sniper");
	level.ttt.explosiveMultiplier = getDvarFloat("ttt_explosive_multiplier");
	level.ttt.preptime = getDvarInt("ttt_preptime");
	if (level.ttt.preptime < 1) level.ttt.preptime = 1;

	level.ttt.prematch = true;
	level.ttt.preparing = true;

	level.inGracePeriod = false;

	setDvar("scr_player_forceautoassign", "1");
	setDvar("scr_player_forcerespawn", "1");
	setDvar("scr_game_hardpoints", "0");
	setDvar("scr_teambalance", "0");
	setDvar("scr_game_spectatetype", "2");

	setDvar("scr_dm_scorelimit", "0");
	setDvar("scr_dm_timelimit", (getDvarFloat("ttt_roundtime") + level.ttt.preptime / 60));
	setDvar("scr_dm_numlives", "0");
	setDvar("scr_dm_winlimit", "0");

	if (getDvar("g_gametype") != "dm")
	{
		setDvar("g_gametype", "dm");
		map_restart();
	}

	scripts\ttt\items::init();
	scripts\ttt\pickups::init();
	scripts\ttt\ui::init();

	thread OnPrematchOver();
	thread OnRoundRestart();

	thread OnPlayerConnect();

	wait(0.05); // wait for the dm script to execute
	setDvar("g_deadChat", "0");
}

initPlayer()
{
	self.ttt = spawnStruct();
	self.ttt.role = undefined;
	self.ttt.bodyFound = false;
	self.ttt.inBuyMenu = false;
	self.ttt.incomingDamageMultiplier = 1.0;

	self scripts\ttt\items::initPlayer();
	self scripts\ttt\ui::initPlayer();

	wait(0.05);
	self setClientDvars(
		"cg_deadChatWithDead", 1,
		"cg_deadChatWithTeam", 0,
		"cg_deadHearTeamLiving", 1,
		"cg_deadHearAllLiving", 1,
		"cg_everyoneHearsEveryone", 0
	);
}

OnPrematchOver()
{
	level endon("game_ended");
	level waittill("prematch_over");

	level.ttt.prematch = false;
	//visionSetNaked("sepia", 1.0);

	thread OnRoundStart();
}

OnRoundRestart()
{
	level endon("game_ended");
	level waittill("restarting");

	thread OnRoundStart();
}

OnRoundStart()
{
	thread scripts\ttt\pickups::spawnWorldPickups();

	thread OnPreptimeEnd();
	thread OnTimelimitReached();
}

OnPreptimeEnd()
{
	level endon("game_ended");

	wait(level.ttt.preptime);
	level.ttt.preparing = false;

	drawPlayerRoles();

	foreach(player in getLivingPlayers())
	{
		player.maxhealth = level.ttt.maxhealth;
		player.health = player.maxhealth;

		player.isRadarBlocked = true;

		player scripts\ttt\items::setStartingCredits();
		player scripts\ttt\items::setStartingPerks();
	}

	foreach (player in level.players) player scripts\ttt\ui::displayHeadIcons();
	level.disableSpawning = true;
	//visionSetNaked(getDvar("mapname"), 2.0);

	checkRoundWinConditions();
}

OnTimelimitReached()
{
	level endon("game_ended");

	level waittill("ttt_timelimit_reached");
	endRound("innocent", "timelimit");
}

OnAftertimeEnd()
{
	level endon("game_ended");

	wait(getDvarInt("ttt_aftertime"));

	scripts\ttt\ui::destroyRoundEnd();

	foreach (player in level.players) player.cancelKillcam = true;
	wait(0.05);
	level notify("round_end_finished"); // kicks off the final killcam
	while (level.showingFinalKillcam) wait(0.05);

	level.gameEnded = false;

	game["roundsPlayed"]++;
	if (game["roundsPlayed"] >= getDvarInt("ttt_roundlimit"))
	{
		thread maps\mp\gametypes\_gamelogic::endGame("tie", "Round limit reached");
		return;
	}

	map_restart(true);
	level notify("restarting");
}

OnPlayerConnect()
{
	level endon("game_ended");

	for (;;)
	{
		level waittill("connected", player);

		player thread initPlayer();

		if (getLivingPlayers().size <= 1 && !level.gameEnded && !level.ttt.preparing) map_restart(true);

		player thread OnPlayerDisconnect();
		player thread OnPlayerSpawn();
		player thread OnPlayerDeath();
		player thread OnPlayerEnemyKilled();
		player thread OnPlayerRagdoll();
		player thread OnPlayerScoreboardOpen();
		player thread OnPlayerScoreboardClose();
	}
}

OnPlayerDisconnect()
{
	self waittill ("disconnect");

	checkRoundWinConditions();
}

OnPlayerSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		self takeAllWeapons();
		self _clearPerks();
		self SetOffhandPrimaryClass("other");
		self _SetActionSlot(1, ""); // disable nightvision
		self scripts\ttt\items::resetPlayerEquipment();

		//spawnWeapon = "usp_tactical_mp";

		//self giveWeapon(spawnWeapon);
		//self SetWeaponAmmoClip(spawnWeapon, 0);
		//self SetWeaponAmmoStock(spawnWeapon, 0);
		//self setSpawnWeapon(spawnWeapon);

		self scripts\ttt\ui::displaySelfHud();

		self thread OnPlayerDropWeapon();
		self thread OnPlayerBuyMenu();
		self thread OnPlayerHealthUpdate();
	}
}

OnPlayerDeath()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("death");

		self scripts\ttt\ui::destroySelfHud();
		self unsetPlayerBuyMenu();
		checkRoundWinConditions();
	}
}

OnPlayerEnemyKilled()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("killed_enemy", victim);

		self scripts\ttt\items::awardKillCredits(victim);
	}
}

OnPlayerRagdoll()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("start_ragdoll");

		if (level.ttt.preparing) continue;

		body = spawn("script_model", self.body.origin);
		body linkTo(self.body, "tag_origin", (0, 0, 32), (0, 0, 0));
		body setCursorHint("HINT_NOICON");
		body setHintString("^3Unidentified body^7\nPress ^3[{+activate}]^7 to inspect");
		body makeUsable();
		foreach (player in level.players) body enablePlayerUse(player);
		body thread playerBodyThink(self);
	}
}

playerBodyThink(owner)
{
	while (isDefined(self))
	{
		self waittill ("trigger", player);

		player scripts\ttt\items::awardBodyInspectCredits(owner);

		roleTextColor = "";
		switch (owner.ttt.role)
		{
			case "innocent":
				roleTextColor = "^2";
				break;
			case "traitor":
				roleTextColor = "^1";
				break;
			case "detective":
				roleTextColor = "^4";
				break;
		}

		playerName = removeColorsFromString(player.name);
		ownerName = removeColorsFromString(owner.name);

		if (!owner.ttt.bodyFound)
		{
			owner.ttt.bodyFound = true;
			self setHintString(roleTextColor + ownerName + "^7\nPress ^3[{+activate}]^7 to inspect");
			foreach (p in level.players)
			{
				if (p == player) p iPrintLnBold("You found the body of ^3" + ownerName + "^7. They were " + roleTextColor + owner.ttt.role + "^7.");
				else p iPrintLnBold(playerName + "^7 found the body of ^3" + ownerName + "^7. They were " + roleTextColor + owner.ttt.role + "^7.");
			}
		}
		else player iPrintLnBold("This is the body of ^3" + ownerName + "^7. They were " + roleTextColor + owner.ttt.role + "^7.");
	}
}

OnPlayerDropWeapon()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("drop_weapon", "+actionslot 1");

	for (;;)
	{
		self waittill("drop_weapon");

		weapon = self getCurrentWeapon();
		if (!isDefined(weapon) || weapon == "killstreak_ac130_mp") continue;
		if (self getWeaponsListPrimaries().size <= 1) continue; // actually gets all regular guns
		item = self dropItem(weapon);
		lastWeapon = self getLastWeapon();
		if (!isDefined(lastWeapon) || !self hasWeapon(lastWeapon))
			lastWeapon = self getWeaponsListPrimaries()[0];
		self switchToWeapon(lastWeapon);
	}
}

OnPlayerHealthUpdate()
{
	self endon("disconnect");
	self endon("death");

	for (;;)
	{
		self scripts\ttt\ui::updatePlayerHealthDisplay();
		wait(0.1);
	}
}

OnPlayerScoreboardOpen()
{
	self endon("disconnect");

	self notifyOnPlayerCommand("scoreboard_open", "+scores");

	for (;;)
	{
		self waittill("scoreboard_open");

		// Hide the scoreboard using a hack
		self setClientDvar("cg_scoreboardWidth", 10000);
		self setClientDvar("cg_scoreboardHeight", 0);

		//self scripts\ttt\ui::destroyHeadIcons();
		self thread scoreboardThink();
	}
}

OnPlayerScoreboardClose()
{
	self endon("disconnect");

	self notifyOnPlayerCommand("scoreboard_close", "-scores");

	for (;;)
	{
		self waittill("scoreboard_close");

		self scripts\ttt\ui::destroyScoreboard();
		//self scripts\ttt\ui::displayHeadIcons();

		// Restore default scoreborad settings
		self setClientDvar("cg_scoreboardWidth", 500);
		self setClientDvar("cg_scoreboardHeight", 435);

		// Try to destroy again a tick later (for whenever +scores and -scores are sent simultaneously)
		wait(0.05);
		self scripts\ttt\ui::destroyScoreboard();
	}
}

scoreboardThink()
{
	self endon("disconnect");
	self endon("scoreboard_close");

	for (;;)
	{
		self scripts\ttt\ui::destroyScoreboard();
		self scripts\ttt\ui::displayScoreboard();
		wait(0.25);
	}
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

		if (!self.ttt.inBuyMenu && eventName == "buymenu_close") continue;
		if (!isAlive(self) || !isDefined(self.ttt.role) || (self.ttt.role != "traitor" && self.ttt.role != "detective")) continue;

		if (self.ttt.inBuyMenu) self thread unsetPlayerBuyMenu(true);
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

	while (self getCurrentWeapon() != LAPTOP_WEAPON) wait(0.05); // wait for laptop to open
	while (!self isOnGround()) wait(0.05); // wait for player to land (if falling)

	self.ttt.inBuyMenu = true;

	self setBlurForPlayer(6, 1.5);
	self freezeControls(true);
	self scripts\ttt\ui::destroySelfHud();
	self scripts\ttt\ui::destroyBuyMenu();
	self scripts\ttt\ui::displayBuyMenu(self.ttt.role);
	self thread buyMenuThink();
	self thread buyMenuThinkLaptop(LAPTOP_WEAPON);
}

unsetPlayerBuyMenu(switchToLastWeapon)
{
	if (!isDefined(switchToLastWeapon)) switchToLastWeapon = false;

	self.ttt.inBuyMenu = false;

	self freezeControls(false);
	if (switchToLastWeapon) self switchToWeapon(self getLastWeapon());
	self setBlurForPlayer(0, 0.75);
	self scripts\ttt\ui::destroyBuyMenu();
	self scripts\ttt\ui::displaySelfHud();
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

checkRoundWinConditions()
{
	if (level.ttt.preparing) return;

	if (level.players.size <= 1 && getLivingPlayers().size == 1) return;
	aliveCounts = [];
	aliveCounts["innocent"] = 0;
	aliveCounts["detective"] = 0;
	aliveCounts["traitor"] = 0;
	foreach (player in getLivingPlayers()) aliveCounts[player.ttt.role]++;

	if ((aliveCounts["innocent"] + aliveCounts["detective"]) == 0) endRound("traitor", "death");
	if (aliveCounts["traitor"] == 0) endRound("innocent", "death");
}

drawPlayerRoles()
{
	traitorPct = getDvarFloat("ttt_traitor_pct");
	detectivePct = getDvarFloat("ttt_detective_pct");

	playerCount = level.aliveCount["allies"] + level.aliveCount["axis"];
	traitorCount = int(playerCount * traitorPct);
	detectiveCount = int(playerCount * detectivePct);
	if (traitorCount < 1) traitorCount = 1;
	else if (traitorCount > playerCount) traitorCount = playerCount;

	if (detectiveCount > playerCount) detectiveCount = playerCount;

	randomizedPlayers = array_randomize(getLivingPlayers());
	for (i = 0; i < randomizedPlayers.size; i++)
	{
		role = "innocent";
		if (i < traitorCount) role = "traitor";
		else if (i < traitorCount + detectiveCount) role = "detective";

		randomizedPlayers[i].ttt.role = role;
	}

	foreach (player in level.players)
	{
		if (traitorCount == 1) player iPrintLnBold("There is ^1" + traitorCount + "^7 traitor among us");
		else player iPrintLnBold("There are ^1" + traitorCount + "^7 traitors among us");
		player scripts\ttt\ui::updatePlayerRoleDisplay(true);
	}
}

endRound(winner, reason)
{
	if (level.gameEnded) return;
	level.gameEnded = true;

	scripts\ttt\ui::displayRoundEnd(winner, reason);

	visionSetNaked("mpOutro", 2.0);

	level thread maps\mp\gametypes\_damage::doFinalKillcam(
		5.0,
		level.lastDeath.victim,
		level.lastDeath.attacker,
		level.lastDeath.attackerNum,
		level.lastDeath.killcamentityindex,
		level.lastDeath.killcamentitystarttime,
		level.lastDeath.sWeapon,
		level.lastDeath.deathTimeOffset,
		level.lastDeath.psOffsetTime
	);

	thread OnAftertimeEnd();
}
