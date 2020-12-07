# upd-maker

This is a simple utility for creating updates in Android Recovery (update*.zip) format. You can create both simple updates (consisting of partition images, which are simply written in /dev/block/xxxx), and advanced, using a handwritten script.

The main feature of the utility is the use of Unix Shell, built into any Recovery, to perform all operations. It is a utility for those who are sick of the limitations of 'Edify' (the 'update-binary' interpreter). This solution not only allows you to create more advanced scripts, but also significantly reduces the size of the archive (this is especially noticeable for smaller updates).

The following files are part of the utility:

* `upd-maker` - Actually, the file you run.
* `upd-maker-template.zip` - Template of the update archive.
* `zipsigner-3.0.jar` - Utility for signing update archives, taken from Magisk:
    https://github.com/topjohnwu/Magisk

They can be located at any convenient location, and the upd-maker will search for other files in the same directory where it is installed.

## Basic use

Utility upd-maker can be used to create ready-made updates of Android partitions. In this case, the utility itself will generate a basic updater-script update script. For such use, the command line may look something like this:

```
upd-maker -n "Super Update from Vasya Pupkin" -o update-pupkin.zip \.
	system.PARTITION.raw vendor.PARTITION.raw
```

or, for example, so:

```
upd-maker -n "TWRP installer" -o update-TWRP-3.4.5.zip recovery.PARTITION
```

Keep in mind that image files should be filed exactly as they are written in /dev/block/xxxx, i.e. if the partition is packed with, for example, the ext4 sparse or brotli algorithm, they should be unpacked beforehand. The zip utility will do a great job of reducing the image size.

The file name must match the name of the block device, i.e. test.PARTITION will be written to /dev/block/test and so on. The file extension is irrelevant.

## Advanced use

The utility also allows you to use fully user-written update scripts. In this case the -s option is used to specify the name of the script file. All options used for script autogeneration (-n, -d, -cs, -ce) will also have an effect, but files and directories defined from the command line will simply be written to the root directory of the archive. For example:

```
upd-maker -o install-supersu-2.82.zip -s supersu-installer \.
	files/su files/99SuperSUDaemon files/SuperSU.apk \.
	files/system files/vendor
```

In the example above files/system and files/vendor are subdirectories with their contents. Once an archive is created, it will look like this:

```
 Length Method Size Cmpr Date Time CRC-32 Name
-------- ------ ------- ---- ---------- ----- -------- ----
   75352 Defl:N 37077 51% 02-29-2008 05:33 90352177 su
      55 Defl:N 44 20% 02-29-2008 05:33 0d67885f 99SuperSUDaemon
 6225270 Defl:N 2862078 54% 02-29-2008 05:33 54f88e45 SuperSU.apk
     117 Defl:N 68 42% 02-29-2008 05:33 7048067f system/init.d.perm
     157 Defl:N 98 38% 02-29-2008 05:33 bc2f60af system/run-init.d
     300 Defl:N 118 61% 02-29-2008 05:33 8ee51b49 system/supersu.perm
     250 Defl:N 102 59% 02-29-2008 05:33 3c82573a vendor/init.d.perm
     168 Defl:N 119 29% 02-29-2008 05:33 b8ce3141 vendor/init.d.rc
     187 Defl:N 108 42% 02-29-2008 05:33 6a6ef29c vendor/run-init.d
     308 Defl:N 129 58% 02-29-2008 05:33 12473aee vendor/supersu.perm
```

## Built-in features

When you start an update, the Recovery utility (or TWRP) runs the META-INF/com/google/android/update-binary script. This is an SH script, which performs the initial initialization of the desktop environment, then runs a custom script META-INF/com/google/android/updater-script.

The following additional functions are available for the user scenario:

* `ui_print'.
    Similar to the function ui_print in the language Edify, prints a line in the graphical console of the program. Example: ui_print "Hello!

* `progress <position> <duration> `.
    Sets the progress indicator to the specified position (fractional number from 0 to 1) with expected duration of the operation.

* `set_progress <position>`.
    Simply set the progress indicator to the specified position.

* `package_extract_file <package in archive> <package in file system> `.
    Extracts the specified file from the archive. The second argument can be either the full name of the file (in this case, it can be unpacked simultaneously with renaming) or the directory name, in this case the original file name is used.

* `package_extract_folder <path in archive> <path in file system>`.
    Extract a subdirectory with all content.

* `set_perm <uid> <gid> <file> [<file>...]`.
    Allows you to set the owner, group and access rights of the specified file or files. Example: set_perm root 0644 /system/etc/hello.txt

Translated with www.DeepL.com/Translator (free version)

* `perm <file name.perm>`.
    Set the owner, group, access rights and SElinux context for the set of files according to the rules defined in the specified file. The file contains rows, one for each file, in the following format:
    ```
    <file> <uid> <gid> <authorization> <context>
    ```
    For example:
    ```
    /system/etc/init.d 0 0 0755 u:object_r:system_file:s0
    /system/bin/run-init.d 0 2000 0755 u:object_r:system_file:s0
    ```
* `stdout_to_ui_print`
    Redirects stdout to ui_print. It can be used in conveyor constructions of the type:
    ```
    ls -la /system | stdout_to_ui_print.
    ```

* `wipe_cache *
    Clear the Android cache after the successful installation of the update.
    In modern versions of Android is a useless operation: formatted section /cache, which contains almost one garbage.

* `clear_display'.
    Graphics console cleaning

* `enable_reboot
    Allow reboot during installation (useful for debugging packages that may hang during operation).

* `sed_patch <file> <command> [<command>...]`.
    Executes the specified sed commands over the specified file. The resulting file replaces the original file if the content has changed. Example:
    ```
    sed_patch /system/build.prop '/^#adb/,/^service.adb/d'
