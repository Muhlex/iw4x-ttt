#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	level.ttt = spawnStruct();
	scripts\ttt\dvars::init();

	level.ttt.enabled = getDvar("g_gametype") == "ttt";
	if (!level.ttt.enabled) return;

	level.ttt.modEnabled = isSubStr(getDvar("fs_game"), "ttt");
	level.ttt.maxhealth = getDvarInt("scr_player_maxhealth");
	level.ttt.headshotMultiplier = getDvarFloat("ttt_headshot_multiplier");
	level.ttt.headshotMultiplierSniper = getDvarFloat("ttt_headshot_multiplier_sniper");
	level.ttt.knifeDamage = getDvarInt("ttt_knife_damage");
	level.ttt.knifeWeaponBackstabAngle = getDvarFloat("ttt_knife_weapon_backstab_angle");
	level.ttt.armorDamageMultiplier = getDvarFloat("ttt_armor_damage_multiplier");
	level.ttt.speedItemMultiplier = getDvarFloat("ttt_speed_item_mutiplier");
	level.ttt.rpgMultiplier = getDvarFloat("ttt_rpg_multiplier");
	level.ttt.claymoreMultiplier = getDvarFloat("ttt_claymore_multiplier");
	level.ttt.claymoreDelay = getDvarFloat("ttt_claymore_delay");
	level.ttt.feignDeathInvisTime = getDvarFloat("ttt_feign_death_invis_time");
	level.ttt.preptime = max(getDvarInt("ttt_preptime"), 1);

	level.ttt.knifeWeapon = "beretta_tactical_mp";
	if (level.ttt.modEnabled)
	{
		precacheMenu("client_exec");
		precacheItem("combat_knife_mp");
		level.ttt.knifeWeapon = "combat_knife_mp";
	}

	level.ttt.prematch = true;
	level.ttt.preparing = true;

	level.ttt.effects = spawnStruct();

	level.inGracePeriod = false;

	makeDvarServerInfo("cg_overheadIconSize", 0);
	makeDvarServerInfo("cg_overheadRankSize", 0);
	makeDvarServerInfo("cg_overheadNamesSize", 0.75);

	makeDvarServerInfo("ui_allow_classchange", false);
	makeDvarServerInfo("ui_allow_teamchange", false);

	setDvar("scr_player_forceautoassign", true);
	setDvar("scr_player_forcerespawn", true);
	setDvar("scr_game_hardpoints", false);
	setDvar("scr_teambalance", false);
	setDvar("scr_game_spectatetype", 2);
	setDvar("scr_showperksonspawn", false);

	setDvar("bg_fallDamageMinHeight", getDvar("ttt_falldamage_min"));
	setDvar("bg_fallDamageMaxHeight", getDvar("ttt_falldamage_max"));
	setDvar("player_dmgtimer_flinchTime", 80); // reduce flinching for more consistent headshots

	setDvar("scr_ttt_timelimit", (getDvarFloat("ttt_timelimit") + level.ttt.preptime / 60));

	scripts\ttt\_weaponnames::init();
	scripts\ttt\_coords::init();
	scripts\ttt\use::init();
	scripts\ttt\items::init();
	scripts\ttt\pickups::init();
	scripts\ttt\ui::init();

	thread OnPrematchOver();
	thread OnRoundRestart();

	thread OnPlayerConnect();

	wait(0.05); // wait for other scripts to execute
	setDvar("g_deadChat", "0");
}

initPlayer()
{
	self.ttt = spawnStruct();
	self.ttt.role = undefined;
	self.ttt.bodyFound = false;
	self.ttt.damageMultipliers = [];
	self.ttt.attackerHitFeedback = true;

	self scripts\ttt\use::initPlayer();
	self scripts\ttt\pickups::initPlayer();
	self scripts\ttt\items::initPlayer();
	self scripts\ttt\ui::initPlayer();

	wait(0.05);
	self setClientDvars(
		"cg_deadChatWithDead", true,
		"cg_deadChatWithTeam", false,
		"cg_deadHearTeamLiving", true,
		"cg_deadHearAllLiving", true,
		"cg_everyoneHearsEveryone", false,
		"cg_teamChatsOnly", false
	);

	self setClientDvar("ui_ttt_block_esc_menu", false);
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
	level waittill("ttt_restarting");

	thread OnRoundStart();
}

OnRoundStart()
{
	thread scripts\ttt\pickups::spawnWorldPickups();
	setGameEndTime(int(getTime() + level.ttt.preptime * 1000));

	thread OnPreptimeEnd();
	thread OnTimelimitReached();
	thread OnChatMessage();
}

OnPreptimeEnd()
{
	level endon("game_ended");

	wait(level.ttt.preptime - 0.2);
	foreach (player in getLivingPlayers()) player thread scripts\ttt\ui::pulsePlayerRoleDisplay(0.4);
	wait(0.2);
	level.ttt.preparing = false;

	drawPlayerRoles();

	foreach (player in getLivingPlayers())
	{
		player.maxhealth = level.ttt.maxhealth;
		player.health = player.maxhealth;

		player.isRadarBlocked = true;

		player scripts\ttt\items::setStartingCredits();
		player scripts\ttt\items::setStartingItems();

		player scripts\ttt\ui::displayPlayerHeadIcons();
	}

	level.disableSpawning = true;
	//visionSetNaked(getDvar("mapname"), 2.0);

	if (!isDefined(game["ttt_rounds_data"])) game["ttt_rounds_data"] = [];
	game["ttt_rounds_data"][game["roundsPlayed"]] = spawnStruct();
	roundData = game["ttt_rounds_data"][game["roundsPlayed"]];
	roundData.ended = false;
	roundData.players = [];
	foreach (i, player in getLivingPlayers())
	{
		roundData.players[i] = [];
		roundData.players[i]["guid"] = player.guid;
		roundData.players[i]["name"] = player.name;
		roundData.players[i]["role"] = player.ttt.role;
	}

	checkRoundWinConditions();

	thread chatDisableThink();

	level notify("ttt_preptime_end");
}

OnTimelimitReached()
{
	level endon("game_ended");

	level waittill("ttt_timelimit_reached");
	endRound("innocent", "timelimit");
}

OnAftertimeEnd()
{
	wait(getDvarInt("ttt_aftertime"));

	scripts\ttt\ui::destroyRoundEnd();

	foreach (player in level.players)
	{
		player.cancelKillcam = true;
		player scripts\ttt\use::unsetPlayerAvailableUseEnt();
	}
	level notify("round_end_finished"); // kicks off the final killcam
	while (level.showingFinalKillcam) wait(0.05);

	game["roundsPlayed"]++;
	if (game["roundsPlayed"] >= getDvarInt("ttt_roundlimit"))
	{
		thread endGame();
		return;
	}

	game["state"] = "playing";
	map_restart(true);
	level notify("ttt_restarting");
}

OnChatMessage()
{
	level endon("game_ended");

	for (;;)
	{
		level waittill("say", text, player);
		if (player.ttt.role != "traitor") continue;

		PAD_LEFT = "                                                                      ";
		CHARS_PER_LINE = 48;
		playerName = removeColorsFromString(player.name);
		charsFirstLine = CHARS_PER_LINE - playerName.size - 2;
		lines = [];

		lines[0] = PAD_LEFT + "^1" + playerName + "^7: " + getSubStr(text, 0, charsFirstLine);

		if (text.size > charsFirstLine)
			for (i = charsFirstLine; i < text.size; i += CHARS_PER_LINE)
				lines[lines.size] = PAD_LEFT + getSubStr(text, i, i + CHARS_PER_LINE);

		foreach (recipient in getLivingPlayers())
		{
			if (isDefined(recipient.ttt.role) && recipient.ttt.role != "traitor")
				continue;

			foreach (line in lines) recipient iPrintLn(line);
			recipient thread playChatMessageSound();
		}
	}
}

playChatMessageSound()
{
	for(i = 0; i < 3; i++)
	{
		wait(0.05 * i);
		self playLocalSound("ui_text_type");
		self playLocalSound("ui_text_type");
	}
}

OnPlayerConnect()
{
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
		player thread OnPlayerWeaponSwitchStart();
		player thread OnPlayerGrenadeFire();
		player thread OnPlayerScoreboardOpen();
		player thread OnPlayerScoreboardClose();
	}
}

OnPlayerDisconnect()
{
	self waittill("disconnect");

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

		self detach(self.headModel, "");
		self [[game[self.team + "_model"]["SMG"]]]();

		self scripts\ttt\pickups::giveKnifeWeapon();
		self setSpawnWeapon(level.ttt.knifeWeapon);
		self scripts\ttt\ui::setupHeadIconAnchor();
		self scripts\ttt\ui::displaySelfHud();

		self thread scripts\ttt\use::OnPlayerUse();
		self thread scripts\ttt\use::playerUseEntsThink();
		self thread scripts\ttt\pickups::OnPlayerDropWeapon();
		self thread scripts\ttt\items::OnPlayerRoleWeaponToggle();
		self thread scripts\ttt\items::OnPlayerRoleWeaponEquip();
		self thread scripts\ttt\items::OnPlayerRoleWeaponActivate();
		self thread scripts\ttt\items::OnPlayerCustomOffhandUse();
		self thread scripts\ttt\items::OnPlayerBuyMenu();
		self thread OnPlayerHealthUpdate();
		self thread OnPlayerAttack();
	}
}

OnPlayerDeath()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("death");

		self scripts\ttt\use::unsetPlayerAvailableUseEnt();
		self scripts\ttt\ui::destroySelfHud();
		self scripts\ttt\items\bomb::displayBombHud();
		self scripts\ttt\items::unsetPlayerBuyMenu();
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

		bodyEnt = spawn("script_model", self.body.origin);
		bodyEnt linkTo(self.body, "tag_origin", (0, 0, 16), (0, 0, 0));
		bodyEnt scripts\ttt\use::makeUsableCustom(
			::OnBodyInspectTrigger,
			::OnBodyInspectAvailable,
			::OnBodyInspectAvailableEnd,
			undefined,
			undefined,
			10
		);

		bodyEnt.owner = self;
		bodyEnt.found = false;
		bodyEnt.credits = self.ttt.items.credits;
		bodyEnt.ownerData = []; // copy any needed data for if the dead player disconnects
		bodyEnt.ownerData["name"] = self.name;
		bodyEnt.ownerData["role"] = self.ttt.role;
	}
}

OnBodyInspectTrigger(bodyEnt)
{
	self scripts\ttt\items::awardBodyInspectCredits(bodyEnt);

	playerName = removeColorsFromString(self.name);
	ownerName = removeColorsFromString(bodyEnt.ownerData["name"]);
	ownerRoleColor = getRoleStringColor(bodyEnt.ownerData["role"]);

	if (!bodyEnt.found)
	{
		bodyEnt.owner.ttt.bodyFound = true;
		bodyEnt.found = true;
		bodyEnt.usePriority = 0;
		foreach (p in level.players)
		{
			if (p == self)
				p iPrintLnBold("You found the body of ^3" + ownerName + "^7. They were " + ownerRoleColor + bodyEnt.ownerData["role"] + "^7.");
			else
				p iPrintLnBold(playerName + "^7 found the body of ^3" + ownerName + "^7. They were " + ownerRoleColor + bodyEnt.ownerData["role"] + "^7.");

			p playLocalSound("copycat_steal_class");
		}
		foreach (p in scripts\ttt\use::getUseEntAvailablePlayers(bodyEnt))
			p scripts\ttt\ui::updateUseAvailableHint(undefined, ownerRoleColor + ownerName + "^7\n[ ^3[{+activate}]^7 ] to inspect");
	}
	else self iPrintLnBold("This is the body of ^3" + ownerName + "^7. They were " + ownerRoleColor + bodyEnt.ownerData["role"] + "^7.");
}
OnBodyInspectAvailable(bodyEnt)
{
	self scripts\ttt\ui::destroyUseAvailableHint();

	if (bodyEnt.found)
	{
		ownerName = removeColorsFromString(bodyEnt.ownerData["name"]);
		ownerRoleColor = getRoleStringColor(bodyEnt.ownerData["role"]);
		self scripts\ttt\ui::displayUseAvailableHint(undefined, ownerRoleColor + ownerName + "^7\n[ ^3[{+activate}]^7 ] to inspect");
	}
	else
		self scripts\ttt\ui::displayUseAvailableHint(undefined, "^3Unidentified body^7\n[ ^3[{+activate}]^7 ] to inspect");
}
OnBodyInspectAvailableEnd()
{
	self scripts\ttt\ui::destroyUseAvailableHint();
}

OnPlayerWeaponSwitchStart()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("weapon_switch_started", weaponName);

		self thread OnPlayerWeaponSwitchCancel(weaponName);
	}
}

OnPlayerWeaponSwitchCancel(weaponName)
{
	self endon("disconnect");
	self endon("weapon_change");

	for (;;)
	{
		while (self isSwitchingWeapon() || self getCurrentWeapon() == "none") wait(0.05);

		self notify("ttt_weapon_switch_canceled", weaponName);
		break;
	}
}

OnPlayerGrenadeFire()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("grenade_fire", entity, weaponName);

		// Remove offhand grenades after throwing, to prevent "none remaining" popup.
		OFFHAND_ITEMS = [];
		OFFHAND_ITEMS[0] = "smoke_grenade_mp";
		OFFHAND_ITEMS[1] = "flash_grenade_mp";
		OFFHAND_ITEMS[2] = "concussion_grenade_mp";

		if (isInArray(OFFHAND_ITEMS, weaponName) && self hasWeapon(weaponName))
			self takeWeapon(weaponName);
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

OnPlayerAttack()
{
	self endon("disconnect");
	self endon("death");

	self notifyOnPlayerCommand("ttt_attack", "+attack");

	for (;;)
	{
		self waittill("ttt_attack");
		if (self getCurrentWeapon() == level.ttt.knifeWeapon) self clientExec("+melee; -melee");
	}
}

OnPlayerScoreboardOpen()
{
	self endon("disconnect");

	self notifyOnPlayerCommand("ttt_scoreboard_open", "+scores");

	for (;;)
	{
		self waittill("ttt_scoreboard_open");

		// Hide the scoreboard using a hack
		self setClientDvar("cg_scoreboardWidth", 10000);
		self setClientDvar("cg_scoreboardHeight", 0);

		//self scripts\ttt\ui::destroyPlayerHeadIcons();
		self thread scoreboardThink();
	}
}

OnPlayerScoreboardClose()
{
	self endon("disconnect");

	self notifyOnPlayerCommand("ttt_scoreboard_close", "-scores");

	for (;;)
	{
		self waittill("ttt_scoreboard_close");

		self scripts\ttt\ui::destroyScoreboard();
		//self scripts\ttt\ui::displayPlayerHeadIcons();

		// Restore default scoreboard settings
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
	self endon("ttt_scoreboard_close");

	for (;;)
	{
		self scripts\ttt\ui::destroyScoreboard();
		self scripts\ttt\ui::displayScoreboard();
		wait(0.25);
	}
}

chatDisableThink()
{
	level endon("game_ended");

	for (;;)
	{
		foreach (player in level.players) player setClientDvar("cg_teamChatsOnly", true);
		waitframe();
	}
}

checkRoundWinConditions()
{
	if (level.ttt.preparing) return;

	if (level.players.size == 0 || (level.players.size == 1 && getLivingPlayers().size == 1)) return;
	aliveCounts = [];
	aliveCounts["innocent"] = 0;
	aliveCounts["detective"] = 0;
	aliveCounts["traitor"] = 0;
	foreach (player in getLivingPlayers()) aliveCounts[player.ttt.role]++;

	if ((aliveCounts["innocent"] + aliveCounts["detective"]) == 0) endRound("traitor", "death");
	else if (aliveCounts["traitor"] == 0) endRound("innocent", "death");
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

	// The array_randomize function in common utils is biased.
	randomizedPlayers = fisherYatesShuffle(getLivingPlayers());

	for (i = 0; i < randomizedPlayers.size; i++)
	{
		role = "innocent";
		if (i < traitorCount) role = "traitor";
		else if (i < traitorCount + detectiveCount) role = "detective";

		randomizedPlayers[i].ttt.role = role;
	}

	foreach (player in getLivingPlayers())
	{
		if (traitorCount == 1) player iPrintLnBold("There is ^1" + traitorCount + "^7 traitor among us");
		else player iPrintLnBold("There are ^1" + traitorCount + "^7 traitors among us");
		player scripts\ttt\ui::updatePlayerRoleDisplay();

		if (player.ttt.role == "detective")
		{
			player detach(player.headModel, "");
			player [[game[player.team + "_model"]["RIOT"]]]();
		}
	}

	logPrint("TTT_ROUND_START;" + getSystemTime() + "\n");

	playersString = "TTT_PLAYERS";
	foreach (player in getLivingPlayers())
		playersString += ";" + player.guid + "<" + player.ttt.role + ">";
	logPrint(playersString + "\n");

	dvarsString = "TTT_DVARS";
	foreach (dvar, value in level.ttt.dvars)
		dvarsString += ";" + dvar + "<" + value + ">";
	logPrint(dvarsString + "\n");

	logPrint("TTT_MAP;" + getDvar("mapname") + "\n");
}

endRound(winner, reason)
{
	if (level.gameEnded) return;

	level.gameEnded = true;
	level.gameEndTime = getTime();
	level.inGracePeriod = false;
	game["state"] = "postgame";

	setDvar("g_deadChat", "1");
	if (reason == "death") setDvar("scr_gameended", 2); // primarily sets "Round Winning Kill" in killcam

	scripts\ttt\ui::displayRoundEnd(winner, reason);
	foreach (player in level.players)
	{
		playerTeam = "innocent";
		if (isDefined(player.ttt.role) && player.ttt.role == "traitor") playerTeam = "traitor";
		if (winner == playerTeam) player playLocalSound("mp_bonus_start");
		else player playLocalSound("mp_bonus_end");

		player setClientDvar("cg_teamChatsOnly", false);
		player scripts\ttt\ui::destroyPlayerCustomOffhandDisplay();
		player scripts\ttt\ui::destroyPlayerPassivesDisplay();
	}

	visionSetNaked("mpOutro", 2.0);
	logPrint("TTT_ROUND_END;" + winner + ";" + reason + ";" + (getSecondsPassed() - level.ttt.preptime) + "\n");

	roundData = game["ttt_rounds_data"][game["roundsPlayed"]];

	roundData.ended = true;
	roundData.winner = winner;
	roundData.endReason = reason;

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

	level notify("game_ended");
}

endGame()
{
	WAIT_TIME = getDvarFloat("ttt_summary_timelimit");

	setDvar("scr_gameended", 1);
	levelFlagSet("game_over");
	levelFlagSet("block_notifies");

	visionSetNaked("mpOutro", 0.0);

	waitframe(); // give "game_ended" notifies time to process

	levelFlagClear("block_notifies");

	level.intermission = true;
	level notify("spawning_intermission");

	foreach (player in level.players)
	{
		player maps\mp\gametypes\_gamelogic::freeGameplayHudElems();
		player scripts\ttt\ui::destroySelfHud();

		player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
		// sessionstate must be something other than "intermission" to allow displaying HUD elements
		player.sessionstate = "playing";
		// Replicate the behavior of "intermission" state:
		player freezePlayer();
		player freezeControls(true);
		player playerHide();
	}

	thread scripts\ttt\ui::displayGameEnd(game["ttt_rounds_data"]);

	setGameEndTime(getTime() + int(WAIT_TIME * 1000));
	wait(WAIT_TIME);


	scripts\ttt\ui::destroyGameEnd();
	level notify("exitLevel_called");
	exitLevel(false);
}
