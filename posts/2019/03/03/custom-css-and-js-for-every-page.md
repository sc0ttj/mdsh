## Custom CSS and JS for every page


I've implemented a super easy way to include custom JavaScript (JS) and CSS in any pages or posts you create using `mdsh`.

It is as simple as adding a `.css` or `.js` to the relevant folder in `assets/`, and giving the files the same name as the `.html` file in which you wish to include your custom scripts.

For example, this post, titled "Custom CSS and JS for every page" gets the filename `custom-css-and-js-for-every-page.html`.

So you can create the following CSS and JS files, and they will be *automatically* included in `custom-css-and-js-for-every-page.html` when building the page:

- `assests/js/custom-css-and-js-for-every-page.js`
- `assets/css/custom-css-and-js-for-every-page.css`

Note: If you create these custom CSS and JS scripts **after** you have written the post/page, it will need to be re-built using `update_pages -all` in order for them to be included.

Tip: Create any custom JS or CSS files you will need (even as empty files) *before* you run `create_post`, and you won't need to re-build the page.

The custom CSS is included **after** the `main.css` stylesheet.

The custom JS is included **after** the main `app.js` script.


