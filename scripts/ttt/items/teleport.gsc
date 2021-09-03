#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\ttt\_util;

init()
{
	teleport = spawnStruct();
	teleport.name = "PLAYER-SWAP TELEPORT";
	teleport.description = "^3Offhand Item\n^2Swap places ^7with a random player.\n\nPress [ ^3[{+smoke}]^7 ] to teleport.";
	teleport.icon = "cardicon_abduction";
	teleport.onBuy = ::OnBuy;
	teleport.onCustomOffhandUse = ::OnCustomOffhandUse;
	teleport.getIsAvailable = scripts\ttt\items::getIsAvailableOffhand;
	teleport.unavailableHint = scripts\ttt\items::getUnavailableHint("offhand");
	teleport.offhandDisplay = true;

	scripts\ttt\items::registerItem(teleport, "traitor");
}

OnBuy(item)
{
	self scripts\ttt\items::giveCustomOffhand(item);
}

OnCustomOffhandUse(item)
{
	DURATION = 3.0;

	availableTargets = array_remove(getLivingPlayers(), self);
	foreach (target in availableTargets)
	{
		if (target.ttt.isTeleporting)
			availableTargets = array_remove(availableTargets, target);
	}

	if (self.ttt.isTeleporting)
	{
		self thread displayErrorHud(&"ALREADY TELEPORTING");
		return;
	}
	if (availableTargets.size < 1)
	{
		self thread displayErrorHud(&"NO TARGETS AVAILABLE");
		return;
	}
	if (self isOnLadder() || self isMantling() || !self isOnGround())
	{
		self thread displayErrorHud(&"TELEPORT ONLY ON SOLID GROUND");
		return;
	}

	target = availableTargets[randomInt(availableTargets.size)];

	self.ttt.isTeleporting = true;
	target.ttt.isTeleporting = true;

	self scripts\ttt\items::resetCustomOffhand();

	self freezePlayer();
	self thread displayTeleportHud(DURATION);
	target thread displayTeleportHud(DURATION);

	wait(DURATION / 2);

	oldSelfStance = self getStance();
	oldSelfOrigin = self.origin;
	oldSelfAngles = self getPlayerAngles();

	self unfreezePlayer();

	self setStance(target getStance());
	self setOrigin(target.origin);
	self setPlayerAngles(target getPlayerAngles());
	target setStance(oldSelfStance);
	target setOrigin(oldSelfOrigin);
	target setPlayerAngles(oldSelfAngles);

	self freezePlayer();
	target freezePlayer();

	playFX(level.ttt.effects.playerAppear, self getTagOrigin("j_spine4"));
	playFX(level.ttt.effects.playerAppear, target getTagOrigin("j_spine4"));
	self playLocalSound("tactical_insert_flare_ignite_plr");
	self playSound("tactical_insert_flare_ignite_npc");
	target playLocalSound("tactical_insert_flare_ignite_plr");
	target playSound("tactical_insert_flare_ignite_npc");

	wait(DURATION / 4);

	self unfreezePlayer();
	target unfreezePlayer();

	self.ttt.isTeleporting = false;
	target.ttt.isTeleporting = false;
}

displayErrorHud(message)
{
	if (self.ttt.items.inBuyMenu) return;

	self playLocalSound("counter_uav_deactivate");

	if (isDefined(self.ttt.ui["hud"]["self"]["offhand"]["teleport"]["error"]))
		self.ttt.ui["hud"]["self"]["offhand"]["teleport"]["error"] destroy();

	error = self createFontString("objective", 1.5);
	error.sort = 3;
	error.label = message;
	error.glowAlpha = 1;
	error.glowColor = (0.8, 0.1, 0.2);
	error setPoint("BOTTOM CENTER", "BOTTOM CENTER", 0, -92);
	self.ttt.ui["hud"]["self"]["offhand"]["teleport"]["error"] = error;
	wait(1.5);

	error fadeOverTime(0.5);
	error.alpha = 0.0;
	wait(0.5);

	error destroy();
}

displayTeleportHud(duration)
{
	white = newClientHudElem(self);
	white.horzAlign = "fullscreen";
	white.vertAlign = "fullscreen";
	white setShader("white", 640, 480);
	white.sort = 1;
	white.alpha = 0.0;
	white.targetAlpha = 1.0;
	self.ttt.ui["hud"]["self"]["teleport"]["white"] = white;

	black = newClientHudElem(self);
	black.horzAlign = "fullscreen";
	black.vertAlign = "fullscreen";
	black setShader("black", 640, 480);
	black.sort = 2;
	black.alpha = 0.0;
	black.targetAlpha = 0.35;
	self.ttt.ui["hud"]["self"]["teleport"]["black"] = black;

	grain = newClientHudElem(self);
	grain.horzAlign = "fullscreen";
	grain.vertAlign = "fullscreen";
	grain setShader("javelin_overlay_grain", 640, 480);
	grain.sort = 3;
	grain.alpha = 0.0;
	grain.targetAlpha = 1.0;
	self.ttt.ui["hud"]["self"]["teleport"]["grain"] = grain;

	vignette = newClientHudElem(self);
	vignette.horzAlign = "fullscreen";
	vignette.vertAlign = "fullscreen";
	vignette setShader("combathigh_overlay", 640, 480);
	vignette.sort = 4;
	vignette.color = (0.65, 0.2, 0.1);
	vignette.alpha = 0.0;
	vignette.targetAlpha = 0.8;
	self.ttt.ui["hud"]["self"]["teleport"]["vignette"] = vignette;

	foreach (el in self.ttt.ui["hud"]["self"]["teleport"])
	{
		el fadeOverTime(duration / 4);
		el.alpha = el.targetAlpha;
	}

	wait(duration / 4);
	wait(duration / 2);

	foreach (el in self.ttt.ui["hud"]["self"]["teleport"])
	{
		el fadeOverTime(duration / 4);
		el.alpha = 0.0;
	}

	wait(duration / 4);

	self destroyTeleportHud();
}

destroyTeleportHud()
{
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["teleport"]);
}
