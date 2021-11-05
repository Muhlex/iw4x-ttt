init()
{
	if (level.ttt.modEnabled)
	{
		precacheItem("winchester1200_mp");
	}

	w = [];
	w[0][0] = "tavor_mp";
	w[0][1] = "fal_mp";
	w[0][2] = "masada_mp";
	w[0][3] = "mp5k_mp";
	w[0][4] = "ump45_mp";
	w[0][5] = "aug_mp";

	w[1][0] = "m4_mp";
	w[1][1] = "famas_mp";
	w[1][2] = "scar_mp";
	w[1][3] = "ak47_mp";
	w[1][4] = "p90_mp";
	w[1][5] = "uzi_mp";
	w[1][6] = "rpd_mp";
	w[1][7] = "m1014_mp";
	w[1][8] = "glock_mp";

	w[2][0] = "fn2000_mp";
	w[2][1] = "m240_mp";
	w[2][2] = "m40a3_mp";
	w[2][3] = "m40a3_mp"; // generate more sniper rifles as this is the only one in the pool
	w[2][4] = "usp_mp";
	w[2][5] = "deserteagle_mp";
	w[2][6] = "coltanaconda_mp";
	w[2][7] = "pp2000_mp";
	w[2][8] = "tmp_mp";
	if (level.ttt.modEnabled)
		w[2][9] = "winchester1200_mp";
	else
		w[2][9] = "model1887_mp";

	level.ttt.tieredWeapons = w;
}
