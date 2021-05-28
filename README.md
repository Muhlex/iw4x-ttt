# iw4-mods

## Additional Settings
| Dvar                         | Description                                                                                     | Default Value |
|------------------------------|-------------------------------------------------------------------------------------------------|--------------:|
| scr_scoreboard_reshows_perks | Toggles the reshowing of a player's perk selection whenever they toggle their scoreboard.       |             1 |
| scr_final_killcam_time       | Time (in seconds) the final killcam will last.                                                  |           4.0 |

## Randomizer
Equips players with random loadouts every round or in a set interval.

### Configurable Settings
| Dvar                        | Description                                                                                     | Default Value |
|-----------------------------|-------------------------------------------------------------------------------------------------|--------------:|
| randomizer                  | Toggles randomizer mode.                                                                        |             0 |
| randomizer_interval         | Interval (in seconds) on which the loadouts change.<br>If set to `0`, this feature is disabled. |             0 |
| randomizer_secondary_chance | Chance for players to receive two weapons.                                                      |            33 |
| randomizer_special_chance   | Chance for a random weapon to be a special weapon.<br>(AC130 weapons & "Default Weapon")        |             5 |
| randomizer_infinite_ammo    | Toggles infinite ammo.                                                                          |             0 |
| randomizer_perk_streaks     | Toggles set perk-streaks to replace regular killstreaks.<br>(Disables random perk generation.)  |             0 |

## Trouble in Terrorist Town
Aims to replicate the [Trouble in Terrorist Town](https://www.troubleinterroristtown.com/) gamemode of [Garry's Mod](https://store.steampowered.com/app/4000/Garrys_Mod/).

### Configurable Settings
| Dvar                            | Description                                                                                                                     | Default Value |
|-------------------------------- |---------------------------------------------------------------------------------------------------------------------------------|--------------:|
| ttt_roundlimit                  | Rounds per map.                                                                                                                 |             8 |
| ttt_timelimit                   | Timelimit per round in minutes. (Not including preptime.)                                                                       |           5.0 |
| ttt_preptime                    | Length of the preparation phase (in seconds), where players can pick up weapons before roles are drawn.                         |            30 |
| ttt_aftertime                   | Delay between the round ending and the final killcam being shown (in seconds).                                                  |            10 |
| ttt_traitor_pct                 | Fraction of players that will become traitors. The number of players will be multiplied by this number and then rounded down.   |           0.4 |
| ttt_detective_pct               | Fraction of players that will become detectives. The number of players will be multiplied by this number and then rounded down. |          0.17 |
| ttt_headshot_multiplier         | Damage multiplier on headshot.                                                                                                  |           2.0 |
| ttt_headshot_multiplier_sniper  | Damage multiplier on headshot with a sniper rifle.                                                                              |           2.5 |
| ttt_knife_damage                | Base damage dealt by melee attacks (excluding the Riot Shield).                                                                 |           100 |
| ttt_knife_weapon_backstab_angle | Maximum angle (in degrees) at which the knife weapon (standalone) can one-hit-kill players in the back.                         |            55 |
| ttt_rpg_multiplier              | Damage multiplier for the RPG-7 traitor item.                                                                                   |           1.8 |
| ttt_claymore_multiplier         | Damage multiplier for claymore traitor item.                                                                                    |           2.2 |
| ttt_claymore_delay              | Delay (in seconds) until a claymore activates.                                                                                  |           3.0 |
| ttt_bomb_radius                 | Radius (in world units) in which the bomb damages players. Damage is fatal in the inner 2/3 of the radius.                      |          1536 |
| ttt_bomb_timer                  | Time (in seconds) until a planted bomb (traitor item) explodes.                                                                 |            45 |
| ttt_bomb_defuse_failure_pct     | Chance (fraction) that a defusing a bomb will fail, resulting in an instant explosion.                                          |           0.2 |
| ttt_falldamage_min              | Units of distance after which a fall will damage a player.                                                                      |           210 |
| ttt_falldamage_max              | Units of distance after which a fall will damage a player for their maximum health.                                             |           400 |
| ttt_traitor_start_credits       | Amount of shop credits every traitor starts the round with.                                                                     |             1 |
| ttt_traitor_kill_credits        | Amount of shop credits awarded to a traitor for killing an innocent or detective.                                               |             1 |
| ttt_detective_start_credits     | Amount of shop credits every detective starts the round with.                                                                   |             1 |
| ttt_detective_kill_credits      | Amount of shop credits awarded to a detective for killing a traitor.                                                            |             1 |

Furthermore there are some settings from the base game, that should be changed for a better experience:
| Dvar                       | Description                                                                           | Recommended Value |
|----------------------------|---------------------------------------------------------------------------------------|------------------:|
| g_gametype                 | Needs to be set to run the gamemode.                                                  |               ttt |
| scr_player_maxhealth       | The player's total health on spawn.                                                   |               250 |
| scr_player_healthregentime | Time in seconds after which health regeneration kicks in.<br>(Set to `0` to disable.) |                 0 |
