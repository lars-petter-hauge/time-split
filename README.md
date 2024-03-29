# Time Split

Time split is a factorio mod that provides an overlay during gameplay that shows time progress for specific events. It can show difference between a previous run an hence the player can get a feeling if they are improving their time.

There are multiple achievements in factorio which are unlocked if the player manages to beat the game within a time limit. Although it is possible to lock an achivement to the user interface, this mod is intended to provide a more detailed view of the progress at sub events as well (e.g, when the user unlocks some technology).

![ScreenShot](doc/images/screenshot.png)

The overlay, shown in the upper left corner in the screenshot, shows a list of events.

![ScreenShot](doc/images/screenshot_cropped.png)

For each event the time as given in the settings is listed on the left column of time stamps, whereas the timestamp for current save game is listed in the right column. The player can edit time splits in the mod settings (default to 12:00:00). The time difference is given after the name of each event and is color labeled to indicate if it is lower (green) or higher (red).

![ScreenShot-collapsed](doc/images/screenshot_cropped_collapsed.png)

Clicking the arrow up collapses the list to only show the final goal together with current segment that the player is within.

**Please note though that enabling mods (this one included) disables achievements on Steam, and the particular time achievements are also disabled locally if any mod is included.** Using this mod is more intended during practice, or if the player has already earned the achievements and simply wants to improve.

## The internals

There is a specific set of events that the mod will split times on. This list could be expanded, as long as it is possible to detect the changes through the factorio API. Currently it is based only on when each techonology is unlocked.

The mod is implemented using the provided factorio API. Factorio is implemented with a specific number of updates per second (UPS), which is constrained to 60. This mod assumes that the computer running the mod is able to run at 60 UPS. This might not be the case, especially for very large game saves, but it should work perfectly fine in most circumstances. Please also note that during single player, the updates per second is paused when selecting technology, and hence this mod will also ignore time when the player selects technology.

## What this mod doesn't do

It does not try to compete with the much more developed [LiveSplit](https://livesplit.org/). LiveSplit is a software used by speedrunners and is also compatible with factorio. It is not a factorio mod, hence does not disable achievement. It will be more accurate for time splits as it is not based on in game UPS. It is also by far much more configurable.

## Contribute

Feel free to create issues and/or submit pull requests. All tests are required to pass, but there are only unit tests added. Unfortunately it is not possible to add integration tests in the CI pipeline and any testing within the game must be done manually.

## Tests

The testing framework is based on [busted](https://olivinelabs.com/busted). If you want to run the tests locally, please install as described on their pages and run with:

```bash
busted . --pattern test_
```

## Local deploy

A convenience script `deploy.py` is made for developers to install the mod locally. The script will package the files as factorio expects them and copy to the given folder. Typically the steam folder is located in `C:\Users\user name\AppData\Roaming\Factorio\mods`. Run the deploy with:

```bash
python deploy.py --p time-split -t C:\Users\user name\AppData\Roaming\Factorio\mods
```

Otherwise please refer to `deploy.py -h` for more information.

## Attributes

<a href="https://www.flaticon.com/free-icons/short-term" title="short term icons">Short term icons created by Anggara - Flaticon</a>

<a href="https://www.flaticon.com/free-icons/sort-ascending" title="sort ascending icons">Sort ascending icons created by Bharat Icons - Flaticon</a>