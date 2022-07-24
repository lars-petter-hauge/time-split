# Time Split

Time split is a factorio mod that provides an overlay during gameplay that shows time progress for specific events. It can show difference between a previous run an hence the player can get a feeling if they are improving their time.

There are multiple achievements in factorio which are unlocked if the player manages to beat the game within a time limit. Although it is possible to lock an achivement to the user interface, this mod is intended to provide a more detailed view of the progress at sub events as well (e.g, when the user unlocks some technology).

**Please note though that enabling mods (this one included) disables achievements on Steam, and the particular time achievements are also disabled locally if any mod is included.** Using this mod is more intended during practice, or if the player has already earned the achievements and simply wants to improve.

## How does it work

The player can edit time splits in the mod settings (default to 12:00:00). The overlay will show the progress of the current save relative to the previous time splits. The difference is highlighted and color coded. It is also possible to collapse the overview to only show current segment and the final goal.


## The internals

There is a specific set of events that the mod will split times on. This list could be expanded, as long as it is possible to detect the changes through the factorio API. Currently it is based only on when each techonology is unlocked.

The mod is implemented using the provided factorio API. Factorio is implemented with a specific number of updates per second (UPS), which is constrained to 60. This mod assumes that the computer running the mod is able to run at 60 UPS. This might not be the case, especially for very large game saves, but it should work perfectly fine in most circumstances. Please also note that during single player, the updates per second is paused when selecting technology, and hence this mod will also ignore time when the player selects technology.

## What this mod doesn't do

It does not try to compete with the much more developed LiveSplit. LiveSplit is a software used by speedrunners and is also compatible with factorio. It is not a factorio mod, hence does not disable achievement. It will be more accurate for time splits as it is not based on in game UPS. It is also by far much more configurable.
