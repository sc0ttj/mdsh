


You can now choose a page layout when creating new posts and pages - this
provides an easy way to render your pages with different mustache templates,
with varying layouts and structure.

The current layouts available are `main` and `simple`. Each layout must have a
`.mustache` template file in `.app/templates/[html]/`, such as `main.mustache`
or `simple.mustache`.

Layouts should not start with an underscore - as templates whose names begin with
an underscore are "partials" and to be included in other templates.

The `page_layout` variable is available a build time, and taken from your post
or pages front matter. For example, here is the YAML front matter for this post:

```yaml
title:        Easier layout selection
slug:         easier-layout-selection
descr:        You can now choose a page layout when creating new posts and pages - this provides an easy way to render your pages with different mustache templates, with varying layouts and structure.
permalink:
time_to_read: 2 mins
created:      2019-09-13T06:15:27Z
category:     blog
tags:         yaml
layout:       main
author:       sc0ttj
email:        foo@example.com
twitter:      @foobar
language:     en
js_deps:
modified:     2019-09-13T06:15:27Z

---
```

More layouts will be added in the future, to make it even easier to customise
your pages.
