#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\ttt\ui_util;

init()
{
	precacheShader("specialty_copycat");
	precacheShader("cardicon_brit_beret");
	precacheShader("cardtitle_silencer");

	level.ttt.ui = [];
	level.ttt.ui["hud"] = [];

	level.ttt.colors["preparing"] = (0.5, 0.5, 0.5);
	level.ttt.colors["innocent"] = (0.4, 0.75, 0); // exact ^2 color code is (0.52, 0.75, 0)
	level.ttt.colors["detective"] = (0.0, 0.52, 0.64);
	level.ttt.colors["traitor"] = (1.0, 0.19, 0.19);
	level.ttt.colors["self"] = (1.0, 0.8, 0.4);
}

initPlayer()
{
	self.ttt.ui = [];
	self.ttt.ui["hud"] = [];

	self.ttt.ui["hud"]["role"] = self createFontString("hudbig", 0.8);
	self.ttt.ui["hud"]["role"] setPoint("TOP RIGHT", "TOP RIGHT", -20, 10);
	self.ttt.ui["hud"]["role"].color = (1, 1, 1);
	self.ttt.ui["hud"]["role"].glowAlpha = 1;
	self.ttt.ui["hud"]["role"].foreground = false;
	self.ttt.ui["hud"]["role"].hidewheninmenu = true;

	self.ttt.ui["hud"]["health"] = self createFontString("hudbig", 0.8);
	self.ttt.ui["hud"]["health"] setPoint("BOTTOM RIGHT", "BOTTOM RIGHT", -90, -8);
	self.ttt.ui["hud"]["health"].foreground = false;
	self.ttt.ui["hud"]["health"].hidewheninmenu = true;

	for (;;)
	{
		wait(0.05);
		self updatePlayerHealthDisplay();
	}
}

updatePlayerHealthDisplay()
{
	text = "";
	if (isAlive(self))
	{
		text = self.health + "/" + level.ttt.maxhealth; // use cached maxhealth, because disabling health regen messes with the value
		healthPct = self.health / level.ttt.maxhealth;
		healthProxToHalf = (1 - abs(healthPct - 0.5)) * 2;

		self.ttt.ui["hud"]["health"].color = ((1 - healthPct) + healthProxToHalf * 0.5, healthPct + healthProxToHalf * 0.5, 0.5);
		self.ttt.ui["hud"]["health"].glowColor = ((1 - healthPct) * 0.6 + healthProxToHalf * 0.3, healthPct * 0.6 + healthProxToHalf * 0.3, 0.3);
		self.ttt.ui["hud"]["health"].glowAlpha = (1 - healthPct) + 0.25;
	}
	self.ttt.ui["hud"]["health"] setText(text);
}

updatePlayerRoleDisplay(role)
{
	text = "";
	if (!isDefined(role))
	{
		role = "preparing";
		text = "PREPARING";
	}
	else if (role == "innocent") text = "INNOCENT";
	else if (role == "detective") text = "DETECTIVE";
	else if (role == "traitor") text = "TRAITOR";
	self.ttt.ui["hud"]["role"].glowColor = level.ttt.colors[role];
	self.ttt.ui["hud"]["role"] setText(text);
}

setHeadIcons()
{
	for (i = 0; i < level.players.size; i++)
	{
		for (j = 0; j < level.players.size; j++)
		{
			if (level.players[i].guid == level.players[j].guid) continue;

			if (level.players[i].ttt.role == "traitor" && level.players[j].ttt.role == "traitor")
				level.players[i] maps\mp\_entityheadicons::setHeadIcon(level.players[j], game["entity_headicon_allies"], (0, 0, 80), 8, 8, false, false);
			if (level.players[i].ttt.role == "detective")
				level.players[i] maps\mp\_entityheadicons::setHeadIcon(level.players[j], game["entity_headicon_axis"], (0, 0, 80), 8, 8, false, false);
		}
	}
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
	level.ttt.ui["hud"]["outcome"]["bg"].hidewheninmenu = true;
	level.ttt.ui["hud"]["outcome"]["bg"].alpha = 0.35;
	level.ttt.ui["hud"]["outcome"]["bg"].sort = -1;

	level.ttt.ui["hud"]["outcome"]["title"] = createServerFontString("objective", 2.0);
	level.ttt.ui["hud"]["outcome"]["title"] setParent(level.ttt.ui["hud"]["outcome"]["bg"]);
	level.ttt.ui["hud"]["outcome"]["title"] setPoint("TOP CENTER", "TOP CENTER", 0, 28);
	level.ttt.ui["hud"]["outcome"]["title"].glowColor = level.ttt.colors[winner];
	level.ttt.ui["hud"]["outcome"]["title"].glowAlpha = 1.0;
	level.ttt.ui["hud"]["outcome"]["title"].hidewheninmenu = true;
	level.ttt.ui["hud"]["outcome"]["title"] setText(winnerText);

	level.ttt.ui["hud"]["outcome"]["reason"] = createServerFontString("default", 1.5);
	level.ttt.ui["hud"]["outcome"]["reason"] setParent(level.ttt.ui["hud"]["outcome"]["title"]);
	level.ttt.ui["hud"]["outcome"]["reason"] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 10);
	level.ttt.ui["hud"]["outcome"]["reason"].hidewheninmenu = true;
	level.ttt.ui["hud"]["outcome"]["reason"] setText(reasonText);
}

destroyRoundEnd()
{
	recursivelyDestroyElements(level.ttt.ui["hud"]["outcome"]);
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
		else if (!isAlive(player) && (self.ttt.role == "traitor" || level.gameEnded))
			players["missing"][players["missing"].size] = player;
		else
			players["alive"][players["alive"].size] = player;
	}

	vertPadding = 8;
	totalVertPadding = vertPadding * 2; // top and bottom padding

	self.ttt.ui["sb"]["bg"] = self createRectangle(240, 0, (0, 0, 0));
	self.ttt.ui["sb"]["bg"] setPoint("CENTER", "CENTER", 0, 0);
	self.ttt.ui["sb"]["bg"].alpha = 0.65;
	self.ttt.ui["sb"]["bg"].foreground = true; // gets it displayed over the crosshair
	self.ttt.ui["sb"]["bg"].sort = -1;

	self.ttt.ui["sb"]["icon"]["face"] = createIcon("specialty_copycat", 32, 32);
	self.ttt.ui["sb"]["icon"]["face"] setParent(self.ttt.ui["sb"]["bg"]);
	self.ttt.ui["sb"]["icon"]["face"] setPoint("CENTER CENTER", "TOP LEFT", 6, 0);
	self.ttt.ui["sb"]["icon"]["face"].foreground = true;
	self.ttt.ui["sb"]["icon"]["face"].sort = 5;

	self.ttt.ui["sb"]["icon"]["hat"] = createIcon("cardicon_brit_beret", 32, 32);
	self.ttt.ui["sb"]["icon"]["hat"] setParent(self.ttt.ui["sb"]["icon"]["face"]);
	self.ttt.ui["sb"]["icon"]["hat"] setPoint("TOP LEFT", "TOP LEFT", -3, -16);
	self.ttt.ui["sb"]["icon"]["hat"].foreground = true;
	self.ttt.ui["sb"]["icon"]["hat"].sort = 10;

	self.ttt.ui["sb"]["icon"]["pipe"] = createIcon("cardtitle_silencer", 20, 4);
	self.ttt.ui["sb"]["icon"]["pipe"] setParent(self.ttt.ui["sb"]["icon"]["face"]);
	self.ttt.ui["sb"]["icon"]["pipe"] setPoint("TOP LEFT", "TOP LEFT", 16, 20);
	self.ttt.ui["sb"]["icon"]["pipe"].foreground = true;
	self.ttt.ui["sb"]["icon"]["pipe"].sort = 10;

	// ALIVE PLAYERS

	self.ttt.ui["sb"]["headings"]["alive"] = self createFontString("objective", 1.5);
	self.ttt.ui["sb"]["headings"]["alive"] setParent(self.ttt.ui["sb"]["bg"]);
	self.ttt.ui["sb"]["headings"]["alive"] setPoint("TOP CENTER", "TOP CENTER", 0, vertPadding);
	self.ttt.ui["sb"]["headings"]["alive"] setText("TERRORISTS (" + players["alive"].size + ")");

	foreach (i, player in players["alive"])
	{
		self.ttt.ui["sb"]["names"][i] = self createFontString("default", 1.5);
		if (i == 0) self.ttt.ui["sb"]["names"][i] setParent(self.ttt.ui["sb"]["headings"]["alive"]);
		else self.ttt.ui["sb"]["names"][i] setParent(self.ttt.ui["sb"]["names"][i - 1]);
		self.ttt.ui["sb"]["names"][i] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 0);
		if (player.guid == self.guid) self.ttt.ui["sb"]["names"][i].color = level.ttt.colors["self"];
		if (player.ttt.role == "detective" || self.ttt.role == "traitor" || level.gameEnded || !isAlive(self))
		{
			self.ttt.ui["sb"]["names"][i].glowColor = level.ttt.colors[player.ttt.role];
			self.ttt.ui["sb"]["names"][i].glowAlpha = 1.0;
		}
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
		totalVertPadding += vertPadding;
		self.ttt.ui["sb"]["headings"]["missing"] setText("MISSING IN ACTION (" + players["missing"].size + ")");

		foreach (i, player in players["missing"])
		{
			j = i + players["alive"].size;
			self.ttt.ui["sb"]["names"][j] = self createFontString("default", 1.5);
			if (i == 0) self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["headings"]["missing"]);
			else self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["names"][j - 1]);
			self.ttt.ui["sb"]["names"][j] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 0);
			if (player.guid == self.guid) self.ttt.ui["sb"]["names"][j].color = level.ttt.colors["self"];
			if (player.ttt.role == "detective" || self.ttt.role == "traitor" || level.gameEnded || !isAlive(self))
			{
				self.ttt.ui["sb"]["names"][j].glowColor = level.ttt.colors[player.ttt.role];
				self.ttt.ui["sb"]["names"][j].glowAlpha = 1.0;
			}
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
		totalVertPadding += vertPadding;
		self.ttt.ui["sb"]["headings"]["confirmed"] setText("CONFIRMED DEAD (" + players["confirmed"].size + ")");

		foreach (i, player in players["confirmed"])
		{
			j = i + players["alive"].size + players["missing"].size;
			self.ttt.ui["sb"]["names"][j] = self createFontString("default", 1.5);
			if (i == 0) self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["headings"]["confirmed"]);
			else self.ttt.ui["sb"]["names"][j] setParent(self.ttt.ui["sb"]["names"][j - 1]);
			self.ttt.ui["sb"]["names"][j] setPoint("TOP CENTER", "BOTTOM CENTER", 0, 0);
			if (player.guid == self.guid) self.ttt.ui["sb"]["names"][j].color = level.ttt.colors["self"];
			if (player.ttt.role == "detective" || self.ttt.role == "traitor" || level.gameEnded || !isAlive(self))
			{
				self.ttt.ui["sb"]["names"][j].glowColor = level.ttt.colors[player.ttt.role];
				self.ttt.ui["sb"]["names"][j].glowAlpha = 1.0;
			}
			self.ttt.ui["sb"]["names"][j] setText(removeColorsFromString(player.name));
		}
	}

	sbHeight = 0;
	foreach (heading in self.ttt.ui["sb"]["headings"]) sbHeight += heading.height;
	foreach (name in self.ttt.ui["sb"]["names"]) sbHeight += name.height;
	sbHeight += totalVertPadding;
	self.ttt.ui["sb"]["bg"] setDimensions(undefined, int(sbHeight));
}

destroyScoreboard()
{
	recursivelyDestroyElements(self.ttt.ui["sb"]);
}
