#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\ui_util;

init()
{
	level.ttt = spawnStruct();
	level.ttt.enabled = !!getDvarInt("ttt");
	if (!level.ttt.enabled) return;

	level.ttt.maxhealth = getDvarInt("scr_player_maxhealth");
	level.ttt.headshotMultiplier = getDvarFloat("ttt_headshot_multiplier");
	level.ttt.headshotMultiplierSniper = getDvarFloat("ttt_headshot_multiplier_sniper");

	level.ttt.prematch = true;
	level.ttt.preparing = true;

	level.inGracePeriod = false;

	setDvar("scr_player_forceautoassign", "1");
	setDvar("scr_player_forcerespawn", "1");
	setDvar("scr_game_hardpoints", "0");
	setDvar("scr_teambalance", "0");
	setDvar("scr_game_spectatetype", "2");

	setDvar("scr_dm_scorelimit", "0");
	setDvar("scr_dm_timelimit", (getDvarFloat("ttt_roundtime") + getDvarInt("ttt_preptime") / 60));
	setDvar("scr_dm_numlives", "0");
	setDvar("scr_dm_winlimit", "0");

	setDvar("g_deadChat", "0");

	if (getDvar("g_gametype") != "dm")
	{
		setDvar("g_gametype", "dm");
		map_restart();
	}

	scripts\ttt\pickups::init();
	scripts\ttt\ui::init();

	thread OnPrematchOver();
	thread OnRoundRestart();

	thread OnPlayerConnect();
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

	wait(int(getDvarInt("ttt_preptime")));
	level.ttt.preparing = false;

	foreach(player in getLivingPlayers())
	{
		player.maxhealth = level.ttt.maxhealth;
		player.health = player.maxhealth;

		player.isRadarBlocked = true;
	}

	drawPlayerRoles();
	scripts\ttt\ui::setHeadIcons();
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

	foreach (player in level.players) player.cancelKillcam = true;

	level notify("round_end_finished"); // kicks off the final killcam

	while (level.showingFinalKillcam) wait(0.05);

	level.gameEnded = false;

	scripts\ttt\ui::destroyRoundEnd();

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

	for(;;)
	{
		level waittill("connected", player);

		player thread initPlayer();

		player thread OnPlayerDisconnect();
		player thread OnPlayerSpawn();
		player thread OnPlayerDeath();
		player thread OnPlayerEnemyKilled();
		player thread OnPlayerRagdoll();
		player thread OnPlayerScoreboard();
	}
}

initPlayer()
{
	self setClientDvars(
		"g_deadChat", 0,
		"cg_deadChatWithDead", 1,
		"cg_deadChatWithTeam", 0,
		"cg_deadHearTeamLiving", 1,
		"cg_deadHearAllLiving", 1,
		"cg_everyoneHearsEveryone", 0
	);

	self.ttt = spawnStruct();
	self.ttt.role = undefined;
	self.ttt.bodyFound = false;

	self scripts\ttt\ui::initPlayer();
}

OnPlayerDisconnect()
{
	self waittill ("disconnect");

	checkRoundWinConditions();
}

OnPlayerSpawn()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		self takeAllWeapons();
		self _clearPerks();

		spawnWeapon = "usp_tactical_mp";

		self giveWeapon(spawnWeapon);
		self SetWeaponAmmoClip(spawnWeapon, 0);
		self SetWeaponAmmoStock(spawnWeapon, 0);
		self setSpawnWeapon(spawnWeapon);

		if (level.ttt.preparing)
		{
			//if (!level.ttt.prematch) self visionSetNakedForPlayer("sepia", 0);
			self scripts\ttt\ui::updatePlayerRoleDisplay();
		}
	}
}

OnPlayerDeath()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("death");

		checkRoundWinConditions();
	}
}

OnPlayerEnemyKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_enemy");

		// award Traitor point if traitor here
	}
}

OnPlayerRagdoll()
{
	self endon("disconnect");

	for(;;)
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

OnPlayerScoreboard()
{
	self endon("disconnect");

	self notifyOnPlayerCommand("scoreboard_open", "+scores");
	self notifyOnPlayerCommand("scoreboard_close", "-scores");

	for (;;)
	{
		self waittill("scoreboard_open");
		self setClientDvar("cg_scoreboardWidth", 10000);
		self setClientDvar("cg_scoreboardHeight", 0);
		self thread scoreboardThink();

		self waittill("scoreboard_close");
		self scripts\ttt\ui::destroyScoreboard();
		self setClientDvar("cg_scoreboardWidth", 500);
		self setClientDvar("cg_scoreboardHeight", 435);
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

checkRoundWinConditions()
{
	if (level.ttt.preparing) return;

	if (level.players.size <= 1) return; // DEBUG
	aliveCounts = [];
	aliveCounts["innocent"] = 0;
	aliveCounts["detective"] = 0;
	aliveCounts["traitor"] = 0;
	foreach (player in getLivingPlayers()) aliveCounts[player.ttt.role]++;

	// TEMP --START-- (delete this)
	if (aliveCounts["traitor"] == 1)
	{
		foreach (player in getLivingPlayers()) if (player.ttt.role == "traitor")
		{
			player.isRadarBlocked = false;
			player.hasRadar = true;
		}
	}
	// TEMP --END--

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
		if (isDefined(player.ttt.role)) player scripts\ttt\ui::updatePlayerRoleDisplay(player.ttt.role);
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
