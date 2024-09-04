# How to use the settings menu

The settings menu was made to be more or less drop in and forget, therefore there is not that much you have to do if you only wish to use the basic settings.

## Adding the settings menu to your game

Firstly, you want to make an instance of the `settings.tscn` scene, which can be found in `scenes` folder.

When clicking on the newly added `Settings` scene, you will have to fill two exported variables.

- The first one being `Is In Game Menu`, this decides if the settings menu is part of a menu that can be accessed during gameplay or a menu on a title scene. 
- The second one is `Menu Panel`, this is a reference to the node that the menu elements are contained in. *This reference is used to show the menu again after exiting the settings menu.*

There is also one optional variable which is the `Ignored Sections`. This is an array of the names of the sections you do not want shown in the current instance of the settings menu. For example you may not want the gameplay settings shown in the title scene settings menu.


## Adding/removing settings elements/sections

Since the settings structure is created at runtime, changing what settings you want to include in your settings menu can be done by simply deleting the instance of the element/section section scene from the scene tree. The same goes for adding elements and or sections where you simply just have to create an instance of either of them and the rest is handled automatically.

Every instance of the settings menu uses the same sections and elements, so if you wish to ignore some sections in a specific instance, you can do so by adding the name of the section to the `Ignored Sections` array as mentioned before.

## Tweaking default settings

Each settings element has a predefined default value for it and **project settings will be overwritten as soon as the settings menu is loaded**, however these changes are not saved to the project settings.

If you decide that you want to tweak the default values it is done on a per settings element basis and is very simple to do.

Depending on the type of element you are changing you will have different values you can change.
- For elements with **drop downs** you will have to enter the name of the option you wish to use as the default option. If the name provided is not a valid option, the first option in the list is selected by default.
- For elements with **sliders** you can set default value, the minimum and maximum values as well as the step value and lastly you can also add an optional suffix as well as if the value should be displayed in a percentage format, i.e., the true value is 0 to 1 but the displayed value is 0 to 100.
- For elements with a **toggle** you can simply set if they are enabled or disabled.

Every element will also have two extra options, these being:
- `Identifier`, this is the name if the element and this is used as the identifier for the element.
- `Is in game setting`, which determines if the setting changes anything inside of the game world rather than just project wide settings. Elements with this option set to true will only have their settings applied when a settings menu instance with `Is in game menu` is set to true is loaded.

There may also be some extra options for certain elements like for keybinds you have a list where you input the name of the actions you wish to remap and the name that should be shown or for audio settings you have can change which audio bus it is responsible for.

*For input settings, you may want to directly edit the `Action List` variable inside of the element's script as the entries will be sorted alphabetically if they are added via the editor.*

## How to set up in game settings

The application of in game setting is the least modular part of settings menu as it highly depends on the existing game's structure. However, I have included example scripts for the included in game settings which can be used if you do not wish to make your own script.

If you decided to **use the example scripts** it is very easy to add it to your game. Firstly, the scripts can be found in the `scripts/settings-handler-scripts` folder. To actually add them to your game scene, you want to first create a `Node` object and attach one of the settings handler scripts to it. Lastly you simply have to add the reference to the appropriate object by clicking on the newly created `Node` object and assigning the exported variable a value.

If you decided to **make your own script**, how you handle the application of the provided values is up to you, however you have to connect the `applied_in_game_setting` signal from the `SettingsDataManager`. This is the signal that is called by the individual elements which are flagged as in game settings so that their values can be applied to the actual game objects they are handling.

Connecting the signal:
```
func _ready():
    # Connect neccessary signal
    SettingsDataManager.connect("applied_in_game_setting", apply_in_game_settings)
```
The function called by the signal and it's neccessary arguments:
```
# Called to apply in game settings for the specific node
func apply_in_game_settings(section: String, element: String, value) -> void:
    # Your code for handling the application of the values
```