#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\ttt\_util;

init()
{
	smell = spawnStruct();
	smell.name = "SMELL-O-VISION";
	smell.description = "^3Passive item\n^2Smell ^7where other players were.\nPlayers leave ^2temporary trails^7.";
	smell.icon = "cardicon_hyena";
	smell.iconOffsetX = -2;
	smell.iconOffsetY = -1;
	smell.onBuy = ::OnBuy;
	smell.getIsAvailable = scripts\ttt\items::getIsAvailablePassive;
	smell.unavailableHint = &"^1You can already smell player's traces";
	smell.passiveDisplay = true;
	smell.trailEnts = [];

	scripts\ttt\items::registerItem(smell, "detective");

	level.ttt.effects.smell = loadFX("smoke/smoke_geotrail_fraggrenade");
	// level.ttt.effects.smell = loadFX("custom/smell_trail_red");

	level thread OnPreptimeEnd(smell);
}

OnPreptimeEnd(item)
{
	level endon("game_ended");

	level waittill("ttt_preptime_end");

	INTERVAL = 0.8;

	for (;;)
	{
		itemOwners = getItemOwningPlayers(item);
		foreach (player in level.players)
		{
			playerPos = player getTagOrigin("tag_stowed_hip_rear");

			if (item.trailEnts[player.guid].size < 16 && isAlive(player)) {
				ent = spawn("script_model", playerPos);
				ent setModel("tag_origin");
				ent hide();
				// One could also use a single custom trail effect and just parent that to the player:
				// ent linkTo(player, "tag_stowed_hip_rear");

				foreach (owner in itemOwners)
					if (player.guid != owner.guid)
						ent showToPlayer(owner);

				ent thread restartSmellFX();

				item.trailEnts[player.guid][item.trailEnts[player.guid].size] = ent;
			}

			ents = item.trailEnts[player.guid];

			foreach (i, ent in ents)
			{
				if (i == 0)
				{
					if (isAlive(player)) ent moveTo(playerPos, INTERVAL);
					else
					{
						item.trailEnts[player.guid] = array_remove(ents, ent);
						stopFXOnTag(level.ttt.effects.smell, ent, "tag_origin");
						ent delete();
					}
				}
				else ent moveTo(ents[i - 1].origin, INTERVAL);
			}
		}

		wait(INTERVAL);
	}
}

OnBuy(item)
{
	self endon("disconnect");
	self endon("death");

	self updateSmellVisibility(item);

	self thread OnSmellInterrupt(item);
}

OnSmellInterrupt(item)
{
	self waittill_any("disconnect", "death");

	self updateSmellVisibility(item);
}

updateSmellVisibility(item)
{
	itemOwners = getItemOwningPlayers(item);
	foreach (guid, playerTrailEnts in item.trailEnts)
	{
		foreach (ent in playerTrailEnts)
		{
			ent hide();

			foreach (owner in itemOwners)
				if (guid != owner.guid)
					ent showToPlayer(owner);

			ent thread restartSmellFX();
		}
	}
}

getItemOwningPlayers(item)
{
	result = [];
	foreach (p in getLivingPlayers())
		if (isInArray(p.ttt.items.boughtItems, item))
			result[result.size] = p;

	return result;
}

restartSmellFX()
{
	wait(0.25);

	stopFXOnTag(level.ttt.effects.smell, self, "tag_origin");
	playFXOnTag(level.ttt.effects.smell, self, "tag_origin");
}
