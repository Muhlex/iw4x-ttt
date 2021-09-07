init()
{
	w = [];
	w[0][0] = "famas_mp";
	w[0][1] = "scar_mp";
	w[0][2] = "fal_mp";
	w[0][3] = "tavor_mp";
	w[0][4] = "masada_mp";
	w[0][5] = "ump45_mp";
	w[0][6] = "aug_mp";

	w[1][0] = "m4_mp";
	w[1][1] = "ak47_mp";
	w[1][2] = "mp5k_mp";
	w[1][3] = "p90_mp";
	w[1][4] = "uzi_mp";
	w[1][5] = "kriss_mp";
	w[1][6] = "rpd_mp";
	w[1][7] = "m1014_mp";
	w[1][8] = "beretta393_reflex_mp";
	w[1][9] = "glock_mp";

	w[2][0] = "fn2000_mp";
	w[2][1] = "mg4_mp";
	w[2][2] = "m40a3_mp";
	w[2][3] = "m40a3_mp"; // generate more sniper rifles as this is the only one in the pool
	w[2][4] = "usp_mp";
	w[2][5] = "deserteagle_mp";
	w[2][6] = "coltanaconda_mp";
	w[2][7] = "pp2000_mp";
	w[2][8] = "tmp_mp";
	w[2][9] = "model1887_mp";
	if (level.ttt.modEnabled)
		w[2][9] = "winchester1200_mp";

	level.ttt.tieredWeapons = w;
}
