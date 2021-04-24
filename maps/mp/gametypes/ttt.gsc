#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	if (getDvar("mapname") == "mp_background")
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar(level.gameType, 0, 0, 1440);
	registerScoreLimitDvar(level.gameType, 0, 0, 0);
	registerWinLimitDvar(level.gameType, 1, 0, 5000);
	registerRoundLimitDvar(level.gameType, 0, 0, 10);
	registerNumLivesDvar(level.gameType, 0, 0, 10);
	registerHalfTimeDvar(level.gameType, 0, 0, 1);

	level.onStartGameType = ::onStartGameType;
	level.onDeadEvent = ::noop;
	level.onOneLeftEvent = ::noop;
	level.getSpawnPoint = ::getSpawnPoint;

	game["dialog"]["gametype"] = "ttt";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level.gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
}

noop()
{
	return;
}


onStartGameType()
{
	setClientNameMode("auto_change");

	text = "^2Innocent^7 (^4Detectives^7): Try to stay alive and figure out who the traitors are.\n^1Traitors^7: Kill all innocent players without being detected.";
	setObjectiveText("allies", text);
	setObjectiveText("axis", text);
	setObjectiveScoreText("allies", text);
	setObjectiveScoreText("axis", text);
	text = "Trouble in Terrorist Town";
	setObjectiveHintText("allies", text);
	setObjectiveHintText("axis", text);

	level.spawnMins = (0, 0, 0);
	level.spawnMaxs = (0, 0, 0);
	maps\mp\gametypes\_spawnlogic::addSpawnPoints("allies", "mp_dm_spawn");
	maps\mp\gametypes\_spawnlogic::addSpawnPoints("axis", "mp_dm_spawn");
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter(level.spawnMins, level.spawnMaxs);
	setMapCenter(level.mapCenter);

	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank::registerScoreInfo("kill", 0);
	maps\mp\gametypes\_rank::registerScoreInfo("headshot", 0);
	maps\mp\gametypes\_rank::registerScoreInfo("assist", 0);
	maps\mp\gametypes\_rank::registerScoreInfo("suicide", 0);
	maps\mp\gametypes\_rank::registerScoreInfo("teamkill", 0);

	level.QuickMessageToAll = true;
}


getSpawnPoint()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	return spawnPoint;
}
