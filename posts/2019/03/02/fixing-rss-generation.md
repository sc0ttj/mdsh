

## Fixing RSS generation

I've made a few changes in the `./create_rss` function, so that it works on both Linux and Mac OS X:

- dont use the `-printf` option with `find`
- dont use `--rfc` option with `date`
- simplified sed commands
- use simple find command to list files newest to oldest (with `sort -r`)
- create RFC 2822 date formats using `date +"%a, %d %b %Y %T %z"`

Because there is no simple way to generate the dates with a command that works on both Linux and Mac, I use `uname` to check the OS type (Linux, Darwin, etc), then I set the date using one of two ways.

Here is the relevant code from `create_rss`:

```
if [ "$os_type" = "Linux" ];then
  # use GNU date
  pubDate=`date -r "$file" +"%a, %d %b %Y %T %z"`
  force_update=`date -r "$file" "+%s"`
else # Mac, BSD
  # use BSD date
  pubDate=`date -r "$timestamp" +"%a, %d %b %Y %T %z"`
  force_update=`date -r "$timestamp" "+%s"`
fi
```

Using this, the command `./create_rss posts/ > feed.rss` that is used in `update_pages` should work on Linux, Mac and BSD.
