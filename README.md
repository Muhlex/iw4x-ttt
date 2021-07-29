# iw4-mods
A small collection of mods for IW4. Based on IW4X — some things will not work on other game clients.
Due to having to make changes in the core files, these mods are only compatible with one another
and cannot be simply combined with any others that do the same thing. &mdash; Sorry!

## Additional Settings
| Dvar                             | Description                                                                                 | Default Value |
|----------------------------------|---------------------------------------------------------------------------------------------|--------------:|
| scr_scoreboard_reshows_perks     | Toggles the reshowing of a player's perk selection whenever they toggle their scoreboard.   |             0 |
| scr_final_killcam_time           | Time (in seconds) the final killcam will last.                                              |           4.0 |
| scr_sd_always_show_final_killcam | If true, S&D rounds will always try to show the last kill (by any team) as a final killcam. |             0 |
| scr_forced_killstreaks           | Forces player's killstreak rewards. Format: `<kills>,<reward>,`... e.g. `4,uav,8,airdrop`   |            "" |


## [Trouble in Terrorist Town](docs/TTT.md)
Aims to replicate the [Trouble in Terrorist Town](https://www.troubleinterroristtown.com/)
gamemode of [Garry's Mod](https://store.steampowered.com/app/4000/Garrys_Mod/).

### Features
- 3 player roles
- 17 items
- Identifying bodies
- Random weapon spawns
- Custom UI
- (optional) Mod

**For further details and demos [visit the TTT documentation](docs/TTT.md).**


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
