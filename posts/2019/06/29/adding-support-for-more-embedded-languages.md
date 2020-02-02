

After the latest update, `mdsh` now lets you embed languages other than Bash in 
your Markdown, when writing your posts or pages.

The syntax for embedding dynamic content in your pages using Bash is:

```
<#bash
// some Bash code
;#>
```

And now you can replace the `bash` bit with the name of any of these other 
languages: `ash`, `awk`, `c`, `dash`, `gawk`, `node`, `nodejs`, `perl`, `php`, `python`, `ruby`.

For example, to include the output of some Ruby code in your Markdown, you would 
do this:

```
<#ruby
puts "hello world"
;#>
```

<!-- more -->

Or to include some output from Python, do this:

```
<#python
print "hello world";
;#>
```

Or to include some JavaScript output (using NodeJS), do this:

```
<#node
console.log("hello world");
;#>
```

And so on...

So in summary:

Users of `mdsh` now have an easy way of including dynamically generated content 
in their pages, generated using a range of scripting languages.

### Advanced

#### Running C code

If you have [TCC](https://bellard.org/tcc/tcc-doc.html) installed, you can even 
embed C code in your Markdown, and it will be compiled and run "on-the-fly" - the 
output of the compiled C code will end up in your final Markdown and HTML.

Example:

```
<#c
main(){
  puts("Hello world");
}
;#>
```

Note, this feature is not heavily tested. To install TCC, search for the package 
`tcc` using your package manager.

#### Running scripts

For more complex needs, you can run scripts, rather than commands:

```
<#bash
python path/to/script.py
;#>
```

or

```
<#bash
node path/to/script.js
;#>
```

or

```
<#bash
tcc -run path/to/script.c arg1 arg2
;#>
```

#### Targeting specific versions of interpretors

You can target specific versions of Perl, PHP, Python or Ruby. Just make sure you 
have the version chosen installed. Example, if using `<#php5`, then `php5` 
should be available in your `$PATH`. You may want to create some aliases or 
symlinks to achieve this.

Here are some examples:

```
<#perl5.24.1
print "hello world from Perl";
;#>
```

or

```
<#php5
echo "hello world from PHP";
;#>
```

or

```
<#python2.7
print "hello world from Python2";
;#>
```

or

```
<#python3.6
print "hello world from Python3";
;#>
```

or

```
<#ruby-2.3.3
puts "hello world from Ruby";
;#>
```

And so on... In each case, the given interpretor (`ruby-2.3.3`, for example) 
should be available in your `$PATH`.

Of course, you can always use `nvm`, `rvm` (etc) to manage the versions 
of Node, Ruby (etc) that you use, if you prefer to do it that way.
