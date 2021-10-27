#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

getLastValidWeapon(getRoleWeapons)
{
	if (!isDefined(getRoleWeapons)) getRoleWeapons = false;

	weaponList = self getWeaponsListPrimaries();
	lastWeaponName = self getLastWeapon();
	if (!isDefined(lastWeaponName) || !self hasWeapon(lastWeaponName) || lastWeaponName == level.ttt.knifeWeapon || (!getRoleWeapons && scripts\ttt\items::isRoleWeapon(lastWeaponName)))
		foreach (weaponName in weaponList)
			if (weaponName != level.ttt.knifeWeapon && (getRoleWeapons || !scripts\ttt\items::isRoleWeapon(weaponName)))
				lastWeaponName = weaponName;
	if (!isDefined(lastWeaponName) || !self hasWeapon(lastWeaponName))
		lastWeaponName = weaponList[0];

	return lastWeaponName;
}

switchToLastWeapon()
{
	self switchToWeapon(self getLastValidWeapon());
}

freezePlayer()
{
	if (!isDefined(self.ttt.freezeCount)) self.ttt.freezeCount = 0;

	if (self.ttt.freezeCount == 0)
	{
		freezeEnt = spawn("script_origin", self.origin);
		freezeEnt hide();
		self playerLinkTo(freezeEnt);
		self.ttt.freezeEnt = freezeEnt;
	}
	self.ttt.freezeCount++;
}

unfreezePlayer()
{
	if (!isDefined(self.ttt.freezeCount)) self.ttt.freezeCount = 0;

	self.ttt.freezeCount = int(max(0, self.ttt.freezeCount - 1));

	if (self.ttt.freezeCount > 0) return;

	self unlink();
	self.freezeEnt delete();
}

setPlayerModel(model) // model can either be a string or a function callback
{
	self detach(self.headModel, "");
	self.headModel = undefined;
	self maps\mp\gametypes\_weapons::detach_all_weapons();

	if (isString(model))
		self setModel(model);
	else
		self [[model]]();

	self maps\mp\gametypes\_weapons::stowedWeaponsRefresh();
}

playSoundDelayed(sound, delay)
{
	wait(delay);
	self playSound(sound);
}

playFXDelayed(fx, pos, delay)
{
	wait(delay);
	playFX(fx, pos);
}

playFxOnTagDelayed(fx, ent, tag, delay)
{
	wait(delay);
	playFXOnTag(fx, ent, tag);
}

clientExec(command) // only available with the mod active
{
	self setClientDvar("client_exec", command);
	self openMenu("client_exec");

	if (isDefined(self)) self closeMenu("client_exec");
}

createRectangle(w, h, color, showToAll)
{
	rect = undefined;
	if (!isDefined(showToAll) || showToAll == false) rect = newClientHudElem(self);
	else rect = newHudElem();
	rect.elemType = "rect";
	rect.x = 0;
	rect.y = 0;
	rect.xOffset = 0;
	rect.yOffset = 0;
	rect.width = w;
	rect.height = h;
	rect.baseWidth = w;
	rect.baseHeight = h;
	rect.color = color;
	rect.alpha = 1.0;
	rect.children = [];
	rect setParent(level.uiParent);
	rect.hidden = false;
	rect setShader("white", int(w), int(h));

	return rect;
}

setRectDimensions(w, h)
{
	if (isDefined(w)) self.width = w;
	if (isDefined(h)) self.height = h;
	self setShader("white", int(self.width), int(self.height));
	self maps\mp\gametypes\_hud_util::updateChildren();
}

fontPulseCustom(scale, duration, player)
{
	self notify("fontPulse");
	self endon("fontPulse");
	self endon("death");

	if (isDefined(player))
	{
		player endon("disconnect");
		player endon("joined_team");
		player endon("joined_spectators");
	}

	halfDuration = duration / 2;
	prevFontScale = self.fontScale;

	self changeFontScaleOverTime(halfDuration);
	self.fontScale = self.fontScale * scale;
	wait(halfDuration);

	self changeFontScaleOverTime(halfDuration);
	self.fontScale = prevFontScale;
}

removeColorsFromString(str)
{
	parts = strTok(str, "^");
	foreach (i, part in parts)
	{
		if (i == 0 && str[0] != "^") continue;

		switch (part[0])
		{
			case "0":
			case "1":
			case "2":
			case "3":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
			case ":":
			case ";":
				parts[i] = getSubStr(part, 1);
		}
	}
	result = "";
	foreach (part in parts) result += part;
	return result;
}

getRoleStringColor(role)
{
	switch (role)
	{
		case "innocent":
			return "^2";
		case "traitor":
			return "^1";
		case "detective":
			return "^5";
	}
}

getWeaponRarity(weaponName)
{
	for (i = 0; i < level.ttt.tieredWeapons.size; i++)
		if (isInArray(level.ttt.tieredWeapons[i], weaponName))
			return (level.ttt.tieredWeapons.size - 1) - i;
	if (scripts\ttt\items::isRoleWeapon(weaponName))
		return 3;
	else
		return 4;
}

getWeaponRarityString(rarity)
{
	return getWeaponRarityStringColor(rarity) + getWeaponRarityStringStars(rarity);
}

getWeaponRarityStringStars(rarity)
{
	result = "[";
	for (i = 0; i <= rarity; i++) result += "¤";
	return result + "]";
}

getWeaponRarityStringColor(rarity)
{
	switch (rarity)
	{
		case 0:
			return "^7";
		case 1:
			return "^2";
		case 2:
			return "^4";
		case 3:
			return "^6";
		case 4:
			return "^;";
	}
}

getWeaponPickupLabel(rarity)
{
	switch (rarity)
	{
		case 0:
			return &"[ ^3[{+activate}] ^7] for ^3&&1 ^7·";
		case 1:
			return &"[ ^3[{+activate}] ^7] for ^3&&1 ^2··";
		case 2:
			return &"[ ^3[{+activate}] ^7] for ^3&&1 ^4···";
		case 3:
			return &"[ ^3[{+activate}] ^7] for ^3&&1 ^6····";
		case 4:
			return &"[ ^3[{+activate}] ^7] for ^3&&1 ^;·····";
	}
}

printToTraitorChat(message, ignorePlayer)
{
	PAD_LEFT = "                                                            ";
	CHARS_PER_LINE = 48;
	words = strTok(message, " ");
	lines = [];

	currentLine = 0;
	lines[0] = PAD_LEFT;

	foreach (i, word in words)
	{
		if (lines[currentLine].size - PAD_LEFT.size + word.size > CHARS_PER_LINE)
		{
			currentLine++;
			lines[currentLine] = PAD_LEFT;
		}

		if (word.size > CHARS_PER_LINE)
		{
			for (j = 0; j < word.size; j += CHARS_PER_LINE)
			{
				if (j > 0)
				{
					currentLine++;
					lines[currentLine] = PAD_LEFT;
				}
				lines[currentLine] += getSubStr(word, j, j + CHARS_PER_LINE);
			}
		}
		else
			lines[currentLine] += word;
		if (i < words.size - 1) lines[currentLine] += " ";
	}

	foreach (recipient in level.players)
	{
		if (!isAlive(recipient))
			continue;
		if (isDefined(recipient.ttt.role) && recipient.ttt.role != "traitor")
			continue;
		if (isDefined(ignorePlayer) && recipient == ignorePlayer)
			continue;

		foreach (line in lines) recipient iPrintLn(line);
		recipient thread playTraitorChatMessageSound();
	}
}

playTraitorChatMessageSound()
{
	for(i = 0; i < 3; i++)
	{
		wait(0.05 * i);
		self playLocalSound("ui_text_type");
		self playLocalSound("ui_text_type");
	}
}

secsToHMS(seconds)
{
	seconds = int(seconds);
	result = [];

	result["s"] = seconds % 60;
	result["m"] = int(seconds / 60) % 60;
	result["h"] = int(seconds / (60 * 60)) % 24;

	return result;
}

recursivelyDestroyElements(array)
{
	foreach (element in array)
	{
		if (isArray(element)) recursivelyDestroyElements(element);
		else
		{
			element destroy();
			element = undefined;
		}
	}
	array = undefined;
}

isArray(array)
{
	return isDefined(getFirstArrayKey(array));
}

isInArray(array, searchValue)
{
	foreach (value in array) if (value == searchValue) return true;
	return false;
}

arraySlice(array, start, end)
{
	result = [];
	for (i = start; i < end; i++)
	{
		if (isDefined(array[i])) result[result.size] = array[i];
	}
	return result;
}

arrayFindIndex(array, element)
{
	foreach (i, el in array)
		if (el == element) return i;

	return -1;
}

fisherYatesShuffle(array)
{
	for (i = array.size - 1; i > 0; i--)
	{
		j = randomInt(i + 1);
		temp = array[i];
		array[i] = array[j];
		array[j] = temp;
	}
	return array;
}

addDamageMultiplier(id, multiplier, mods, type)
{
	if (!isDefined(id)) return;
	if (!isDefined(multiplier)) return;
	if (!isDefined(mods)) mods = [];
	if (!isDefined(type) || type != "out" && type != "in") type = "out";

	config = spawnStruct();
	config.id = id;
	config.multiplier = multiplier;
	if (isArray(mods)) config.mods = mods;
	else
	{
		config.mods = [];
		config.mods[0] = mods;
	}
	config.type = type;

	self.ttt.damageMultipliers[self.ttt.damageMultipliers.size] = config;
}

removeDamageMultiplier(id)
{
	removeConfig = undefined;

	foreach (config in self.ttt.damageMultipliers)
	{
		if (config.id == id)
		{
			removeConfig = config;
			break;
		}
	}

	self.ttt.damageMultipliers = array_remove(self.ttt.damageMultipliers, removeConfig);
}

addSpeedMultiplier(id, multiplier)
{
	if (!isDefined(id)) return;
	if (!isDefined(multiplier)) return;

	config = spawnStruct();
	config.id = id;
	config.multiplier = multiplier;

	self.ttt.speedMultipliers[self.ttt.speedMultipliers.size] = config;
	self updateSpeedMultipliers();
}

removeSpeedMultiplier(id)
{
	removeConfig = undefined;

	foreach (config in self.ttt.speedMultipliers)
	{
		if (config.id == id)
		{
			removeConfig = config;
			break;
		}
	}

	self.ttt.speedMultipliers = array_remove(self.ttt.speedMultipliers, removeConfig);
}

updateSpeedMultipliers()
{
	speedScale = 1.0;

	foreach (config in self.ttt.speedMultipliers)
		speedScale *= config.multiplier;

	self.moveSpeedScaler = speedScale;
	self setMoveSpeedScale(speedScale);
}

drawDebugLine(pos1, pos2, color, ticks)
{
	if (!isDefined(color)) color = (1, 1, 1);
	if (!isDefined(ticks)) ticks = 200;

	for (i = 0; i < ticks; i++)
	{
		line(pos1, pos2, color);
		wait(0.05);
	}
}

drawDebugCircle(pos, radius, color, ticks)
{
	for (i = 0; i < 40; i++)
	{
		angle = i / 40 * 360;
		nextAngle = (i + 1) / 40 * 360;

		linePos = pos + (cos(angle) * radius, sin(angle) * radius, 0);
		nextLinePos = pos + (cos(nextAngle) * radius, sin(nextAngle) * radius, 0);

		thread drawDebugLine(linePos, nextLinePos, color, ticks);
	}
}

printCloseEntities()
{
	/#
	count = 0;
	for (i = 0; i < 8192; i++)
	{
		entity = GetEntByNum(i);
		if (!isDefined(entity)) continue;
		distance = distance(self.origin, entity.origin);
		if (distance > 512) continue;
		classname = entity.classname;
		if (!isDefined(classname)) classname = "undefined";
		targetname = entity.targetname;
		if (!isDefined(targetname)) targetname = "undefined";
		if (!isDefined(distance)) distance = "undefined";
		iPrintLn("CLASS: " + classname + " | TARGET: " + targetname + " | DIST: " + distance);
		count++;
	}
	iPrintLnBold("Found " + count + " entities in 512 units proximity.");
	#/
}

displayExampleRoundsSummary()
{
	exPlayerList = [];
	exPlayerList[0] = "Player 1";
	exPlayerList[1] = "Cool Dude";
	exPlayerList[2] = "Another Player";
	exPlayerList[3] = "Me";
	exPlayerList[4] = "You";
	exPlayerList[5] = "Them";
	exPlayerList[6] = "Someone else";

	exampleData = [];

	for (i = 0; i < 7; i++)
	{
		ex = spawnStruct();
		if (randomInt(2)) ex.winner = "traitor";
		else ex.winner = "innocent";
		ex.endReason = "death";
		ex.ended = true;

		ex.players = [];
		exRandomizedPlayerList = fisherYatesShuffle(exPlayerList);

		foreach (j, playerName in exRandomizedPlayerList)
		{
			ex.players[j]["name"] = playerName;
			if (j < 2) ex.players[j]["role"] = "traitor";
			else if (j < 3) ex.players[j]["role"] = "detective";
			else ex.players[j]["role"] = "innocent";
		}

		exampleData[i] = ex;
	}

	scripts\ttt\ui::displayGameEnd(exampleData);

	wait(30.0);
	scripts\ttt\ui::destroyGameEnd();
}
