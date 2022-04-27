#include maps\mp\_utility;

main()
{
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_aim_koala");

	game["attackers"] = "axis";
	game["defenders"] = "allies";

	// we want some custom rules for the arena mode, so we wrap/override the arena callbacks
	if (getDvar("g_gametype") == "arena")
	{
		level.onStartGameType = ::OnStartGameTypeArena;
		level.onDeadEvent = ::OnDeadEventArena;
		level.onOneLeftEvent = ::noop;
		level.getSpawnPoint = ::getSpawnPointArena;
		level thread OnPlayerConnectArena();
	}

	initPushTriggers();
}

noop(){}

OnStartGameTypeArena()
{
	flagDelayDvar = getDvar("mapname") + "_arena_flag_delay";
	flagCaptureTimeDvar = getDvar("mapname") + "_arena_flag_capture_time";
	setDvarIfUninitialized(flagDelayDvar, 20.0);
	setDvarIfUninitialized(flagCaptureTimeDvar, 8.0);
	flagDelay = getDvarFloat(flagDelayDvar);
	flagCaptureTime = getDvarFloat(flagCaptureTimeDvar);

	level.inGracePeriod = false;
	level.roundEndDelay = 2.5;
	level.halftimeRoundEndDelay = 2.5;
	// level.postRoundTime = 5.0;

	setClientNameMode("auto_change");

	if (!isdefined( game["switchedsides"]))
		game["switchedsides"] = false;

	if (game["switchedsides"])
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setObjectiveText("allies", &"OBJECTIVES_ARENA");
	setObjectiveText("axis", &"OBJECTIVES_ARENA");

	if (level.splitscreen)
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_ARENA");
		setObjectiveScoreText( "axis", &"OBJECTIVES_ARENA");
	}
	else
	{
		setObjectiveScoreText("allies", &"OBJECTIVES_ARENA_SCORE");
		setObjectiveScoreText("axis", &"OBJECTIVES_ARENA_SCORE");
	}
	setObjectiveHintText("allies", &"OBJECTIVES_ARENA_HINT");
	setObjectiveHintText("axis", &"OBJECTIVES_ARENA_HINT");

	level.spawnMins = (0, 0, 0);
	level.spawnMaxs = (0, 0, 0);
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_tdm_spawn_allies_start");
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints("mp_tdm_spawn_axis_start");
	maps\mp\gametypes\_spawnlogic::addSpawnPoints("allies", "mp_tdm_spawn");
	maps\mp\gametypes\_spawnlogic::addSpawnPoints("axis", "mp_tdm_spawn");

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter(level.spawnMins, level.spawnMaxs);
	setMapCenter(level.mapCenter);

	allowed[0] = "dom";
	allowed[1] = "airdrop_pallet";
	allowed[2] = "arena";
	maps\mp\gametypes\_rank::registerScoreInfo("capture", 200);

	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\arena::precacheFlag();
	thread suppressLeaderDialogThink();
	thread spawnArenaFlagDelayed(flagDelay, flagCaptureTime);
}

suppressLeaderDialogThink()
{
	level endon("game_ended");

	for (;;)
	{
		level.lastStatusTime = getTime();
		wait 2.0;
	}
}

spawnArenaFlagDelayed(flagDelay, flagCaptureTime)
{
	level endon("game_ended");

	level waittill("prematch_over");

	wait flagDelay;

	maps\mp\gametypes\arena::arenaFlag();
	level.arenaFlag maps\mp\gametypes\_gameobjects::setUseTime(flagCaptureTime);
	// also a small fix because arena.gsc uses nonexisting images here
	level.arenaFlag maps\mp\gametypes\_gameobjects::set2DIcon("friendly", "waypoint_defend");
	level.arenaFlag maps\mp\gametypes\_gameobjects::set2DIcon("enemy", "waypoint_captureneutral");
	level.arenaFlag.onUse = ::OnArenaFlagUse;
}

OnArenaFlagUse(player)
{
	self maps\mp\gametypes\arena::onUse(player);
	// fix it here too
	self maps\mp\gametypes\_gameobjects::set2DIcon("enemy", "waypoint_capture");
}

OnDeadEventArena(team)
{
	if (team == "allies")
		thread endGameCustom("axis", game["strings"]["allies_eliminated"]);
	else if (team == "axis")
		thread endGameCustom("allies", game["strings"]["axis_eliminated"]);
}

getSpawnPointArena()
{
	// reset the actual hasSpawned value because other spawnPlayer() logic needs it
	if (self.hasSpawned && !self.hasActuallySpawned)
	{
		self.hasSpawned = false;
		self.hasActuallySpawned = true;
	}

	// fake set grace period to force start spawns
	level.inGracePeriod = 1;
	spawnPoint = self maps\mp\gametypes\arena::getSpawnPoint();
	level.inGracePeriod = false;

	return spawnPoint;
}

OnPlayerConnectArena()
{
	for (;;)
	{
		level waittill("connected", player);

		// need to hackily set this here to allow spawns even though there's no unlimited lives and grace period is over
		player.hasActuallySpawned = player.hasSpawned;
		player.hasSpawned = true;
	}
}

initPushTriggers()
{
	setDvarIfUninitialized("scr_trigger_push_multiplier_x", 1.0);
	setDvarIfUninitialized("scr_trigger_push_multiplier_y", 1.0);
	setDvarIfUninitialized("scr_trigger_push_multiplier_z", 1.0);
	setDvarIfUninitialized("scr_trigger_push_multiplier_side_boost", 0.02);

	multiplier = (
		getDvarFloat("scr_trigger_push_multiplier_x"),
		getDvarFloat("scr_trigger_push_multiplier_y"),
		getDvarFloat("scr_trigger_push_multiplier_z")
	);
	sideBoostMultiplier = getDvarFloat("scr_trigger_push_multiplier_side_boost");

	foreach (trigger in getEntArray("trigger_push", "targetname"))
		trigger thread OnPushTrigger(multiplier, sideBoostMultiplier);
}

OnPushTrigger(multiplier, sideBoostMultiplier)
{
	for (;;)
	{
		self waittill("trigger", player);

		// script_angles is actually the velocity to be applied
		dir = vectorToAngles(self.script_angles);
		rightVec = anglesToRight(dir);
		sideVec = (abs(rightVec[0]), abs(rightVec[1]), abs(rightVec[2]));
		playerVelocity = player getVelocity();
		addVelocityTrigger = self.script_angles * multiplier;
		addVelocitySideBoost = playerVelocity * sideVec * sideBoostMultiplier;
		player setVelocity(playerVelocity + addVelocityTrigger + addVelocitySideBoost);
	}
}

endGameCustom(winner, endReasonText)
{
	game["state"] = "postgame";

	level.gameEndTime = getTime();
	level.gameEnded = true;

	level notify("game_ended", winner);
	levelFlagSet("game_over");
	levelFlagSet("block_notifies");

	wait 0.05; // give "game_ended" notifies time to process
	setGameEndTime(0); // stop/hide the timers

	game["roundsPlayed"]++;
	if (winner == "axis" || winner == "allies")
		game["roundsWon"][winner]++;

	maps\mp\gametypes\_gamescore::updateTeamScore("axis");
	maps\mp\gametypes\_gamescore::updateTeamScore("allies");
	maps\mp\gametypes\_gamescore::updatePlacement();
	maps\mp\gametypes\_gamelogic::rankedMatchUpdates(winner);
	setDvar("g_deadChat", 1);

	foreach (player in level.players)
	{
		player thread maps\mp\gametypes\_gamelogic::roundEndDoF(1.5);
		player maps\mp\gametypes\_gamelogic::freeGameplayHudElems();
		player setClientDvars("cg_everyoneHearsEveryone", 1);
		player setClientDvars("cg_drawSpectatorMessages", 0, "g_compassShowEnemies", 0);

		if (player.pers["team"] == "spectator")
			player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

	visionSetNaked("mpOutro", 1.0);

	// I wanted some slow-mo...
	// Since the iw4x engine version doesn't support easing into/from slow-mo, we emulate it:

	// Somehow this breaks everything, so disable it for now...
	// for (i = 1.0; i > 0.4; i -= 0.05)
	// {
	// 	setSlowMotion(i, i - 0.05, 0.05);
	// 	wait 0.1;
	// }
	setSlowMotion(1.0, 0.4, 0.45);
	wait 0.5;
	setSlowMotion(0.4, 1.0, 0.05);

	if (!wasOnlyRound())
	{
		setDvar("scr_gameended", 2);

		level notify("round_end_finished");

		if (level.showingFinalKillcam)
		{
			foreach (player in level.players)
				player notify("reset_outcome");

			level notify("game_cleanup");

			maps\mp\gametypes\_gamelogic::waittillFinalKillcamDone();
		}

		if (!wasLastRound())
		{
			levelFlagClear("block_notifies");
			if (maps\mp\gametypes\_gamelogic::checkRoundSwitch())
				maps\mp\gametypes\_gamelogic::displayRoundSwitch();

			foreach (player in level.players)
				player.pers["stats"] = player.stats;

			level notify("restarting");
			game["state"] = "playing";
			map_restart(true);
			return;
		}

		if (!level.forcedEnd)
			endReasonText = maps\mp\gametypes\_gamelogic::updateEndReasonText(winner);
	}

	setDvar("scr_gameended", 1);
	if (!isDefined( game["clientMatchDataDef"]))
	{
		game["clientMatchDataDef"] = "mp/clientmatchdata.def";
		setClientMatchDataDef(game["clientMatchDataDef"]);
	}

	maps\mp\gametypes\_missions::roundEnd(winner);

	maps\mp\gametypes\_gamelogic::displayGameEnd(winner, endReasonText);

	if (level.showingFinalKillcam && wasOnlyRound())
	{
		foreach (player in level.players)
			player notify("reset_outcome");

		level notify("game_cleanup");

		maps\mp\gametypes\_gamelogic::waittillFinalKillcamDone();
	}

	levelFlagClear( "block_notifies" );

	level.intermission = true;

	level notify ("spawning_intermission");

	foreach (player in level.players)
	{
		player closepopupMenu();
		player closeInGameMenu();
		player notify("reset_outcome");
		player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

	maps\mp\gametypes\_gamelogic::processLobbyData();

	wait 1.0;

	if (matchMakingGame())
		sendMatchData();

	foreach (player in level.players)
		player.pers["stats"] = player.stats;

	if (!level.postGameNotifies)
	{
		if (!wasOnlyRound())
			wait 6.0;
		else
			wait 3.0;
	}
	else
	{
		wait min(10.0, 4.0 + level.postGameNotifies);
	}
	if (!matchmakingGame())
	{
		intermissionTime = level.intermissionTime;

		if (getDvarInt("party_host"))
			intermissionTime = 10.0;

		thread maps\mp\gametypes\_gamelogic::timeLimitClock_Intermission(intermissionTime);
		wait intermissionTime;
	}

	level notify("exitLevel_called");
	exitLevel(false);
}
