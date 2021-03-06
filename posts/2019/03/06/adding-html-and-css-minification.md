

## Adding HTML and CSS minification

As of the last update, your HTML pages (and any CSS files they use) will be minified by default when running `update_pages`.

This should make them smaller in filesize and your site should load a little faster.

The minification is done by a new script called `minify`. It takes no arguments, and when run, it will search the current folder (and all sub-folders) for HTML and CSS files and then minify them.

A few points to note:

- the original HTML files are *replaced* by the minified versions
- the original CSS files are preserved - a `file.min.css` is created
- all HTML pages are updated to use the minified CSS files instead of the originals
- all minification must be done **after** creating the RSS feed

Don't worry, the `update_pages` script handles it all for you.

Here is the contents of the new `minify` script:

```shell
#!/bin/bash

# minifies HTML and CSS files,  requires no arguments

# usage: minify

# The script will then find all html and css files in the
# current dir (recursively) and replace them with minified
# versions

# minify HTML and CSS
echo "Minifying HTML and CSS.."

css_files="`find . -type f -name "*.css" | grep -v '.min.css' | sort -r`"
for css_file in $css_files
do
  minified_file="${css_file//.css/.min.css}";
  cp "$css_file" "$minified_file"
  cat "$css_file" 
    | grep -v '/\*' 
    | tr -d '
' 
    | sed -e 's/  / /g' 
          -e 's/ {/{/g' 
          -e 's/{ /{/g' 
          -e 's/ }/}/g' 
          -e 's/: /:/g' 
          -e 's/; /;/g' > "$minified_file"
done

html_files="`find . -type f -name "*.html" | grep -v 'min.html' | sort -r`"
for html_file in $html_files
do
  sed -i 's|.css?v=|.min.css?v=|g' $html_file
  sed ':a;N;$!ba;s/>\s*</></g' $html_file > ${html_file//.html/.minhtml}
  mv ${html_file//.html/.minhtml} ${html_file}
done

```
