

## Fixing code formatting

I've added `IFS= read -r line` to mdshell, the new bit specifically being the `IFS= ` part.

This should preserve code formatting in code blocks, when that code has been pasted straight into the terminal (middle-click).

So let's test it. Here is some code I pasted in from `mdshell`:

```
if [ ! "$1" ] || [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ];then
  echo "

  An interactive shell for writing Markdown documents, with
  support for adding sub-shells into your Markdown to
  produce dynamic output.

  Usage:  mdshell <path-to-file> # creates the file if it doesn't exist
  "
  exit
fi
```
