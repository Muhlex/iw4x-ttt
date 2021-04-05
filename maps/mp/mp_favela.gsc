main()
{
	maps\mp\mp_favela_precache::main();

	maps\createart\mp_favela_art::main();
	maps\mp\mp_favela_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_favela" );
	//setExpFog( 270, 11488, 0.8, 0.8, 0.8, 0.1, 0 );

	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 1.5;

	ambientPlay( "ambient_mp_favela" );

	switch ( level.gameType )
	{
		case "oneflag":
			game[ "attackers" ] = "allies";
			game[ "defenders" ] = "axis";
			break;
		default:
			game[ "attackers" ] = "axis";
			game[ "defenders" ] = "allies";
			break;
	}

	setdvar( "r_specularcolorscale", "2.8" );
	setdvar( "compassmaxrange", "1500" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.25 );
	setdvar( "r_lightGridContrast", .45 );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );

		self thread FapDach();
	}
}

FapDach()
{
	self endon( "death" );

	for(;;)
	{
		roofMin = (774, -0.125, 275);
		roofMax = (1135, 491.124, 500);

		if (self.origin[0] >= roofMin[0] && self.origin[0] <= roofMax[0] && self.origin[1] >= roofMin[1] && self.origin[1] <= roofMax[1] && self.origin[2] >= roofMin[2] && self.origin[2] <= roofMax[2])
			self DisableWeapons();
		else
			self EnableWeapons();

		wait 0.2;
	}
}
