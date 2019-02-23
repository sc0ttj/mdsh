## Rofnafen script

```
#!/bin/sh

romdir="/root/network/MAINPC--rootfs/mnt-point/mnt/sdb1/Games"
[ -d "$2" ] && romdir="$2"

# choose a system dir to look in for roms
find "$romdir" \
    -maxdepth 1 \
    -mindepth 1 \
    -type d \
  | sed "s#.*/##g" \
  | sort -u \
  | rofi -dmenu \
      -p 'Enter name: ' \
      -i -mesg 'Choose a system to play' > /tmp/rofi_system_name

system_name="$(cat /tmp/rofi_system_name 2>/dev/null)"

if [ "$system_name" = "" ] || [ ! -d "$romdir/$system_name" ];then
 exit 1
fi


# looks for, list and choose a rom
find $romdir/$system_name \
    -maxdepth 2 \
    -mindepth 1 \
    -type f \
    -iname "*.cue" -or -iname "*.ccd" -or -iname "*.iso" -or -iname "*.zip" \
    -or -iname "*.smc" -or -iname "*.smd" -or -iname "*.gb" -or -iname "*.gbc" \
    -or -iname "*.gba" \
  | sed -e 's#.*/##g' \
  | sort -u \
  | rofi -dmenu -p 'Enter name: ' -i -mesg 'Choose a ROM to play' > /tmp/rofi_rom_name;

# rom name, escape [ and ]
romname="$(cat /tmp/rofi_rom_name | sed -e 's/\[/\[/g' -e 's/\]/\]/g')"
[ "$romname" = "" ] && exit 1

romfile="$(find "$romdir/$system_name" -maxdepth 2 -mindepth 1 -type f -iname "*${romname}*")"


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

more..
