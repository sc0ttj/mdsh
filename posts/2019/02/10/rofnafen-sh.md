

## Introducing rofnafen.sh

I have a small script I use to quickly load whatever SNES, PlayStation (etc) ROMs I wanna play.

It uses `rofi`, the desktop launcher, and `mednafen` the mutli-system emulator.

I have added key bindings so I can hit `Ctrl-SPACE` and start typing a system (PSX, SNES, etc),
then hit ENTER and start typing a game name, then hit ENTER again to play :)

As you can see from the default ROM dir I have set at the top of the script, it loads ROMs over the local network just fine.

```shell
#!/bin/sh

romdir="/root/network/MAINPC--rootfs/mnt-point/mnt/sdb1/Games"
[ -d "$2" ] && romdir="$2"

# choose a system dir to look in for roms
find "$romdir" \n    -maxdepth 1 \n    -mindepth 1 \n    -type d \n  | sed "s#.*/##g" \n  | sort -u \n  | rofi -dmenu \n      -p 'Enter name: ' \n      -i -mesg 'Choose a system to play' > /tmp/rofi_system_name


if [ "$system_name" = "" ] || [ ! -d "$romdir/$system_name" ];then
 exit 1
fi


# looks for, list and choose a rom
find $romdir/$system_name \n    -maxdepth 2 \n    -mindepth 1 \n    -type f \n    -iname "*.cue" -or -iname "*.ccd" -or -iname "*.iso" -or -iname "*.zip" \n    -or -iname "*.smc" -or -iname "*.smd" -or -iname "*.gb" -or -iname "*.gbc" \n    -or -iname "*.gba" \n  | sed -e 's#.*/##g' \n  | sort -u \n  | rofi -dmenu -p 'Enter name: ' -i -mesg 'Choose a ROM to play' > /tmp/rofi_rom_name;

# rom name, escape [ and ]
romname=""
[ "$romname" = "" ] && exit 1



if [ ! -f "$romfile" ];then
  rofi -dmenu -mesg "Rom file '$romname' not found!"
  exit 1
fi


case $system_name in
  *)
    # run the chosen game
    mednafen "$romfile"
    exit $?
    ;;
esac
```
