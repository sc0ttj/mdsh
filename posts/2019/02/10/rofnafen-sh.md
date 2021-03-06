


### python

Here is `SOME "PYTHON"` in a sentence.

And a python block:

```python
current dir: $PWD
wo"r"ld
```

### perl

Now some `PERL $PWD "stuff"` in a sentence.

And a Perl block:

```perl
perl-lowo"r"ld
```

And another, running a specific Perl version (/usr/bin/perl5.24.1):

```
hello world from Perl
```

### Node JS

Node `in a` sentence.

Node block:

```
Current dir: $PWD
```

### bash

Your date is `Fri Aug 30 19:34:58 BST 2019.`

Your PWD is `/root/Sites/github/mdsh`

Your user is `root
`. Your OS is `Linux
` and Pkg version is 1.9.22

I have a small script I use to quickly load whatever SNES, PlayStation (etc) ROMs I wanna play.

It uses `rofi`, the desktop launcher, and `mednafen` the mutli-system emulator.

I have added key bindings so I can hit `Ctrl-SPACE` and start typing a system (PSX, SNES, etc),
then hit ENTER and start typing a game name, then hit ENTER again to play :)

As you can see from the default ROM dir I have set at the top of the script, it loads ROMs over the local network just fine.

Here is the script:

```shell
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
