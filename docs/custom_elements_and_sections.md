# Adding custom elements and sections

Since the settings menu is designed to be modular, adding custom settings elements and or sections does not require messing with anything besides what the element actually does or what the section is called.

## Creating an element

I have included **templates for the element types** that were used to make the settings that come with the settings menu. These templates can be found in `scenes/settings-elements/templates`.

The only thing you have to change once you have duplicated a template and moved it to it's corresponding folder, is the **name of the root node** and the **text of the label node**.

## Setting up elements

Now that you have the element scene set up, you have to change some things inside of the element's script.

Depending on the type of element you chose to make you will have different things you need to change.

For **option elements** you want to change the **exported enum** at the top and add the options the element will have and don't forget to change the default value as well. 
```
# Default values for the element
@export_enum(
    "Example"
) var defaultValue: String = "Example"
```
Lastly you want to add these options to the `OPTION_LIST` **dictionary** as well as what these options correspond to. The values are completely dependant on what the setting will do, but if your setting does not require a value for the options, you can also replace the `Dictionary` with an `Array[String]`.

For **slider elements** you do not have to change anything, but if you wish to have a range of 0 to 1, but display a range of 0 to 100 or have any amount of disparity between actual value and displayed value you can do that by modifying the following parts of the script:
- First, you will want to change the default values to the actual range you want to have.
- Next, you have to multiply the values of the `init_slider` function to the values you want displayed. This can be found inside of the `load_settings` function.

  ```
  sliderValueRef.init_slider(minValue * 100, maxValue * 100, stepValue * 100, currentValue * 100)
  ```
- Lastly, you should divide the value you get from the slider by the amount you multiplied it in the `init_slider` function. You do this in the `value_changed` function.
  ```
  func value_changed(newValue: float) -> void:
      currentValue = newValue / 100
  ```

As for **toggle** and **button** elements, you don't have to make any modifications to the script, but do not forget to change their export variables in the editor. Especially for the **button element** as it is the reference to the **element panel** which it will create and display when clicked.

Now that you have set up all the variables, you can go ahead and write what the setting is supposed to do in the `apply_settings` function, ***button elements** being the exception here*. This function will be called when the settings data is first loaded for the element and when the apply button is pressed inside of the settings menu.

## Creating an in game setting

If you are making a setting that you want to interract with a game object, you will want to call `ElementResource.apply_in_game_setting(sectionRef, self)` in the `apply_settings` function of the element. You will then want to connect the `apply_in_game_setting` **signal** to the game object's script or to something that has a reference to the game object and will handle it's settings. Optionally you can pass an extra value to the object by including it as the third argument in the `ElementResource.apply_in_game_setting()` function.

Examples for how this is done inside of an element can be seen with settings that handle either camera settings or environment settings as for how they are applied to the object example scripts for that can be found in `scripts/settings-handler-scripts`.

## Creating sub elements

When creating an element with sub elements there are a few extra steps you need to do, however again I have included a template for an element with sub elements as well as a template for a sub element. Both of these can be found in `scenes/settings-elements/templates/sub-element-template`.

Once you have your parent element which has the sub element inside of it, you will want to modify some parts of the script.

Firstly, you want to make **export variables** for the sub elements that are under the parent element.
```
# Sub element references
@export var subElement: Node
```
Next, you want to add these references to the `SUB_ELEMENTS` array found inside of the `_ready()` function.
```
# Array of references to the sub elements
var SUB_ELEMENTS: Array[Node] = [
    subElement
]
```
Lastly, you can change how the sub elements will be shown based on the currently value of the parent element. You can do this inside of the `toggle_sub_element_visiblity()` function.
```
# Called to toggle the visiblity of the sub elements
func toggle_sub_element_visiblity() -> void:
    # Toggle the visiblity for the appropriate sub elements
    match currentValue:
        "Hide":
            subElement.hide()
        "Show":
            subElement.show()
```

## Creating a section

Similar to elements, I have included a template for an empty section, which again can be found in `scenes/settings-elements/templates`.

When adding elements to the section you either want to add them directly inside of the `ElementList` node or if you want to have separate visual groups inside of the section, you want to add them inside the `SubSectionElements` node which is found inside of the `SubSection` node. If you wish you can also rename the `SubSection` node and do not forget to change the text for the label. *These subsections are only visual and do not affect the settings data structure.*

As for adding the section to the settings menu, you want to create an instance of the scene inside of the `settings` scene inside of the `SettingsTabs` node.

## Creating element panels

As before, I have included a template for an empty element panel at `scenes/settings-elements/templates/element-panel-template`.

Element panels essentially server the same purpose as a settings section, however they are their own panel inside of being part of the existing settings panel that the sections are part of. They also handle applying and saving separately to the settings panel and they also have their own settings cache.

Each **element panel** has a corresponding **button element** inside of a section in the settings panel. Therefore, you will have to create a **button element** for an **element panel** and do not forget to assign the reference to the panel to the button element inside of the editor.

Since the panel it self is created by the **button element**, you should not manually add the panel to the settings scene.