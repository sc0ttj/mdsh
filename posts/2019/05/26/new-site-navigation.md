


To improve site navigation, I've added a new template to `mdsh`, which produces a nice menu for easier website navigation - it lists the main pages (`.html` pages in the root dir, exluding `index.html` and `404.html`), most recent blog posts, as well as the sites categories and tags.

You can see this site navigation section in the footer of this page.

<!-- more -->

### How to edit

The site navigation is created using a function in `.app/generate_page_content.bash`, which is called `site_navigation` and does the following:

- creates the mustache iterators and data needed by the `.app/templates/html/_site_navigation.mustache` template
- renders the HTML from the template

This `site_navigation` function is called using the `{{site_navigation}}` variable in the `_site_footer.mustache` template: when the footer template is parsed, the `site_navigation` shell function is executed and its output included in the HTML output.

You could edit the contents of the `site_navigation` function to change the data passed to the `_site_navigation.mustache` template, or edit where it appears by moving `{{site_navigation}}` in your templates, or you could edit `_site_navigation.mustache` itself to edit the HTML it produces.

You might also need to edit `assets/css/main.css` as well - look for `.site-navigation` classes.

### Other uses

The navigation generated could be used in the main website header, or it could be used as off-screen links for screen-readers, or it could be used as off-screen TAB only content, much like the "Skip to content" popup you get when tabbing through `mdsh` generated pages.
