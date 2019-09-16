


You can now set stylesheets in the front matter of your posts and pages or in
`assets/data/site.yml` - providing an easy way to style your pages with
default stylesheets, or unique ones per page.

### Settings a default website stylesheet

Your websites default styles are defined in `assets/data/site.yml`:

```
stylesheet: <name>
code_stylesheet: <name>
```

..where `<name>` matches a CSS file in `assets/css/` (without the `.css`
extension, or `pygments-` prefix).

### Setting a page stylesheet

You can override the site defaults by defining stylesheet in your pages front matter
(top of the `.mdsh` file) in the same way:

```
stylesheet: <name>
code_stylesheet: <name>
```

### Stylesheet files are in `assets/css/`

The current stylesheets available are `main` and `simple`. Each stylesheet must
have a .css file in `assets/css/`.

Stylesheets should not start with an underscore or 'pygments' - as these are
"partials" and to be included in other stylesheets.

### Using stylesheets in your templates

The following variables are available to use in your templates:

- `{{page_stylesheet}}`: the main stylesheet for your page, falls back to site defaults.
- `{{page_code_stylesheet}}`: the stylesheet for any highlighted code blocks on your page, falls back to site defaults.

Also available, but you probably won't need to use them:

- `{{site_stylesheet}}`: the default stylesheet for your site.
- `{{site_code_stylesheet}}`: the default stylesheet for any highlighted code blocks on your site.
