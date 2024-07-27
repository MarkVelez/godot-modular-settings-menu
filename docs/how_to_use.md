# How to use the settings menu

The settings menu was made to be more or less drop in and forget, therefore there is not that much you have to do if you only wish to use the basic settings.

## Adding the settings menu to your game

Firstly, you want to make an instance of the `settings.tscn` scene, which can be found in `scenes` folder.

When clicking on the newly added `Settings` scene, you will have to fill two exported variables.

- The first one being `Is In Game Menu`, this decides if the settings menu is part of a menu that can be accessed during gameplay or a menu on a title scene. 
- The second one is `Menu Panel`, this is a reference to the node that the menu elements are contained in. *This reference is used to show the menu again after exiting the settings menu.*

The last thing that has to be done is to emit the `get_settings` signal on the `Settings` node when the user wanted to enter the settings menu.
```
# When the settings button is pressed
func settings_button_pressed():
    # Hide the main menu
    menuRef.hide()
    # Show the settings menu
    settingsRef.show()
    # Emit the get_settings signal on the settings menu
    settingsRef.emit_signal(&"get_settings")
```


## Adding/removing settings elements/sections

Since the settings structure is created at runtime, changing what settings you want to include in your settings menu can be done by simply deleting the instance of the element/section section scene from the scene tree. The same goes for adding elements and or sections where you simply just have to create an instance of either of them and the rest is handled automatically.

The name of the element/section depends on the name of the root node of the element/section scene. This name is used as the name of the element/section inside of the save file. 

However if you wish to give them custom names, you can do that by changing the value of the `identifier` variable:

```
@onready var identifier: StringName = &"Your Custom Name"
```

For **sub elements** however, you want to leave the `parentRef` variable alone, as it is handled by it's parent element.

## Tweaking default settings

Each settings element has a predefined default value for it and **project settings are not used and are be overwritten in game**, however these changes are not saved to the project settings.

If you decide that you want to tweak the default values it is done on a per settings element basis and is very simple to do.

Depending on the type of element you are changing you will have different values you can change.
- For elements with **drop downs** you will have list of options to choose from.
- For elements with **sliders** you can set default value obviously, the minimum and maximum values as well as the step value and last you can also add an optional suffix.
- For elements with a **toggle** you can simply set if the value is true or false.

Every element will also have two extra options, these being:
- `Is in game setting`, which determines if the setting changes anything inside of the game world rather than just project wide settings.
- `Is sub element`, which is used when an element has extra elements under it. An example for this would be the Scaler element.

There may also be some extra options for certain elements like for keybinds you have a list where you input the name of the actions you wish to remap and the name that should be shown or for audio settings you have can change which audio bus it is responsible for.

## How to set up in game settings

The application of in game settings is the least modular part of settings menu as it highly depends on the existing game's structure. However, I have included example scripts for the included in game settings which can be used if you do not wish to make your own script.

If you decided to **use the example scripts** it is very easy to add it to your game. Firstly, the scripts can be found in the `scripts/settings-handler-scripts` folder. To actually add them to your game scene, you want to first create a `Node` object and attach one of the settings handler scripts to it. Lastly you simply have to add the reference to the appropriate object by clicking on the newly created `Node` object and assigning the exported variable a value.

If you decided to **make your own script**, how you handle the application of the provided values is up to you, however you have to connect the `apply_in_game_settings` signal from the `SettingsDataManager`. This is the signal that is called by the individual elements which are flagged as in game settings so that their values can be applied to the actual game objects they are handling.

Connecting the signal:
```
func _ready():
    # Connect neccessary signal
    SettingsDataManager.connect(&"apply_in_game_settings", apply_in_game_settings)
```
The function called by the signal and it's neccessary arguments:
```
# Called to apply in game settings for the specific node
func apply_in_game_settings(section: StringName, element: StringName, _value) -> void:
    # Your code for handling the application of the values
```
The `value` argument is not always used so if the object does not require it at all you can prefix it with an underscore as seen in the example. If the object does use it, then you can either just use `value = null`.