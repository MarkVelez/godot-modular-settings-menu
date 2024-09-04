# Adding custom elements and sections

Since the settings menu is designed to be modular, adding custom settings elements and or sections does not require messing with anything besides what the element actually does or what the section is called.

## Creating an element

I have included **templates for the element types** that were used to make the settings that come with the settings menu. These templates can be found in `scenes/settings-elements/templates`.

The only thing you have to change once you have duplicated a template and moved it to it's corresponding folder, is the `Identifier` of the element and the **text of the label node**.

## Setting up elements

Now that you have the element scene set up, you have to change some things inside of the element's script.

Depending on the type of element you chose to make you will have different things you need to change.

For `option elements`, you will have to initialize the `OPTION_LIST_` variable which holds all the options the option element will have, as well as optionally what each option does. The variable has to be either a `Dictionary` or an `Array[String]`.
```
# Provide the options for the element
func _init() -> void:
	OPTION_LIST_ = {
		"Example": null
	}
```

For `slider elements` and `toggle elements`, there is nothing you have to change besides the `_apply_settings()` function. The same goes for `option elements` as well. This function is called when the settings menu's apply button is pressed as well as when the settings menu is loaded.

## Special elements

There are two more elements that are a bit more complex compared to the basic elements. These being the `button element` and the `multi element`.

The `button element` is less of a settings element, rather it is a way to access an `element panel`. An element panel functionally acts as a settings section, but it is its own panel that is not part of the base settings menu panel. The only thing you have to change on a button element is providing the element panel scene to the exported variable.

A `multi element` again is not exactly a settings element, but rather a "wrapper" for multiple settings elements. The way it works is that there is one `main element` that is displayed in the settings menu. This element can be any of the three basic element types, but inside of the provided template an option element is used. Based on the value of the main element the `sub elements` will be shown according to what is inside of the `_display_sub_elements()` function of the `multi element`. The multi element has two exported variables. These being the `main element` and an array for the `sub elements`. *Both the main and sub elements should be direct children of the multi element however this is not mandatory.*

## Creating an in game setting

If you are making a setting that you want to interract with a game object, you will want to call `apply_in_game_setting(value)` in the `_apply_settings` function of the element. You will then want to connect the `applied_in_game_setting` **signal** to the game object's script or to something that has a reference to the game object and will handle it's settings. How to do the signal part is explained in more detail in [How to Use](how_to_use.md#how-to-set-up-in-game-settings).

## Creating a section

Similar to elements, I have included a template for an empty section, which again can be found in `scenes/settings-elements/templates`.

When adding elements to the section you either want to add them directly inside of the `ElementList` node or if you want to have separate visual groups inside of the section, you want to add them inside the `SubSectionElements` node which is found inside of the `SubSection` node. If you wish you can also rename the `SubSection` node and do not forget to change the text for the label. *These subsections are only visual and do not affect the settings data structure.*

As for adding the section to the settings menu, you want to create an instance of the scene inside of the `settings.tscn` scene inside of the `SettingsTabs` node.

Make sure to change the **name of the root node** as this is what is displayed in the settings menu. You will also have to change the `Identifier` of the section as this is used to identify the section inside of the settings data.

## Creating element panels

As before, I have included a template for an empty element panel at `scenes/settings-elements/templates/element-panel-template`.

Element panels essentially server the same purpose as a settings section, however they are their own panel inside of being part of the existing settings panel that the sections are part of. They also handle applying and saving separately to the settings panel and they also have their own settings cache.

Each `element panel` has a corresponding `button element` inside of a section in the settings panel. Therefore, you will have to create a **button element** for an **element panel** and do not forget to assign the reference to the panel to the button element inside of the editor.

Since the panel it self is created by the **button element**, you should not manually add the panel to the settings scene.