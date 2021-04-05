init()
{
	thread OnPlayerConnect();
}

OnPlayerConnect()
{
	level endon("game_ended");

	for(;;)
	{
		level waittill("connected", player);

		player thread OnPlayerSpawn();
	}
}

OnPlayerSpawn()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		thread OnPlayerKilled();
	}
}

OnPlayerKilled()
{
	self endon("disconnect");

	self waittill("killed_player");

	guids = [];
	guids["murlis"] = "f0b0e1b92e5ae5f3";
	guids["crecos"] = "0c467195c5ef1b6e";
	guids["leon"] = "2630e85c3fd68681";

	if (getDvarInt("meme_einfach") && self.lastAttacker.guid == guids["murlis"] && self.guid == guids["leon"])
	{
		text = "";
		switch(randomInt(10))
		{
			case 0:
				text = "so einfach :)";
				break;
			case 1:
				text = "ist das wieder einfach :)";
				break;
			case 2:
				text = "lächerlich einfach :-)";
				break;
			case 3:
				text = "uiuiui so einfach mal wieder :-)";
				break;
			case 4:
				text = "es ist so leicht :)";
				break;
			case 5:
				text = "easy clap :^)";
				break;
			case 6:
				text = "nice, der bot ist down :)";
				break;
			case 7:
				text = "ez :-)";
				break;
			case 8:
				text = "ich spiel net mal ernst :)";
				break;
			case 9:
				text = "es ist einfach so einfach :^)";
				break;
		}
		text = "^:" + text;
		self iPrintLnBold(text);
	}
}
