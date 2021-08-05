#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\ttt\_util;

init()
{
	precacheShader("cardicon_vest_1");
	precacheShader("hud_suitcase_bomb");

	precacheShader("cardicon_comic_shepherd");
	precacheShader("cardtitle_silencer");

	precacheShader("nightvision_overlay_goggles");
	precacheShader("compassping_enemy");

	level.ttt.ui = [];
	level.ttt.ui["hud"] = [];

	level.ttt.colors["preparing"] = (0.5, 0.5, 0.5);
	level.ttt.colors["innocent"] = (0.4, 0.75, 0); // exact ^2 color code is (0.52, 0.75, 0)
	level.ttt.colors["detective"] = (0.0, 0.52, 0.64);
	level.ttt.colors["traitor"] = (1.0, 0.19, 0.19);
	level.ttt.colorsScoreboard["innocent"] = (1.0, 1.0, 1.0);
	level.ttt.colorsScoreboard["detective"] = (0.45, 0.8, 1.0);
	level.ttt.colorsScoreboard["traitor"] = (1.0, 0.45, 0.45);
	level.ttt.colorsScoreboard["self"] = (0.5, 0.5, 0.5);
	level.ttt.colorsBuyMenu["item_bg"] = (0.35, 0.35, 0.35);
	level.ttt.colorsBuyMenu["item_selected"] = (1.0, 0.84, 0.68);
	level.ttt.colorsBuyMenu["traitor"] = (0.2, 0.0, 0.0);
	level.ttt.colorsBuyMenu["detective"] = (0.0, 0.05, 0.2);

	level.ttt.buyMenu["max_columns"] = 3;
	level.ttt.buyMenu["max_entries"] = 9;
	level.ttt.buyMenu["padding"] = 4;
	level.ttt.buyMenu["square_length"] = 48;
	level.ttt.buyMenu["desc_width"] = 152;
}

initPlayer()
{
	self.ttt.ui = [];
	self.ttt.ui["hud"] = [];
	self.ttt.ui["hud"]["self"] = [];
}

displaySelfHud()
{
	self.ttt.ui["hud"]["self"]["role"] = self createFontString("hudbig", 0.8);
	self.ttt.ui["hud"]["self"]["role"] setPoint("TOP RIGHT", "TOP RIGHT", -20, 10);
	self.ttt.ui["hud"]["self"]["role"].hidewheninmenu = true;
	self.ttt.ui["hud"]["self"]["role"].foreground = true;
	self.ttt.ui["hud"]["self"]["role"].color = (1, 1, 1);
	self.ttt.ui["hud"]["self"]["role"].glowAlpha = 1;

	self.ttt.ui["hud"]["self"]["health"] = self createFontString("hudbig", 1.0625);
	self.ttt.ui["hud"]["self"]["health"] setPoint("BOTTOM CENTER", "BOTTOM RIGHT", -46, -33);
	self.ttt.ui["hud"]["self"]["health"].hidewheninmenu = true;
	self.ttt.ui["hud"]["self"]["health"].foreground = true;
	self.ttt.ui["hud"]["self"]["health"].glowAlpha = 1;
	self.ttt.ui["hud"]["self"]["health"].label = &"";

	self displayBombHud();

	self updatePlayerRoleDisplay();
	self updatePlayerHealthDisplay();
	self updatePlayerPassivesDisplay();
}

destroySelfHud()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]);
}

updatePlayerHealthDisplay()
{
	if (!isDefined(self.ttt.ui["hud"]["self"]["health"])) return;

	text = "";
	if (isAlive(self))
	{
		// use cached maxhealth, because disabling health regen messes with the value
		healthPct = self.health / level.ttt.maxhealth;
		healthProxToHalf = (1 - abs(healthPct - 0.5)) * 2;
		healthGlowAlpha = (1 - healthPct + 0.75) * 0.35;

		self.ttt.ui["hud"]["self"]["health"].color = (
			(1 - healthPct) + healthProxToHalf * 0.5,
			healthPct + healthProxToHalf * 0.5,
			0.5
		);
		self.ttt.ui["hud"]["self"]["health"].glowColor = (
			((1 - healthPct) * 0.6 + healthProxToHalf) * healthGlowAlpha,
			(healthPct * 0.6 + healthProxToHalf) * healthGlowAlpha,
			healthGlowAlpha
		);
	}
	self.ttt.ui["hud"]["self"]["health"] setValue(self.health);
}

updatePlayerPassivesDisplay()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["passives"]);

	i = 0;
	foreach (item in level.ttt.items[self.ttt.role])
	{
		if (!isDefined(item.passiveDisplay) || !item.passiveDisplay) continue;
		if (!isInArray(self.ttt.items.boughtItems, item)) continue;

		icon = self createIcon(item.icon, 16, 16);
		icon.hidewheninmenu = true;
		icon.foreground = true;
		if (i == 0)
			icon setPoint("BOTTOM RIGHT", "BOTTOM RIGHT", -128, -15);
		else
		{
			icon setParent(self.ttt.ui["hud"]["self"]["passives"][i - 1]);
			icon setPoint("TOP RIGHT", "TOP LEFT", -4, 0);
		}

		self.ttt.ui["hud"]["self"]["passives"][i] = icon;
		i++;
	}
}

updatePlayerRoleDisplay()
{
	role = self.ttt.role;

	text = "";
	if (!isDefined(role))
	{
		role = "preparing";
		text = "PREPARING";
	}
	else if (role == "innocent") text = "INNOCENT";
	else if (role == "detective") text = "DETECTIVE";
	else if (role == "traitor") text = "TRAITOR";
	self.ttt.ui["hud"]["self"]["role"].glowColor = level.ttt.colors[role];
	self.ttt.ui["hud"]["self"]["role"] setText(text);

	if ((role == "traitor" || role == "detective") && !isDefined(self.ttt.ui["hud"]["self"]["shop_hint"]))
	{
		self.ttt.ui["hud"]["self"]["shop_hint"] = self createFontString("default", 0.8);
		self.ttt.ui["hud"]["self"]["shop_hint"] setParent(self.ttt.ui["hud"]["self"]["role"]);
		self.ttt.ui["hud"]["self"]["shop_hint"] setPoint("TOP RIGHT", "BOTTOM RIGHT", 0, 10);
		self.ttt.ui["hud"]["self"]["shop_hint"].color = (1, 1, 1);
		self.ttt.ui["hud"]["self"]["shop_hint"].alpha = 0.5;
		self.ttt.ui["hud"]["self"]["shop_hint"].archived = false;
		self.ttt.ui["hud"]["self"]["shop_hint"].hidewheninmenu = true;
		self.ttt.ui["hud"]["self"]["shop_hint"].foreground = true;
		self.ttt.ui["hud"]["self"]["shop_hint"].label = &"Press ^3[{+actionslot 2}]^7 to open shop";
	}
}

pulsePlayerRoleDisplay(duration)
{
	self.ttt.ui["hud"]["self"]["role"] thread scripts\ttt\_util::fontPulseCustom(2.0, duration, self);
}

displayUseAvailableHint(label, text, value)
{
	self.ttt.ui["hud"]["self"]["use_hint"] = [];
	self.ttt.ui["hud"]["self"]["use_hint"]["text"] = self createFontString("default", 1.5);
	self.ttt.ui["hud"]["self"]["use_hint"]["text"] setPoint("BOTTOM CENTER", "BOTTOM CENTER", 0, -120);
	self.ttt.ui["hud"]["self"]["use_hint"]["text"].color = (1, 1, 1);
	self.ttt.ui["hud"]["self"]["use_hint"]["text"].alpha = 0.85;
	self.ttt.ui["hud"]["self"]["use_hint"]["text"].archived = false;
	self.ttt.ui["hud"]["self"]["use_hint"]["text"].hidewheninmenu = true;
	updateUseAvailableHint(label, text, value);
}

updateUseAvailableHint(label, text, value)
{
	if (isDefined(label)) self.ttt.ui["hud"]["self"]["use_hint"]["text"].label = label;
	if (isDefined(text)) self.ttt.ui["hud"]["self"]["use_hint"]["text"] setText(text);
	if (isDefined(value)) self.ttt.ui["hud"]["self"]["use_hint"]["text"] setValue(value);
}

destroyUseAvailableHint()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["use_hint"]);
}

displayActivateHint(title, hint)
{
	self.ttt.ui["hud"]["self"]["activate_hint"] = [];

	self.ttt.ui["hud"]["self"]["activate_hint"]["title"] = self createFontString("objective", 1.4);
	self.ttt.ui["hud"]["self"]["activate_hint"]["title"] setPoint("TOP CENTER", "TOP CENTER", 0, 80);
	self.ttt.ui["hud"]["self"]["activate_hint"]["title"].color = (1, 1, 1);
	self.ttt.ui["hud"]["self"]["activate_hint"]["title"].alpha = 0.85;
	self.ttt.ui["hud"]["self"]["activate_hint"]["title"].archived = false;
	self.ttt.ui["hud"]["self"]["activate_hint"]["title"].hidewheninmenu = true;

	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"] = self createFontString("default", 1.5);
	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"] setParent(self.ttt.ui["hud"]["self"]["activate_hint"]["title"]);
	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 12);
	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"].color = (1, 1, 1);
	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"].alpha = 0.85;
	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"].archived = false;
	self.ttt.ui["hud"]["self"]["activate_hint"]["hint"].hidewheninmenu = true;

	updateActivateHint(title, hint);
}

updateActivateHint(title, hint)
{
	if (isDefined(title)) self.ttt.ui["hud"]["self"]["activate_hint"]["title"] setText(title);
	if (isDefined(hint)) self.ttt.ui["hud"]["self"]["activate_hint"]["hint"].label = hint;
}

destroyActivateHint()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["activate_hint"]);
}

setupHeadIconAnchor()
{
	TAG = "j_head";

	headPos = self getTagOrigin(TAG);
	headAngles = self getTagAngles(TAG);

	iconPos = headPos;
	iconPos += anglesToForward(headAngles) * 20.0;
	iconPos += anglesToRight(headAngles) * 4.0;
	iconAnchor = spawn("script_model", iconPos);
	iconAnchor linkTo(self, TAG);
	self.headiconAnchor = iconAnchor;
	self thread OnHeadIconAnchorDestroy();
}

OnHeadIconAnchorDestroy()
{
	self waittill_any("disconnect", "death");

	self.headiconAnchor delete();
}

displayHeadIcons()
{
	self.ttt.ui["hud"]["headicons"] = [];

	foreach (target in getLivingPlayers())
	{
		if (self == target) continue;

		if (self.ttt.role == "traitor" && target.ttt.role == "traitor")
			self displayHeadIconOnPlayer(target, game["entity_headicon_axis"], true);
		if (target.ttt.role == "detective")
		{
			headIcon = self displayHeadIconOnPlayer(target, game["entity_headicon_allies"], false);
			self thread headIconLookAtThink(headIcon, target);
		}
	}
}

headIconLookAtThink(headIcon, target)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_ui_headicons_destroyed");

	RANGE = 8192;
	MAX_POINT_DISTANCE_SQ = 64 * 64;
	MIN_VISIBLE_PCT = 0.8;

	for (;;)
	{
		eyePos = self getEye();
		eyeAngles = self getPlayerAngles();
		eyeDir = anglesToForward(eyeAngles);
		isLookingAtTarget = false;

		vec = vectorFromLineToPoint(eyePos, eyePos + eyeDir * RANGE, target getTagOrigin("tag_stowed_hip_rear"));
		if (lengthSquared(vec) < MAX_POINT_DISTANCE_SQ)
			if (target sightConeTrace(eyePos, self) > MIN_VISIBLE_PCT)
				isLookingAtTarget = true;

		if (isLookingAtTarget && headIcon.visible || !isLookingAtTarget && !headIcon.visible)
			headIcon fadeOverTime(0.15);

		headIcon.visible = isLookingAtTarget;
		headIcon.alpha = isLookingAtTarget * 0.75;

		wait(0.05);
	}
}

destroyHeadIcons()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["headicons"]);
	self notify("ttt_ui_headicons_destroyed");
}

displayHeadIconOnPlayer(target, image, visible)
{
	i = self.ttt.ui["hud"]["headicons"].size;

	self.ttt.ui["hud"]["headicons"][i] = newClientHudElem(self);
	self.ttt.ui["hud"]["headicons"][i] setShader(image, 8, 8);
	self.ttt.ui["hud"]["headicons"][i].color = level.ttt.colors[target.ttt.role];
	self.ttt.ui["hud"]["headicons"][i].alpha = visible * 0.75;
	self.ttt.ui["hud"]["headicons"][i].visible = visible;
	self.ttt.ui["hud"]["headicons"][i] setWaypoint(false, false);
	self.ttt.ui["hud"]["headicons"][i] setTargetEnt(target.headiconAnchor);
	self.ttt.ui["hud"]["headicons"][i] thread OnHeadIconDestroy(self, target);

	return self.ttt.ui["hud"]["headicons"][i];
}

OnHeadIconDestroy(showToPlayer, target)
{
	//self endon("death"); // apparently this always fires instantly
	showToPlayer endon("disconnect");

	target waittill_any("death", "disconnect");
	self destroy();
}

displayRoundEnd(winner, reason)
{
	winnerText = "";
	reasonText = "";
	if (winner == "traitor") winnerText = "THE TRAITORS WIN";
	else winnerText = "THE INNOCENT WIN";

	switch (reason)
	{
		case "death":
			if (winner == "traitor") reasonText = "All innocent players are dead";
			else reasonText = "All traitors have been killed";
			break;
		case "timelimit":
			reasonText = "Time is up";
			break;
	}

	level.ttt.ui["hud"]["outcome"] = [];

	level.ttt.ui["hud"]["outcome"]["bg"] = createRectangle(1000, 80, (0, 0, 0), true);
	level.ttt.ui["hud"]["outcome"]["bg"] setPoint("TOP CENTER", "TOP CENTER", 0, 40);
	level.ttt.ui["hud"]["outcome"]["bg"].archived = false;
	level.ttt.ui["hud"]["outcome"]["bg"].hidewheninmenu = true;
	level.ttt.ui["hud"]["outcome"]["bg"].alpha = 0.35;
	level.ttt.ui["hud"]["outcome"]["bg"].sort = -1;

	level.ttt.ui["hud"]["outcome"]["title"] = createServerFontString("objective", 2.0);
	level.ttt.ui["hud"]["outcome"]["title"] setParent(level.ttt.ui["hud"]["outcome"]["bg"]);
	level.ttt.ui["hud"]["outcome"]["title"] setPoint("TOP CENTER", "TOP CENTER", 0, 16);
	level.ttt.ui["hud"]["outcome"]["title"].archived = false;
	level.ttt.ui["hud"]["outcome"]["title"].hidewheninmenu = true;
	level.ttt.ui["hud"]["outcome"]["title"].glowColor = level.ttt.colors[winner];
	level.ttt.ui["hud"]["outcome"]["title"].glowAlpha = 1;
	level.ttt.ui["hud"]["outcome"]["title"] setText(winnerText);

	level.ttt.ui["hud"]["outcome"]["reason"] = createServerFontString("default", 1.5);
	level.ttt.ui["hud"]["outcome"]["reason"] setParent(level.ttt.ui["hud"]["outcome"]["title"]);
	level.ttt.ui["hud"]["outcome"]["reason"] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 10);
	level.ttt.ui["hud"]["outcome"]["reason"].archived = false;
	level.ttt.ui["hud"]["outcome"]["reason"].hidewheninmenu = true;
	level.ttt.ui["hud"]["outcome"]["reason"] setText(reasonText);
}

destroyRoundEnd()
{
	recursivelyDestroyElements(level.ttt.ui["hud"]["outcome"]);
}

displayGameEnd(data)
{
	teams = [];
	teams[0] = "innocent";
	teams[1] = "traitor";

	displayData = spawnStruct();
	displayData.winCount = [];
	foreach (team in teams)
		displayData.winCount[team] = 0;
	displayData.rounds = [];

	foreach (i, roundData in data)
	{
		if (!roundData.ended || roundData.players.size < 2) continue;

		displayData.winCount[roundData.winner]++;

		displayData.rounds[i] = spawnStruct();
		displayData.rounds[i].winner = roundData.winner;
		displayData.rounds[i].teams = [];
		foreach (team in teams)
		{
			displayData.rounds[i].teams[team] = spawnStruct();
			displayData.rounds[i].teams[team].players = [];
			displayData.rounds[i].teams[team].playerListString = "";
		}

		foreach (playerData in roundData.players)
		{
			playerTeam = playerData["role"];
			if (playerData["role"] == "detective") playerTeam = "innocent";

			roundTeamData = displayData.rounds[i].teams[playerTeam];
			roundTeamData.players[roundTeamData.players.size] = playerData;
		}

		foreach (team, teamData in displayData.rounds[i].teams)
		{
			foreach (playerIndex, playerData in teamData.players)
			{
				if (playerIndex > 0) teamData.playerListString += "^7, ";

				if (roundData.winner == team || playerData["role"] == "detective")
					teamData.playerListString += getRoleStringColor(playerData["role"]);
				teamData.playerListString += removeColorsFromString(playerData["name"]);
			}
		}
	}

	displayData.roundsPerView = [];

	roundsPerView = getDvarInt("ttt_summary_rounds_per_view");
	numViews = ceil(displayData.rounds.size / roundsPerView);
	for (i = 0; i < numViews; i++)
	{
		startIndex = i * roundsPerView;
		roundsThisView = arraySlice(displayData.rounds, startIndex, startIndex + roundsPerView);
		displayData.roundsPerView[displayData.roundsPerView.size] = roundsThisView;
	}

	level.ttt.ui["hud"]["end"] = [];

	level.ttt.ui["hud"]["end"]["bg"] = createRectangle(600, 0, (0, 0, 0), true);
	level.ttt.ui["hud"]["end"]["bg"] setPoint("CENTER", "CENTER", 0, 0);
	level.ttt.ui["hud"]["end"]["bg"].archived = false;
	level.ttt.ui["hud"]["end"]["bg"].hidewheninmenu = true;
	level.ttt.ui["hud"]["end"]["bg"].alpha = 0.35;
	level.ttt.ui["hud"]["end"]["bg"].sort = -1;

	level.ttt.ui["hud"]["end"]["title"] = createServerFontString("objective", 2.0);
	level.ttt.ui["hud"]["end"]["title"] setParent(level.ttt.ui["hud"]["end"]["bg"]);
	level.ttt.ui["hud"]["end"]["title"] setPoint("TOP CENTER", "TOP CENTER", 0, 16);
	level.ttt.ui["hud"]["end"]["title"].archived = false;
	level.ttt.ui["hud"]["end"]["title"].hidewheninmenu = true;
	level.ttt.ui["hud"]["end"]["title"].label = &"ROUNDS SUMMARY";

	foreach (team in teams)
	{
		level.ttt.ui["hud"]["end"]["team_headings"][team] = createServerFontString("objective", 1.5);
		level.ttt.ui["hud"]["end"]["team_headings"][team].archived = false;
		level.ttt.ui["hud"]["end"]["team_headings"][team].hidewheninmenu = true;
		level.ttt.ui["hud"]["end"]["team_headings"][team] setParent(level.ttt.ui["hud"]["end"]["title"]);

		if (team == "innocent")
		{
			level.ttt.ui["hud"]["end"]["team_headings"][team] setPoint("TOP RIGHT", "BOTTOM CENTER", -16, 16);
			level.ttt.ui["hud"]["end"]["team_headings"][team].label = &"^2INNOCENT ^7[^2&&1^7]";
		}
		else if (team == "traitor")
		{
			level.ttt.ui["hud"]["end"]["team_headings"][team] setPoint("TOP LEFT", "BOTTOM CENTER", 16, 16);
			level.ttt.ui["hud"]["end"]["team_headings"][team].label = &"^1TRAITORS ^7[^1&&1^7]";
		}

		level.ttt.ui["hud"]["end"]["team_headings"][team] setValue(displayData.winCount[team]);
	}

	foreach (rounds in displayData.roundsPerView)
	{
		recursivelyDestroyElements(level.ttt.ui["hud"]["end"]["rounds"]);

		foreach (i, round in rounds)
		{
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"] = createServerFontString("objective", 1.5);
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].alpha = 0.0;
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].archived = false;
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].hidewheninmenu = true;

			centerLabel = undefined;
			if (round.winner == "innocent") centerLabel = &"^3�";
			else if (round.winner == "traitor") centerLabel = &"^3�";
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].label = centerLabel;

			if (i == 0)
			{
				level.ttt.ui["hud"]["end"]["rounds"][i]["center"] setParent(level.ttt.ui["hud"]["end"]["title"]);
				level.ttt.ui["hud"]["end"]["rounds"][i]["center"] setPoint("CENTER", "BOTTOM CENTER", 0, 64);
			}
			else
			{
				level.ttt.ui["hud"]["end"]["rounds"][i]["center"] setParent(level.ttt.ui["hud"]["end"]["rounds"][i - 1]["center"]);
				level.ttt.ui["hud"]["end"]["rounds"][i]["center"] setPoint("CENTER", "CENTER", 0, 32);
			}

			foreach (team in teams)
			{
				level.ttt.ui["hud"]["end"]["rounds"][i][team] = createServerFontString("default", 1.5);
				level.ttt.ui["hud"]["end"]["rounds"][i][team].alpha = 0.0;
				level.ttt.ui["hud"]["end"]["rounds"][i][team].archived = false;
				level.ttt.ui["hud"]["end"]["rounds"][i][team].hidewheninmenu = true;
				level.ttt.ui["hud"]["end"]["rounds"][i][team] setText(round.teams[team].playerListString);

				level.ttt.ui["hud"]["end"]["rounds"][i][team] setParent(level.ttt.ui["hud"]["end"]["rounds"][i]["center"]);

				if (team == "innocent")
					level.ttt.ui["hud"]["end"]["rounds"][i][team] setPoint("CENTER RIGHT", "CENTER", -16, 0);
				else if (team == "traitor")
					level.ttt.ui["hud"]["end"]["rounds"][i][team] setPoint("CENTER LEFT", "CENTER", 16, 0);
			}
		}

		bgHeight = 32; // padding
		bgHeight += level.ttt.ui["hud"]["end"]["title"].height + 64;
		foreach (line in level.ttt.ui["hud"]["end"]["rounds"])
			bgHeight += 32;
		bgHeight -= 32;
		bgHeight += level.ttt.ui["hud"]["end"]["rounds"][0]["center"].height / 2;
		level.ttt.ui["hud"]["end"]["bg"] setRectDimensions(undefined, int(bgHeight));

		foreach (i, round in rounds)
		{
			wait(0.8);

			foreach (player in level.players) player playLocalSound("explo_plant_no_tick");

			level.ttt.ui["hud"]["end"]["rounds"][i]["center"] fadeOverTime(0.4);
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].alpha = 1.0;

			prevFontScale = level.ttt.ui["hud"]["end"]["rounds"][i]["center"].fontScale;
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].fontScale = 6.0;
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"] changeFontScaleOverTime(0.4);
			level.ttt.ui["hud"]["end"]["rounds"][i]["center"].fontScale = prevFontScale;

			foreach (team in teams)
			{
				if (team == round.winner)
				{
					level.ttt.ui["hud"]["end"]["rounds"][i][team] fadeOverTime(0.25);
					level.ttt.ui["hud"]["end"]["rounds"][i][team] thread fontPulseCustom(1.25, 0.6);
				}
				else
					level.ttt.ui["hud"]["end"]["rounds"][i][team] fadeOverTime(0.6);
				level.ttt.ui["hud"]["end"]["rounds"][i][team].alpha = 1.0;
			}
		}

		wait(getDvarFloat("ttt_summary_time_per_view"));
	}
}

destroyGameEnd()
{
	recursivelyDestroyElements(level.ttt.ui["hud"]["end"]);
}

displayScoreboard()
{
	self.ttt.ui["sb"] = [];
	self.ttt.ui["sb"]["icon"] = [];
	self.ttt.ui["sb"]["headings"] = [];
	self.ttt.ui["sb"]["names"] = [];

	players = [];
	players["alive"] = [];
	players["missing"] = [];
	players["confirmed"] = [];

	foreach (player in level.players)
	{
		if (!level.ttt.preparing && !isDefined(player.ttt.role)) continue; // exclude players who joined late

		if (!isAlive(player) && player.ttt.bodyFound)
			players["confirmed"][players["confirmed"].size] = player;
		else if (!isAlive(player) && (self.ttt.role == "traitor" || level.gameEnded || !isAlive(self)))
			players["missing"][players["missing"].size] = player;
		else
			players["alive"][players["alive"].size] = player;
	}

	vertPadding = 8;
	totalVertPadding = vertPadding * 2; // top and bottom padding

	self.ttt.ui["sb"]["bg"] = self createRectangle(240, 0, (0, 0, 0));
	self.ttt.ui["sb"]["bg"] setPoint("CENTER", "CENTER", 0, 0);
	self.ttt.ui["sb"]["bg"].alpha = 0.65;
	self.ttt.ui["sb"]["bg"].archived = false;
	self.ttt.ui["sb"]["bg"].foreground = true; // gets it displayed over the crosshair
	self.ttt.ui["sb"]["bg"].sort = -1;

	self.ttt.ui["sb"]["icon"]["face"] = self createIcon("cardicon_comic_shepherd", 32, 32);
	self.ttt.ui["sb"]["icon"]["face"] setParent(self.ttt.ui["sb"]["bg"]);
	self.ttt.ui["sb"]["icon"]["face"] setPoint("BOTTOM LEFT", "TOP LEFT", 4, 2);
	self.ttt.ui["sb"]["icon"]["face"].archived = false;
	self.ttt.ui["sb"]["icon"]["face"].foreground = true;
	self.ttt.ui["sb"]["icon"]["face"].sort = 5;

	self.ttt.ui["sb"]["icon"]["pipe"] = self createIcon("cardtitle_silencer", 20, 4);
	self.ttt.ui["sb"]["icon"]["pipe"] setParent(self.ttt.ui["sb"]["icon"]["face"]);
	self.ttt.ui["sb"]["icon"]["pipe"] setPoint("TOP LEFT", "TOP LEFT", 14, 22);
	self.ttt.ui["sb"]["icon"]["pipe"].archived = false;
	self.ttt.ui["sb"]["icon"]["pipe"].foreground = true;
	self.ttt.ui["sb"]["icon"]["pipe"].sort = 10;

	// ALIVE PLAYERS

	self.ttt.ui["sb"]["headings"]["alive"] = self createFontString("objective", 1.5);
	self.ttt.ui["sb"]["headings"]["alive"] setParent(self.ttt.ui["sb"]["bg"]);
	self.ttt.ui["sb"]["headings"]["alive"] setPoint("TOP CENTER", "TOP CENTER", 0, vertPadding);
	self.ttt.ui["sb"]["headings"]["alive"].archived = false;
	self.ttt.ui["sb"]["headings"]["alive"] setText("PLAYERS (" + players["alive"].size + ")");

	foreach (i, player in players["alive"])
	{
		self.ttt.ui["sb"]["names"][i] = self createFontString("default", 1.5);
		if (i == 0) self.ttt.ui["sb"]["names"][i] setParent(self.ttt.ui["sb"]["headings"]["alive"]);
		else self.ttt.ui["sb"]["names"][i] setParent(self.ttt.ui["sb"]["names"][i - 1]);
		self.ttt.ui["sb"]["names"][i] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 0);
		self.ttt.ui["sb"]["names"][i].archived = false;
		if (player.guid == self.guid)
		{
			self.ttt.ui["sb"]["names"][i].glowColor = level.ttt.colorsScoreboard["self"];
			self.ttt.ui["sb"]["names"][i].glowAlpha = 1;
		}
		if (player.ttt.role == "detective" || self.ttt.role == "traitor" || level.gameEnded || !isAlive(self))
			self.ttt.ui["sb"]["names"][i].color = level.ttt.colorsScoreboard[player.ttt.role];
		self.ttt.ui["sb"]["names"][i] setText(removeColorsFromString(player.name));
	}

	// MISSING PLAYERS

	if (players["missing"].size > 0)
	{
		self.ttt.ui["sb"]["headings"]["missing"] = self createFontString("objective", 1.5);
		if (players["alive"].size > 0)
			self.ttt.ui["sb"]["headings"]["missing"] setParent(self.ttt.ui["sb"]["names"][self.ttt.ui["sb"]["names"].size - 1]);
		else
			self.ttt.ui["sb"]["headings"]["missing"] setParent(self.ttt.ui["sb"]["headings"]["alive"]);
		self.ttt.ui["sb"]["headings"]["missing"] setPoint("TOP CENTER", "BOTTOM CENTER", 0, vertPadding);
		self.ttt.ui["sb"]["headings"]["missing"].archived = false;
		totalVertPadding += vertPadding;
		self.ttt.ui["sb"]["headings"]["missing"] setText("MISSING IN ACTION (" + players["missing"].size + ")");

		foreach (i, player in players["missing"])
		{
			j = i + players["alive"].size;
			self.ttt.ui["sb"]["names"][j] = self createFontString("default", 1.5);
			if (i == 0) self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["headings"]["missing"]);
			else self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["names"][j - 1]);
			self.ttt.ui["sb"]["names"][j] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 0);
			self.ttt.ui["sb"]["names"][j].archived = false;
			if (player.guid == self.guid)
			{
				self.ttt.ui["sb"]["names"][j].glowColor = level.ttt.colorsScoreboard["self"];
				self.ttt.ui["sb"]["names"][j].glowAlpha = 1;
			}
			if (player.ttt.role == "detective" || self.ttt.role == "traitor" || level.gameEnded || !isAlive(self))
				self.ttt.ui["sb"]["names"][j].color = level.ttt.colorsScoreboard[player.ttt.role];
			self.ttt.ui["sb"]["names"][j] setText(removeColorsFromString(player.name));
		}
	}

	// DEAD PLAYERS

	if (players["confirmed"].size > 0)
	{
		self.ttt.ui["sb"]["headings"]["confirmed"] = self createFontString("objective", 1.5);
		if (players["missing"].size > 0)
			self.ttt.ui["sb"]["headings"]["confirmed"] setParent(self.ttt.ui["sb"]["names"][self.ttt.ui["sb"]["names"].size - 1]);
		else if (isDefined(self.ttt.ui["sb"]["headings"]["missing"]))
			self.ttt.ui["sb"]["headings"]["confirmed"] setParent(self.ttt.ui["sb"]["headings"]["missing"]);
		else if (players["alive"].size > 0)
			self.ttt.ui["sb"]["headings"]["confirmed"] setParent(self.ttt.ui["sb"]["names"][self.ttt.ui["sb"]["names"].size - 1]);
		else
			self.ttt.ui["sb"]["headings"]["confirmed"] setParent(self.ttt.ui["sb"]["headings"]["alive"]);
		self.ttt.ui["sb"]["headings"]["confirmed"] setPoint("TOP CENTER", "BOTTOM CENTER", 0, vertPadding);
		self.ttt.ui["sb"]["headings"]["confirmed"].archived = false;
		totalVertPadding += vertPadding;
		self.ttt.ui["sb"]["headings"]["confirmed"] setText("CONFIRMED DEAD (" + players["confirmed"].size + ")");

		foreach (i, player in players["confirmed"])
		{
			j = i + players["alive"].size + players["missing"].size;
			self.ttt.ui["sb"]["names"][j] = self createFontString("default", 1.5);
			if (i == 0) self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["headings"]["confirmed"]);
			else self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["names"][j - 1]);
			self.ttt.ui["sb"]["names"][j] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 0);
			self.ttt.ui["sb"]["names"][j].archived = false;
			if (player.guid == self.guid)
			{
				self.ttt.ui["sb"]["names"][j].glowColor = level.ttt.colorsScoreboard["self"];
				self.ttt.ui["sb"]["names"][j].glowAlpha = 1;
			}
			self.ttt.ui["sb"]["names"][j].color = level.ttt.colorsScoreboard[player.ttt.role];
			self.ttt.ui["sb"]["names"][j] setText(removeColorsFromString(player.name));
		}
	}

	sbHeight = 0;
	foreach (heading in self.ttt.ui["sb"]["headings"]) sbHeight += heading.height;
	foreach (name in self.ttt.ui["sb"]["names"]) sbHeight += name.height;
	sbHeight += totalVertPadding;
	self.ttt.ui["sb"]["bg"] setRectDimensions(undefined, int(sbHeight));
}

destroyScoreboard()
{
	recursivelyDestroyElements(self.ttt.ui["sb"]);
}

displayBuyMenu(role)
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["passives"]);

	MAX_COLUMNS = level.ttt.buyMenu["max_columns"];
	MAX_ENTRIES = level.ttt.buyMenu["max_entries"];
	PADDING = level.ttt.buyMenu["padding"];
	SQUARE_LENGTH = level.ttt.buyMenu["square_length"];
	DESC_WIDTH = level.ttt.buyMenu["desc_width"];

	rowCount = int(min(ceil(level.ttt.items[role].size / MAX_COLUMNS), ceil(MAX_ENTRIES / MAX_COLUMNS)));
	columnCount = int(min(level.ttt.items[role].size, MAX_COLUMNS));
	entryCount = int(min(level.ttt.items[role].size, MAX_ENTRIES));

	self.ttt.ui["bm"] = [];

	self.ttt.ui["bm"]["bg"] = self createRectangle(0, 0, level.ttt.colorsBuyMenu[role]);
	self.ttt.ui["bm"]["bg"] setPoint("CENTER", "CENTER", 0, 0);
	self.ttt.ui["bm"]["bg"].alpha = 0.65;
	self.ttt.ui["bm"]["bg"].hidewheninmenu = true;
	self.ttt.ui["bm"]["bg"].foreground = true; // gets it displayed over the crosshair
	self.ttt.ui["bm"]["bg"].sort = -1;

	self.ttt.ui["bm"]["title"] = self createFontString("hudbig", 1.0);
	self.ttt.ui["bm"]["title"] setParent(self.ttt.ui["bm"]["bg"]);
	self.ttt.ui["bm"]["title"] setPoint("TOP CENTER", "TOP CENTER", 0, 0);
	self.ttt.ui["bm"]["title"].hidewheninmenu = true;
	self.ttt.ui["bm"]["title"].foreground = true;
	self.ttt.ui["bm"]["title"].label = &"CREDIT SHOP";

	self.ttt.ui["bm"]["items_bg"] = [];
	for (i = 0; i < entryCount; i++)
	{
		self.ttt.ui["bm"]["items_bg"][i] = self createRectangle(SQUARE_LENGTH, SQUARE_LENGTH, level.ttt.colorsBuyMenu["item_bg"]);
		self.ttt.ui["bm"]["items_bg"][i].alpha = 0.8;
		self.ttt.ui["bm"]["items_bg"][i].foreground = true;
		self.ttt.ui["bm"]["items_bg"][i].hidewheninmenu = true;

		if (i == 0) // first element
		{
			self.ttt.ui["bm"]["items_bg"][i] setParent(self.ttt.ui["bm"]["bg"]);
			self.ttt.ui["bm"]["items_bg"][i] setPoint("TOP LEFT", "TOP LEFT", PADDING, self.ttt.ui["bm"]["title"].height + PADDING * 4);
		}
		else if (i % MAX_COLUMNS == 0) // new row
		{
			self.ttt.ui["bm"]["items_bg"][i] setParent(self.ttt.ui["bm"]["items_bg"][i - MAX_COLUMNS]);
			self.ttt.ui["bm"]["items_bg"][i] setPoint("TOP LEFT", "BOTTOM LEFT", 0, PADDING);
		}
		else // continue row
		{
			self.ttt.ui["bm"]["items_bg"][i] setParent(self.ttt.ui["bm"]["items_bg"][i - 1]);
			self.ttt.ui["bm"]["items_bg"][i] setPoint("TOP LEFT", "TOP RIGHT", PADDING, 0);
		}
	}

	gridWidth = (self.ttt.ui["bm"]["items_bg"][0].width + PADDING) * columnCount - PADDING;
	gridHeight = (self.ttt.ui["bm"]["items_bg"][0].height + PADDING) * rowCount - PADDING;

	self.ttt.ui["bm"]["scroll_bg"] = self createRectangle(PADDING, gridHeight, (1, 1, 1));
	self.ttt.ui["bm"]["scroll_bg"] setParent(self.ttt.ui["bm"]["items_bg"][columnCount - 1]);
	self.ttt.ui["bm"]["scroll_bg"] setPoint("TOP LEFT", "TOP RIGHT", PADDING, 0);
	self.ttt.ui["bm"]["scroll_bg"].alpha = 0.45;
	self.ttt.ui["bm"]["scroll_bg"].hidewheninmenu = true;
	self.ttt.ui["bm"]["scroll_bg"].foreground = true;

	self.ttt.ui["bm"]["scroll_thumb"] = self createRectangle(PADDING, gridHeight, (1, 1, 1));
	self.ttt.ui["bm"]["scroll_thumb"] setParent(self.ttt.ui["bm"]["scroll_bg"]);
	self.ttt.ui["bm"]["scroll_thumb"] setPoint("TOP LEFT", "TOP LEFT", 0, 0);
	self.ttt.ui["bm"]["scroll_thumb"].hidewheninmenu = true;
	self.ttt.ui["bm"]["scroll_thumb"].foreground = true;

	self.ttt.ui["bm"]["name"] = self createFontString("objective", 1.0);
	self.ttt.ui["bm"]["name"] setParent(self.ttt.ui["bm"]["items_bg"][columnCount - 1]);
	self.ttt.ui["bm"]["name"] setPoint("TOP LEFT", "TOP RIGHT", PADDING * 4, 0);
	self.ttt.ui["bm"]["name"].hidewheninmenu = true;
	self.ttt.ui["bm"]["name"].foreground = true;

	self.ttt.ui["bm"]["unavailable_hint"] = self createFontString("default", 1.0);
	self.ttt.ui["bm"]["unavailable_hint"] setParent(self.ttt.ui["bm"]["name"]);
	self.ttt.ui["bm"]["unavailable_hint"] setPoint("TOP LEFT", "BOTTOM LEFT", 0, PADDING);
	self.ttt.ui["bm"]["unavailable_hint"].hidewheninmenu = true;
	self.ttt.ui["bm"]["unavailable_hint"].foreground = true;

	self.ttt.ui["bm"]["desc"] = self createFontString("default", 1.0);
	self.ttt.ui["bm"]["desc"] setParent(self.ttt.ui["bm"]["name"]);
	self.ttt.ui["bm"]["desc"] setPoint("TOP LEFT", "BOTTOM LEFT", 0, PADDING);
	self.ttt.ui["bm"]["desc"].hidewheninmenu = true;
	self.ttt.ui["bm"]["desc"].foreground = true;

	self.ttt.ui["bm"]["credits"] = self createFontString("default", 1.2);
	self.ttt.ui["bm"]["credits"] setParent(self.ttt.ui["bm"]["bg"]);
	self.ttt.ui["bm"]["credits"] setPoint("BOTTOM LEFT", "BOTTOM LEFT", PADDING, PADDING * -1);
	self.ttt.ui["bm"]["credits"].hidewheninmenu = true;
	self.ttt.ui["bm"]["credits"].foreground = true;
	self.ttt.ui["bm"]["credits"].label = &"Available Credits: ^3";

	bgWidth = PADDING + gridWidth + PADDING * 2 + DESC_WIDTH + PADDING;
	bgHeight = (self.ttt.ui["bm"]["title"].height + PADDING * 3) + gridHeight + self.ttt.ui["bm"]["credits"].height + PADDING * 4;

	self.ttt.ui["bm"]["bg"] setRectDimensions(int(bgWidth), int(bgHeight));

	self updateBuyMenu(role);
}

updateBuyMenu(role, moveDown, moveRight, buySelected)
{
	if (!isDefined(role)) return;
	if (!isDefined(moveDown)) moveDown = 0;
	if (!isDefined(moveRight)) moveRight = 0;
	if (!isDefined(buySelected)) buySelected = false;

	MAX_COLUMNS = level.ttt.buyMenu["max_columns"];
	MAX_ENTRIES = level.ttt.buyMenu["max_entries"];
	PADDING = level.ttt.buyMenu["padding"];
	SQUARE_LENGTH = level.ttt.buyMenu["square_length"];

	totalRowCount = int(ceil(level.ttt.items[role].size / MAX_COLUMNS));
	rowCount = int(min(totalRowCount, ceil(MAX_ENTRIES / MAX_COLUMNS)));
	columnCount = int(min(level.ttt.items[role].size, MAX_COLUMNS));
	entryCount = int(min(level.ttt.items[role].size, MAX_ENTRIES));
	itemsScrolled = self.ttt.items.rowsScrolled * columnCount;

	// Update selected item
	prevSelectedIndex = self.ttt.items.selectedIndex;
	selectedIndexHoriz = self.ttt.items.selectedIndex % columnCount;
	selectedIndexVert = int(self.ttt.items.selectedIndex / columnCount);

	if (selectedIndexVert + moveDown >= 0 && selectedIndexVert + moveDown < totalRowCount)
		selectedIndexVert += moveDown;
	if (selectedIndexHoriz + moveRight >= 0 && selectedIndexHoriz + moveRight < columnCount)
		selectedIndexHoriz += moveRight;
	self.ttt.items.selectedIndex = selectedIndexHoriz + selectedIndexVert * columnCount;
	if (self.ttt.items.selectedIndex < 0)
		self.ttt.items.selectedIndex = 0;
	if (self.ttt.items.selectedIndex >= level.ttt.items[role].size)
		self.ttt.items.selectedIndex = level.ttt.items[role].size - 1;

	// Update scrolling
	if (self.ttt.items.selectedIndex < itemsScrolled)
		self.ttt.items.rowsScrolled = int(self.ttt.items.selectedIndex / columnCount);
	else if (self.ttt.items.selectedIndex >= itemsScrolled + entryCount)
		self.ttt.items.rowsScrolled = int(self.ttt.items.selectedIndex / columnCount) - rowCount + 1;

	itemsScrolled = self.ttt.items.rowsScrolled * columnCount;
	selectedItem = level.ttt.items[role][self.ttt.items.selectedIndex];
	selectedGridIndex = self.ttt.items.selectedIndex - itemsScrolled;
	selectedIsAvailable = [[selectedItem.getIsAvailable]](selectedItem);

	// Update item texts
	self.ttt.ui["bm"]["name"] setText(selectedItem.name);
	self.ttt.ui["bm"]["name"].alpha = 1 - (!(selectedIsAvailable && self.ttt.items.credits) * 0.5);
	self.ttt.ui["bm"]["desc"] setText(selectedItem.description);
	self.ttt.ui["bm"]["desc"].alpha = 1 - (!(selectedIsAvailable && self.ttt.items.credits) * 0.5);

	// Update unavailability hints
	if (!selectedIsAvailable)
		self.ttt.ui["bm"]["unavailable_hint"].label = selectedItem.unavailableHint;
	else if (!self.ttt.items.credits)
		self.ttt.ui["bm"]["unavailable_hint"].label = &"^1No credits available";
	else
		self.ttt.ui["bm"]["unavailable_hint"].label = &"";

	/**
	 * Using setParent() / setPoint() here and then closing the menu with Esc (see OnPlayerBuyMenuEsc)
	 * somehow creates an infinite loop with the updating of the element's children.
	 * Even though it shouldn't have any, neither is this called when closing the menu. ?????
	 * But it does work when first checking if the element is defined. I don't know why.
	 */

	if (isDefined(self.ttt.ui["bm"]["desc"]))
	{
		if (selectedIsAvailable && self.ttt.items.credits)
			self.ttt.ui["bm"]["desc"] setParent(self.ttt.ui["bm"]["name"]);
		else // move down the description by the space the unavailability hint takes up
			self.ttt.ui["bm"]["desc"] setParent(self.ttt.ui["bm"]["unavailable_hint"]);
	}

	// Update rectangle colors
	foreach (i, itemBg in self.ttt.ui["bm"]["items_bg"])
	{
		itemBg.color = level.ttt.colorsBuyMenu["item_bg"];
		itemBg.alpha = i + itemsScrolled < level.ttt.items[role].size;
	}
	self.ttt.ui["bm"]["items_bg"][selectedGridIndex].color = level.ttt.colorsBuyMenu["item_selected"];

	// Update icons
	recursivelyDestroyElements(self.ttt.ui["bm"]["items_icon"]);
	visibleItems = arraySlice(level.ttt.items[role], itemsScrolled, itemsScrolled + entryCount);

	foreach (i, item in visibleItems)
	{
		iconWidth = 32;
		iconHeight = 32;
		if (isDefined(item.iconWidth)) iconWidth = item.iconWidth;
		if (isDefined(item.iconHeight)) iconHeight = item.iconHeight;
		icon = self createIcon(item.icon, iconWidth, iconHeight);
		self.ttt.ui["bm"]["items_icon"][i] = icon;
		icon.foreground = true;
		icon.hidewheninmenu = true;
		icon.sort = 5;
		icon.alpha = 1.0;
		icon.color = (1.0, 1.0, 1.0);

		isAvailable = [[item.getIsAvailable]](item);
		if (!isAvailable || self.ttt.items.credits <= 0)
		{
			icon.alpha = 0.25;
			if (!isAvailable) icon.color = (1.0, 0.4, 0.4);
		}

		icon setParent(self.ttt.ui["bm"]["items_bg"][i]);
		iconOffsetX = int(SQUARE_LENGTH / 2 - iconWidth / 2);
		iconOffsetY = int(SQUARE_LENGTH / 2 - iconHeight / 2);
		if (isDefined(item.iconOffsetX)) iconOffsetX += item.iconOffsetX;
		if (isDefined(item.iconOffsetY)) iconOffsetY += item.iconOffsetY;
		icon setPoint("TOP LEFT", "TOP LEFT", iconOffsetX, iconOffsetY);
	}

	// Update scrollbar
	visiblePercentage = rowCount / totalRowCount;
	trackHeight = self.ttt.ui["bm"]["scroll_bg"].height;
	self.ttt.ui["bm"]["scroll_thumb"] setRectDimensions(undefined, trackHeight * visiblePercentage);
	clippedRowCount = totalRowCount - rowCount;
	yOffsetPctPerRow = (1 - visiblePercentage) / clippedRowCount;
	yOffset = yOffsetPctPerRow * self.ttt.items.rowsScrolled * trackHeight;
	self.ttt.ui["bm"]["scroll_thumb"] setPoint("TOP LEFT", "TOP LEFT", 0, yOffset);
	self.ttt.ui["bm"]["scroll_thumb"].alpha = level.ttt.items[role].size > MAX_ENTRIES;

	// Update credit count
	self.ttt.ui["bm"]["credits"] setValue(self.ttt.items.credits);

	// Play sounds
	if (buySelected) self playLocalSound("oldschool_pickup");
	else if (prevSelectedIndex != self.ttt.items.selectedIndex) self playLocalSound("mouse_over");
}

destroyBuyMenu()
{
	recursivelyDestroyElements(self.ttt.ui["bm"]);
	self updatePlayerPassivesDisplay();
}

updateBombHuds()
{
	foreach (player in level.players)
	{
		player destroyBombHud();
		player displayBombHud();
	}
}

displayBombHud()
{
	if ((isAlive(self) && (!isDefined(self.ttt.role) || self.ttt.role != "traitor")) || self.ttt.items.inBuyMenu) return;

	self.ttt.ui["hud"]["self"]["bombs"] = [];

	foreach(i, bombEnt in level.ttt.bombs)
	{
		self.ttt.ui["hud"]["self"]["bombs"][i] = [];

		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] = newClientHudElem(self);
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] setShader("hud_suitcase_bomb");
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"].color = (1, 0.3, 0.3);
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"].alpha = 0.5;
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] setWaypoint(true, true);
		self.ttt.ui["hud"]["self"]["bombs"][i]["waypoint"] setTargetEnt(bombEnt);

		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] = self createIcon("hud_suitcase_bomb", 24, 24);
		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"].color = (1, 0.3, 0.3);
		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"].hidewheninmenu = true;
		self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] setPoint("TOP RIGHT", "TOP RIGHT", -20, 60);
		if (i > 0)
		{
			self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] setParent(self.ttt.ui["hud"]["self"]["bombs"][i - 1]["icon"]);
			self.ttt.ui["hud"]["self"]["bombs"][i]["icon"] setPoint("TOP LEFT", "TOP LEFT", 0, 24 + 12);
		}

		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] = self createFontString("default", 1.5);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] setParent(self.ttt.ui["hud"]["self"]["bombs"][i]["icon"]);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] setPoint("BOTTOM RIGHT ", "BOTTOM RIGHT", 2, 2);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"].color = (1, 1, 1);
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"].hidewheninmenu = true;
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"].foreground = true;
		self.ttt.ui["hud"]["self"]["bombs"][i]["text"] setValue(scripts\ttt\items\bomb::getBombSecondsRemaining(bombEnt));
	}
}

destroyBombHud()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["bombs"]);
}

displayCameraHud(cameraEnt)
{
	destroyed = !isDefined(cameraEnt) || cameraEnt.destroyed;

	self.ttt.ui["hud"]["self"]["camera"] = [];

	self.ttt.ui["hud"]["self"]["camera"]["static"] = newClientHudElem(self);
	self.ttt.ui["hud"]["self"]["camera"]["static"].horzAlign = "fullscreen";
	self.ttt.ui["hud"]["self"]["camera"]["static"].vertAlign = "fullscreen";
	self.ttt.ui["hud"]["self"]["camera"]["static"] setShader("ac130_overlay_grain", 640, 480);
	self.ttt.ui["hud"]["self"]["camera"]["static"].sort = 1;
	self.ttt.ui["hud"]["self"]["camera"]["static"].alpha = 0.4;

	if (destroyed)
	{
		self.ttt.ui["hud"]["self"]["camera"]["static"].alpha = 1.0;

		self.ttt.ui["hud"]["self"]["camera"]["white"] = newClientHudElem(self);
		self.ttt.ui["hud"]["self"]["camera"]["white"].horzAlign = "fullscreen";
		self.ttt.ui["hud"]["self"]["camera"]["white"].vertAlign = "fullscreen";
		self.ttt.ui["hud"]["self"]["camera"]["white"] setShader("black", 640, 480);
		self.ttt.ui["hud"]["self"]["camera"]["white"].alpha = 0.5;

		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"] = self createFontString("objective", 3);
		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"] setPoint("CENTER", "CENTER", 0, 0);
		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"].label = &"NO SIGNAL ...";
		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"].glowColor = (0.4, 0.45, 0.8);
		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"].glowAlpha = 1;
		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"].sort = 5;
		self.ttt.ui["hud"]["self"]["camera"]["nosignal_text"].hidewheninmenu = true;
	}
	else
	{
		self.ttt.ui["hud"]["self"]["camera"]["overlay"] = newClientHudElem(self);
		self.ttt.ui["hud"]["self"]["camera"]["overlay"].horzAlign = "fullscreen";
		self.ttt.ui["hud"]["self"]["camera"]["overlay"].vertAlign = "fullscreen";
		self.ttt.ui["hud"]["self"]["camera"]["overlay"] setShader("nightvision_overlay_goggles", 640, 480);
		self.ttt.ui["hud"]["self"]["camera"]["overlay"].alpha = 1.0;

		self.ttt.ui["hud"]["self"]["camera"]["live_dot"] = self createIcon("compassping_enemy", 40, 40);
		self.ttt.ui["hud"]["self"]["camera"]["live_dot"].color = (1.0, 0.5, 0.5);
		self.ttt.ui["hud"]["self"]["camera"]["live_dot"] setPoint("TOP LEFT", "TOP LEFT", 16, 16);
		self.ttt.ui["hud"]["self"]["camera"]["live_dot"].sort = 5;
		self.ttt.ui["hud"]["self"]["camera"]["live_dot"].hidewheninmenu = true;

		self.ttt.ui["hud"]["self"]["camera"]["live_text"] = self createFontString("objective", 1.5);
		self.ttt.ui["hud"]["self"]["camera"]["live_text"] setParent(self.ttt.ui["hud"]["self"]["camera"]["live_dot"]);
		self.ttt.ui["hud"]["self"]["camera"]["live_text"] setPoint("CENTER LEFT", "CENTER RIGHT", -2, -1.5);
		self.ttt.ui["hud"]["self"]["camera"]["live_text"].label = &"LIVE";
		self.ttt.ui["hud"]["self"]["camera"]["live_text"].glowColor = (0.7, 0.7, 0.7);
		self.ttt.ui["hud"]["self"]["camera"]["live_text"].glowAlpha = 1;
		self.ttt.ui["hud"]["self"]["camera"]["live_text"].sort = 5;
		self.ttt.ui["hud"]["self"]["camera"]["live_text"].hidewheninmenu = true;

		self.ttt.ui["hud"]["self"]["camera"]["time"] = [];

		self.ttt.ui["hud"]["self"]["camera"]["time"]["h"] = self createFontString("objective", 1.5);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["h"] setPoint("BOTTOM CENTER", "BOTTOM LEFT", 28, -24);

		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_1"] = self createFontString("objective", 1.5);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_1"] setParent(self.ttt.ui["hud"]["self"]["camera"]["time"]["h"]);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_1"] setPoint("CENTER", "CENTER", 14, 0);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_1"].label = &":";

		self.ttt.ui["hud"]["self"]["camera"]["time"]["m"] = self createFontString("objective", 1.5);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["m"] setPoint("CENTER", "CENTER", 14, 0);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["m"] setParent(self.ttt.ui["hud"]["self"]["camera"]["time"]["col_1"]);

		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_2"] = self createFontString("objective", 1.5);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_2"] setParent(self.ttt.ui["hud"]["self"]["camera"]["time"]["m"]);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_2"] setPoint("CENTER", "CENTER", 14, 0);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["col_2"].label = &":";

		self.ttt.ui["hud"]["self"]["camera"]["time"]["s"] = self createFontString("objective", 1.5);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["s"] setParent(self.ttt.ui["hud"]["self"]["camera"]["time"]["col_2"]);
		self.ttt.ui["hud"]["self"]["camera"]["time"]["s"] setPoint("CENTER", "CENTER", 14, 0);

		foreach (timeEl in self.ttt.ui["hud"]["self"]["camera"]["time"])
		{
			timeEl.glowColor = (0.7, 0.7, 0.7);
			timeEl.glowAlpha = 1;
			timeEl.sort = 5;
			timeEl.hidewheninmenu = true;
		}

		self thread cameraHudThink(cameraEnt);
		self thread OnPlayerCameraDestroyed(cameraEnt);
	}
}

cameraHudThink(cameraEnt)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_ui_camera_hud_destroyed");

	for (;;)
	{
		hms = secsToHMS((getTime() - cameraEnt.birthtime) / 1000);

		foreach (key, value in hms)
		{
			self.ttt.ui["hud"]["self"]["camera"]["time"][key] setValue(value);
			if (value < 10)
				self.ttt.ui["hud"]["self"]["camera"]["time"][key].label = &"0";
			else
				self.ttt.ui["hud"]["self"]["camera"]["time"][key].label = &"";
		}

		wait(0.5);
		self.ttt.ui["hud"]["self"]["camera"]["live_dot"].alpha = 0.0;

		wait(0.5);
		self.ttt.ui["hud"]["self"]["camera"]["live_dot"].alpha = 1.0;
	}
}

OnPlayerCameraDestroyed(cameraEnt)
{
	self endon("ttt_ui_camera_hud_destroyed");

	cameraEnt waittill("destroyed");

	self thread restartCameraHud(cameraEnt);
}

restartCameraHud(cameraEnt)
{
	self destroyCameraHud();
	self displayCameraHud(cameraEnt);
}

destroyCameraHud(cameraEnt)
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["camera"]);
	self notify("ttt_ui_camera_hud_destroyed");
}
