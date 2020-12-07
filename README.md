# System Build Android Firmware
*(Android Firmware Construction Kit)*

AFCK is a set of scripts used for (re-)building Android OS firmware. The purpose of this set is the manufacture of tuned firmware, using the ready-made firmware manufacturer as the basis.

At the moment, this project can be used to assemble the firmware for the following devices:

* Android TV set-top box X96 Max

To (re)build the firmware, a script for the GNU Make program and a set of POSIX-compatible utilities are used. Type "make" without parameters to get a description of the goals that can be built by the script.

# Preparing to build
## Base files

The files from which the firmware is built are not part of GIT. They are too big and they change a lot. You will have to find them online yourself. When you run make, you will be told the names of the missing files.

You can try running the script file ingredients/01-get-it-all. It will try to download the necessary files from the network. This does not necessarily work as links to such resources may change frequently.

## apktool
You need to install a fresh apktool from here:
	https://bitbucket.org/iBotPeaches/apktool/downloads/

Create an apktool script that will run the `java -jar apktool version.jar $*`. If you have previously installed framework files in apktool, clean it up:
```
apktool empty-framework-dir --force
```

# Using an assembly system

The assembly system has an integrated help system. Running `make` without parameters will display the complete list of targets to be built. To initiate an assembly of any target, run `make <target>. To avoid cluttering the main help screen, many additional targets are on separate screens. To display additional help screens, type `make help-<screen>`, a list of available additional screens can be found on the main help screen, for example, `make help-mod` will display a list of targets for overlaying modifications to the unpacked firmware.

The `TARGET` variable sets the target firmware platform, for example, `TARGET=x96max/beelink` sets the firmware assembly for the x96max hardware platform based on the beelink firmware. The value of the TARGET variable is either specified in the top-level Makefile or can be overridden in the local-config.mak file, which must be created by yourself.

To assemble the final files from the source ones, run the `make deploy' command. If all goes well, you will get the final distribution files in the out/$(TARGET)/deploy/ subdirectory.

If something fails, you can build the firmware step by step. First try to simply unpack the original firmware: `make img-unpack'. Then apply the modifications, either all at once with the command `make mod`, or one at a time using the target names from `make help-mod`. At the end you can assemble the firmware files: `make ubt-img` and `make upd`. After that there is one small step left: `make deploy` and the final files are ready.


## Develop your own modifications
All modifications are located in separate directories inside the subdirectory of the target platform `build/$(TARGET)/` (for example, build/x96max/beelink/). Each modification is in its own individual subdirectory.

If you are developing your own modification, you need it:

* Create a subdirectory for the modification inside the build/$(TARGET)/ directory. Basically, the name can be anything, but it is customary to make a two-digit name, a dash and a modification name. The number at the beginning of the name of the subdirectory helps to sort the subdirectories in the order of processing, so modifications with a higher number can use the variables specified by the modifications with lower numbers.

* Create in it a file `name of modification.mak', which defines the necessary rules to impose the modification. We shall call the contents of this file * modification rules*.

Note that all files with modification rules are loaded into a single namespace. This means that if you define a variable with a certain name in one file and then a variable with the same name in another file of modification rules, the second assignment will override the first one and the modification may not happen as you want it to. So if you enter additional variables in the modification rules, use the modification name as the basis for the variable name. For example, if your modification is called `boom`, use variable names like `BOOM_APK`, `BOOM_FILES` and so on.

The only exception is for variables with fixed names, which specify exactly how the modification will be applied:

* `HELP` contains a description of the modification. This text is given to the user by the command `make help-mod`.
* `DISABLED` - if this variable gets a non-empty value, the mod will be turned off. This variable can be used to temporarily disable certain mods (without having to delete or rename the .mak file).
* `INSTALL` actually contains a sequence of instructions for overlaying modification on the unpacked image.
* `MOD` contains the name of the fashion
* `DIR` contains the name of the fashion subdirectory. Use it to access additional files such as `$(DIR)/boom.apk` and so on.
* `DEPS` contains a list of files, on which the mod depends. When changing any of these files, the build system will consider that the mod needs to be reloaded. By default, all files from the subdirectory of a mod are added to the `DIR` variable (*not from subdirectories*).
* `/` - a variable with such a funny name is very useful because it contains the base directory where the unpacked images of file systems are located. In GNU Make variables with the same name can be avoided in parentheses: `$/` is equivalent to `$(/)`. Use this variable for convenient work with unpacked image files, for example: `cp $(DIR)/boom.apk $/system/app`.

Also for some tasks there are useful functions that can be called:

* `$(call IMG.UNPACK.EXT4,<section>)` will create a dependency of the current mod on the unpacked image of the specified section. For example, `$(call IMG.UNPACK.EXT4,system)` will create such a dependency so that before the start of mod overlaying the partition `system` has already been unpacked into the directory `$/`, so you can immediately write rules like `rm $/system/build.prop`, etc. If this function is not called, the existence of the `$/system` subdirectory is not guaranteed at the moment when the rules of the mod are started, especially in case of multi-threaded building.
* `$(call MOD.APK,<section>,<file.apk>,<description>)` creates a complete set of rules to install the APK file into the app/ subdirectory of the specified partition (usually system or vendor). The easiest mod for adding a particular app may consist of a single line calling that function.

Basically, the above should be enough to get you started. If you want to know more about how the build system works from within, see the next section.

# How does the build system work

The building system operation is described in more detail in the file doc/HOWITWORKS.md. If something goes wrong or you are going to develop based on afck, we recommend to read this file.
