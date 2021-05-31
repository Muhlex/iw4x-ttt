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
	self unfreezePlayer();

	freezeEnt = spawn("script_origin", self.origin);
	freezeEnt hide();
	self.freezeEnt = freezeEnt;
	self playerLinkTo(freezeEnt);
}

unfreezePlayer()
{
	self unlink();
	self.freezeEnt delete();
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

	rect setShader("progress_bar_fill", w, int(h * 4 / 3));
	rect.shader = "progress_bar_fill";

	return rect;
}

setDimensions(w, h)
{
	if (isDefined(w)) self.width = w;
	if (isDefined(h)) self.height = h;
	self setShader("progress_bar_fill", self.width, int(self.height * 4 / 3));
	self maps\mp\gametypes\_hud_util::updateChildren();
}

fontPulseCustom(player, scale, duration)
{
	self notify("fontPulse");
	self endon("fontPulse");
	self endon("death");

	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");

	halfDuration = duration / 2;
	prevFontScale = self.fontScale;

	self ChangeFontScaleOverTime(halfDuration);
	self.fontScale = self.fontScale * scale;
	wait(halfDuration);

	self ChangeFontScaleOverTime(halfDuration);
	self.fontScale = prevFontScale;
}

removeColorsFromString(str)
{
	parts = strTok(str, "^");
	foreach (i, part in parts)
	{
		switch (getSubStr(part, 0, 1))
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
	result = "";
	switch (role)
	{
		case "innocent":
			result = "^2";
			break;
		case "traitor":
			result = "^1";
			break;
		case "detective":
			result = "^5";
			break;
	}

	return result;
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
	foreach(element in array)
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

intUp(value)
{
	result = int(value);
	if (result == value) return result;
	else return result + 1;
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
