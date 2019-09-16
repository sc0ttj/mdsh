

Each page created using `mdsh` now gives you some extra CSS classes to work with, so you can more easily target specific browsers and devices.

The classes are added to (or removed from) the `<body>` tag of each post or page created, and are as follows:

* `no-js` - added to all pages at build time, removed by `app.js` when it loads
* `touchscreen` - added by `app.js` if users device is a touchscreen device
* `low-battery` - added by `app.js` if a battery with low remaining charge is detected
* `webgl` - added by `app.js` if the users browser supports WebGL

You can use these classes in your CSS to do things such as:

- show/hide content from users don't have JavaScript enabled
- enable/disable animations for (non) WebGL enabled browsers
- disable features/animations for users with low battery % remaining
- and so on

Some other classes are added to `<body>` at build time, which help you style pages and categories individually:

- the category name is added to `<body>` as `.category-{name}`
- the page slug name is added to `<body>`, for example `.my-cool-page`

You can then target individual categories or pages in your CSS like so:

```css
.category-main .main-container {
  /* styles that only affect the pages category main */
}

.my-cool-page .post-header {
  /* styles for only my-cool-page.html */
}
```

Hopefully these changes make it easier to customise your site for your users in a more granular and responsive way.
