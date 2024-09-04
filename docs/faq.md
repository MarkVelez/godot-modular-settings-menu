# Frequently Asked Questions

## Can I change how everything is structured and looks?

While I have not tested it fully, it should be possible to restructure the settings menu to fit the structure of your exisiting menu. This includes both visually different settings menu by making use of different nodes as well as where the elements of the settings menu are located. **However, the scene hierarchy of the elements need to stay the same.** The hierarchy is as follows `Settings > Sections > Elements`. If this hierarchy is not kept, there may be issues that can arise.

## Where is the save file located and can I change the location?

The settings menu uses `OS.get_user_data_dir()` to get the path to the user data directory which is different for each operating system. To find out where it is located for your system, you can refer to the [documentation](https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-get-user-data-dir) for the function.

As for changing this directory, you can do so by going to the `SettingsDataManager` script which can be found in the `singletons` folder. The directory is defined by the `DATA_FOLDER` variable. If you also want to change the name of the save file, you can do so by changing the `FILE_NAME` variable. If you make changes to either of the variables and have already generated a save file, don't forget to delete it. If you are making use of the included keybinds element, make sure to do these changes there as well if you wish to do so as the element handles saving it's settings by itself therefore it also creates it's own separate save file.

## What happens if the save file is tampered with?

There are two validation functions that check if there are any sections or elements that should not be there as well as if there any are that should be there but are missing and if the elements have correct values. If the functions spot any issues, it will be fixed automatically and you will get a warning telling you what the issue was.

