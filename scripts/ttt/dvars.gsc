init()
{
	d = [];
	d["ttt_roundlimit"] = 8;
	d["ttt_timelimit"] = 5.0;
	d["ttt_preptime"] = 30;
	d["ttt_aftertime"] = 10;
	d["ttt_summary_timelimit"] = 25;
	d["ttt_summary_rounds_per_view"] = 4;
	d["ttt_summary_time_per_view"] = 10;
	d["ttt_traitor_pct"] = 0.4;
	d["ttt_detective_pct"] = 0.17;
	d["ttt_headshot_multiplier"] = 2.0;
	d["ttt_headshot_multiplier_sniper"] = 2.5;
	d["ttt_knife_damage"] = 100;
	d["ttt_knife_weapon_backstab_angle"] = 50;
	d["ttt_armor_damage_multiplier"] = 0.8;
	d["ttt_speed_item_mutiplier"] = 1.3;
	d["ttt_rpg_multiplier"] = 1.8;
	d["ttt_claymore_multiplier"] = 2.2;
	d["ttt_claymore_delay"] = 3.0;
	d["ttt_bomb_radius"] = 1536;
	d["ttt_bomb_timer"] = 45;
	d["ttt_bomb_defuse_failure_pct"] = 0.2;
	d["ttt_feign_death_invis_time"] = 6.0;
	d["ttt_falldamage_min"] = 210;
	d["ttt_falldamage_max"] = 400;
	d["ttt_traitor_start_credits"] = 1;
	d["ttt_traitor_kill_credits"] = 1;
	d["ttt_detective_start_credits"] = 1;
	d["ttt_detective_kill_credits"] = 1;

	level.ttt.dvars = [];
	foreach (key, value in d)
	{
		setDvarIfUninitialized(key, value);
		level.ttt.dvars[key] = value;
	}
}
