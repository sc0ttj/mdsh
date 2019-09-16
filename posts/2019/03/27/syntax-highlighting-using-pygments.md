

I've added a new feature to `mdsh`: syntax highlighting for code blocks.

A new option has been added to `.site_config`, which lets you choose the highlighing theme - currently only `monokai` is supported, so is set as the default theme.

### Setup syntax highlighting

To get it working, you simpy need to install `Pygments`, and then `mdsh` will do the rest!

You can install Pygments using the `pip` package manager, if you have it installed:

```console
pip install Pygments
```

Or, if you don't have `pip` installed, on Ubuntu and Debian, you can install `Pygments` like so:

```console
sudo apt-get install python3-pygments
```

### Using syntax highlighting

When you create or edit a blog post or page, you should create the code block using the GitHub flavoured extension, supplying the language name after the triple backticks ("code fences").

Here is an example block of `shell` code:

```shell

 var="foo"
 echo ${var//foo/bar} # outputs 'bar'

```

Disclaimer: Pygments is quite slow - large code blocks may take a while to process, and the highlighted HTML output is a larger filesize than without.

### Further improvements

* add more themes as `assets/css/pygments-{theme}.css`
* the theme can then be changed using `setup` or by editing `.site_config`
* allow setting Pygments options, such as headers, line numbers, etc.
