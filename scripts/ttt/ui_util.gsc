#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

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
	rect setShader("progress_bar_fill", w, int(h * 4 / 3));
	rect.color = color;
	rect.alpha = 1.0;
	rect.children = [];
	rect setParent(level.uiParent);
	rect.hidden = false;

	return rect;
}

setDimensions(w, h)
{
	if (isDefined(w)) self.width = w;
	if (isDefined(h)) self.height = h;
	self setShader("progress_bar_fill", self.width, int(self.height * 4 / 3));
	self maps\mp\gametypes\_hud_util::updateChildren();
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

recursivelyDestroyElements(array)
{
	foreach(element in array)
	{
		if (isArray(element)) recursivelyDestroyElements(element);
		else element destroy();
	}
}

isArray(array)
{
	return isDefined(getArrayKeys(array));
}
