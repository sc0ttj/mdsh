# README

`mdshell` - Write your blog straight from the terminal.

## Description

This is a simple static site generator (SSG), or "blog making thing".

`mdshell` requires only Bash and Perl, and builds HTML files from Markdown files.

The name `mdshell` refers to the fact you can combine Markdown and Bash sub-shells in your blog posts to dynamically produce the HTML output.

This is a fast way of producing documentation for any installed programs or commands, and a nice easy way to write blog posts in Markdown.

## Features

- Written in Bash shell script
- Simple command-line interface (use in the terminal)
- Builds a fast blog with great SEO and mobile support
- Creates blog posts or custom pages, built from Markdown or HTML.
- Generates index pages for categories, tags, authors and more.
- Generates a valid RSS feed and XML sitemap.
- Define your [site and page data](https://sc0ttj.github.io/mdsh/posts/2019/09/07/better-data-and-template-handling.html) in `assets/data/` as YAML, CSV or Bash variables & arrays
- Uses a mustache-like templating system, with [liquid-style filters](https://sc0ttj.github.io/mdsh/posts/2019/07/13/liquid-filters.html)
- Auto convert URLs to [embedded content](https://sc0ttj.github.io/mdsh/posts/2019/09/14/embedding-youtube-videos-tweets-codepens-and-other-third-party-content.html) for Youtube, Twitter, Instagram, etc..
- Embed shell, python, ruby etc, in your Markdown to create [dynamic Markdown](https://sc0ttj.github.io/mdsh/posts/2019/06/29/adding-support-for-more-embedded-languages.html) output!
- Includes a "Contact" page that works out of the box! (uses [formspree.io](http://formspree.io), requires JS)
- Includes a fast page search, with highlighted matches (uses [Jets](https://jets.js.org/), requires JS)
- Supports fullscreen, native app experience on mobile if added to Homescreen
- Supports code syntax highlighting (requires [Pygments](http://pygments.org/), default theme is `monokai`)
- Optionally use [Google Fonts](https://fonts.google.com/) to choose custom web fonts
- Optionally use [Unpkg.com](http://unpkg.com) to manage JavaScript libraries/dependencies
- Optionally use [Git](https://kbroman.org/github_tutorial/) for saving, managing and reverting versions and deployments
- Optionally use [GitHub Pages](https://pages.github.com/) for free, fast, and secure (SSL enabled) site hosting
- Supports many other web hosting options too ([GitLab Pages](https://about.gitlab.com/product/pages/), [Netlify](https://www.netlify.com/docs/continuous-deployment/), others).

## Setup

`.app/setup.sh` - set site defaults, settings and options.

`source .site_setup` - source the app and site settings - _important!_

`server [start|stop]` - start/stop a local web server.

## Usage

`new post` - create a new post. Follow the on-screen instructions - a `.mdsh` file will be created for you containing your chosen options as YAML front matter. After you've saved your new post, all relevant index pages will be updated and re-built.

`publish "message"` - save and publish latest changes.

## Advanced usage

#### Customising posts

`new post -all` - creates a new post, as above, but allows overriding various site defaults.

#### Creating pages

`rebuild file.mdsh > file.html` - create a page from a `.mdsh` file (recommended).

`rebuild file.md > file.html` - create a page from a Markdown file.

`rebuild "$html" > file.html` - create a page from an HTML string.

Or manually:

```
page_title="My cool page" \
page_slug="my-cool-page"  \
page_descr="Some thing"   \
page_layout="main"        \
page_stylesheet="main"    \
  .app/create_page.sh "$body_html" > my-cool-page.html
```

#### Rebuilding pages

If you edit any existing Markdown or .mdsh files, you may need to re-build the HTML pages:

`rebuild` - re-build all index pages (authors, categories, tags, etc).

`rebuild file.mdsh file.html` - re-build a specific page from a .mdsh file (recommended).

`rebuild file.md file.html` - re-build a specific page from its Markdown file.

`rebuild -all` - re-build all posts from their Markdown files.

`rebuild -ALL` - re-build all posts from their .mdsh files.

`rebuild tags:foo,bar` - rebuild tag index pages for tags `foo` and `bar`

`rebuild authors:sc0ttj homepage` - rebuild author page for sc0ttj, and the homepage

#### Updating sitemap

_After_ publishing your new post or page, you can update your sitemap.

`rebuild sitemap` - re-build and publish an updated XML sitemap file.

## Documentation

Type `help` in the terminal.

Also, read the [wiki](https://github.com/sc0ttj/mdsh/wiki) for more help and usage information.

## To do

See [Issues page](https://github.com/sc0ttj/mdsh/issues) for planned features and known bugs.
