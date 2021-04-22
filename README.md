# iw4-mods

## Randomizer
Equips players with random loadouts every round or in a set interval.

### Configurable Settings
| Dvar                        | Description                                                                                       | Default Value |
|-----------------------------|---------------------------------------------------------------------------------------------------|--------------:|
| randomizer                  | Toggles randomizer mode.                                                                          |             0 |
| randomizer_interval         | Interval (in seconds) in which the weapon's change.<br>If set to `0`, this feature is disabled.   |             0 |
| randomizer_secondary_chance | Chance for the player's to receive two weapons.                                                   |            33 |
| randomizer_special_chance   | Chance for that the random weapon will be a special weapon.<br>(AC130 weapons & "Default Weapon") |             5 |
| randomizer_infinite_ammo    | Toggles infinite ammo.                                                                            |             0 |
| randomizer_perk_streaks     | Toggles set perk-streaks to replace regular killstreaks.<br>(Disables random perk generation.)    |             0 |

## Trouble in Terrorist Town
Aims to replicate the [Trouble in Terrorist Town](https://www.troubleinterroristtown.com/) gamemode of Garry's Mod.

### Configurable Settings
| Dvar                           | Description                                                                                                                       | Default Value |
|--------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|--------------:|
| scr_ttt_timelimit              | Timelimit per round in minutes. (Not including preptime.)                                                                         |           5.0 |
| scr_ttt_roundlimit             | Rounds per map.                                                                                                                   |             6 |
| ttt_preptime                   | Length of the preparation phase (in seconds), where player's can pick up weapons before roles are drawn.                          |            30 |
| ttt_aftertime                  | Delay betweeen the round ending and the final killcam being shown (in seconds).                                                   |            10 |
| ttt_traitor_pct                | Percentage of players that will become traitors. The number of players will be multiplied by this number and then rounded down.   |           0.4 |
| ttt_detective_pct              | Percentage of players that will become detectives. The number of players will be multiplied by this number and then rounded down. |          0.17 |
| ttt_headshot_multiplier        | Damage multiplier on headshot.                                                                                                    |           2.0 |
| ttt_headshot_multiplier_sniper | Damage multiplier on headshot with a sniper rifle.                                                                                |           2.5 |
| ttt_explosive_multiplier       | Damage multiplier for explosive weapons.                                                                                          |           1.8 |
| ttt_falldamage_min             | Units of distance after which a fall will damage a player.                                                                        |           210 |
| ttt_falldamage_max             | Units of distance after which a fall will damage a player for their maximum health.                                               |           400 |
| ttt_traitor_start_credits      | Amount of shop credits every traitor starts the round with.                                                                       |             1 |
| ttt_traitor_kill_credits       | Amount of shop credits awarded to a traitor for killing an innocent or detective.                                                 |             1 |
| ttt_detective_start_credits    | Amount of shop credits every detective starts the round with.                                                                     |             1 |
| ttt_detective_kill_credits     | Amount of shop credits awarded to a detective for killing a traitor.                                                              |             1 |
