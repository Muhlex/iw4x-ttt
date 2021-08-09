#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\ttt\_util;

init()
{
	precacheShader("javelin_overlay_grain");

	feigndeath = spawnStruct();
	feigndeath.name = "FEIGN DEATH";
	feigndeath.description = "^3Offhand Item\n^2Drop a fake body ^7on hit while active\nand gain temporary ^2invisibility^7.\n\nPress [ ^3[{+smoke}]^7 ] to activate & toggle.";
	feigndeath.icon = "cardicon_skull_black";
	feigndeath.onBuy = ::OnBuy;
	feigndeath.onCustomOffhandUse = ::OnCustomOffhandUse;
	feigndeath.getIsAvailable = ::getIsAvailable;
	feigndeath.unavailableHint = &"^1Already bought/carrying offhand ^7[ [{+smoke}] ]^1";
	feigndeath.offhandDisplay = true;

	scripts\ttt\items::registerItem(feigndeath, "traitor");
}

getIsAvailable(item)
{
	return scripts\ttt\items::getIsAvailableOffhand() && scripts\ttt\items::getIsAvailablePassive(item);
}

OnBuy(item)
{
	data = spawnStruct();
	data.active = false;
	data.used = false;
	self scripts\ttt\items::giveCustomOffhand(item, data);
	self thread OnCustomOffhandDisplayCreate(item, data);
}

OnCustomOffhandUse(item, data)
{
	if (data.used)
	{
		self thread endInvisibility();
		return;
	}

	if (!data.active)
	{
		self thread OnReceiveDamage(data);
		self addDamageMultiplier("feigndeath", 0.35, undefined, "in");
		self playLocalSound("counter_uav_deactivate");
	}
	else
	{
		self notify("ttt_items_feigndeath_deactivate");
		self removeDamageMultiplier("feigndeath");
		self playLocalSound("counter_uav_activate");
	}

	data.active = !data.active;
	self updateActiveDisplay(data);
}

OnReceiveDamage(data)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_items_feigndeath_deactivate");

	for (;;)
	{
		self waittill("player_damage", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

		if (!isAlive(self)) return;
		if (iDamage < 1) continue;

		self notify("ttt_fake_death");
		self thread fakeDeath(eInflictor, eAttacker, sMeansOfDeath, sWeapon, sHitLoc, vDir);
		data.used = true;
		break;
	}
}

fakeDeath(eInflictor, eAttacker, sMeansOfDeath, sWeapon, sHitLoc, vDir)
{
	deathAnim = true;
	deathAnimDuration = self playerForceDeathAnim(eInflictor, sMeansOfDeath, sWeapon, sHitLoc, vDir);
	if (!isDefined(deathAnimDuration))
	{
		deathAnim = false;
		deathAnimDuration = 1;
	}

	self.body = self clonePlayer(deathAnimDuration);

	if (!deathAnim || self isOnLadder() || self isMantling() || !self isOnGround() || isDefined(self.nuked))
	{
		self.body startRagDoll();
		self notify("start_ragdoll");
	}

	self thread maps\mp\gametypes\_damage::delayStartRagdoll(self.body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath);

	eAttacker SetCardDisplaySlot(self, 8);
	eAttacker openMenu("youkilled_card_display");

	self scripts\ttt\pickups::deathDropWeapons(true);

	self hide();
	self _disableWeapon();
	self _disableOffhandWeapons();
	self.ttt.attackerHitFeedback = false;

	self playLocalSound("item_nightvision_on");
	self destroyActiveDisplay();
	self thread displayInvisHud(level.ttt.feignDeathInvisTime);

	/**
		* playerForceDeathAnim seems to be the only way to influence player animations in GSC.
		* Unfortunately it also needs to be called on the original player (not the clone) and
		* results in the original player to stay in the last frame of the deathanim until it
		* would be done playing. Thus here a consistent and short death animation is forced to
		* minify the time the player is in this buggy state. (Yes this is insanely scuffed.)
		* Remove the hiding of the player to see the effect.
		*/
	self playerForceDeathAnim(self, "MOD_EXPLOSIVE", "", "head", (0, 0, 0));

	self thread OnInvisibilityTimerEnd();
}

OnInvisibilityTimerEnd()
{
	self endon("ttt_items_feigndeath_invis_end");

	wait(level.ttt.feignDeathInvisTime);

	self thread endInvisibility();
}

endInvisibility()
{
	self notify("ttt_items_feigndeath_invis_end");

	self show();
	self removeDamageMultiplier("feigndeath");
	self.ttt.attackerHitFeedback = true;

	self scripts\ttt\ui::setupHeadIconAnchor();
	self scripts\ttt\ui::updateAllHeadIcons();

	playFX(level.ttt.effects.playerAppear, self getTagOrigin("j_spine4"));
	// self playSound("tactical_spawn");
	self playSound("tactical_insert_flare_ignite_npc");
	self playLocalSound("item_nightvision_off");
	self fadeDestroyInvisHud();

	self scripts\ttt\items::resetCustomOffhand();

	wait(1.0);

	self _enableOffhandWeapons();
	self _enableWeapon();
}

OnCustomOffhandDisplayCreate(item, data)
{
	self endon("disconnect");
	self endon("death");
	self endon("ttt_fake_death");

	for (;;)
	{
		self waittill("ttt_ui_custom_offhand_display_created");

		activeInfo = self createFontString("objective", 1.5);
		activeInfo.label = &"FEIGN DEATH ACTIVE";
		activeInfo.glowAlpha = 1;
		activeInfo.glowColor = (0.1, 0.25, 0.8);
		activeInfo setPoint("BOTTOM CENTER", "BOTTOM CENTER", 0, -92);

		self.ttt.ui["hud"]["self"]["offhand"]["active_info"] = activeInfo;
		self updateActiveDisplay(data);
	}
}

updateActiveDisplay(data)
{
	activeInfo = self.ttt.ui["hud"]["self"]["offhand"]["active_info"];
	activeInfo.alpha = data.active && !data.used;
}

destroyActiveDisplay()
{
	if (isDefined(self.ttt.ui["hud"]["self"]["offhand"]["active_info"]))
		self.ttt.ui["hud"]["self"]["offhand"]["active_info"] destroy();
}

displayInvisHud(invisTime)
{
	grain = newClientHudElem(self);
	grain.horzAlign = "fullscreen";
	grain.vertAlign = "fullscreen";
	grain setShader("javelin_overlay_grain", 640, 480);
	grain.sort = 1;
	grain.alpha = 1.0;
	self.ttt.ui["hud"]["self"]["feigndeath"]["grain"] = grain;

	vignette = newClientHudElem(self);
	vignette.horzAlign = "fullscreen";
	vignette.vertAlign = "fullscreen";
	vignette setShader("combathigh_overlay", 640, 480);
	vignette.sort = 2;
	vignette.color = (0.15, 0.3, 1.0);
	vignette.alpha = 1.0;
	self.ttt.ui["hud"]["self"]["feigndeath"]["vignette"] = vignette;

	text = self createFontString("objective", 1.5);
	text.sort = 3;
	text.label = &"INVISIBLE";
	text.glowAlpha = 1;
	text.glowColor = (0.1, 0.25, 0.8);
	text setPoint("TOP CENTER", "CENTER", 0, 42);
	self.ttt.ui["hud"]["self"]["feigndeath"]["text"] = text;

	bar = self createRectangle(520, 16, (1, 1, 1));
	bar.sort = 3;
	bar setParent(text);
	bar setPoint("TOP CENTER", "BOTTOM CENTER", 0, 12);
	bar scaleOverTime(invisTime - 0.2, 0, bar.height);
	self.ttt.ui["hud"]["self"]["feigndeath"]["bar"] = bar;

	hint = self createFontString("default", 1.2);
	hint.sort = 4;
	hint.label = &"[ ^3[{+smoke}] ^7] to uncloak";
	hint.color = (0.25, 0.25, 0.25);
	hint setParent(bar);
	hint setPoint("CENTER", "CENTER", 0, 0);
	self.ttt.ui["hud"]["self"]["feigndeath"]["hint"] = hint;

	wait(invisTime * 0.75);
	hint fadeOverTime(invisTime * 0.05);
	hint.alpha = 0.0;
}

fadeDestroyInvisHud()
{
	foreach (element in self.ttt.ui["hud"]["self"]["feigndeath"])
	{
		element fadeOverTime(0.5);
		element.alpha = 0.0;
	}

	wait(0.5);
	recursivelyDestroyElements(self.ttt.ui["hud"]["self"]["feigndeath"]);
}
