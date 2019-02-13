# title:        Using Sed
# slug name:    using-sed
# description:  A how not to...
# time to read: 1 min
# category:     blog
# tags:         blog,shell,sed
# author:       John Doe
# email:        foo@bar.com
# twitter:      @foobar
# language:     en
# JS deps:      cash-dom 
# created:      2019/02/11
# modified:     2019/02/11

---
## Using Sed

Here is what I am using:

```
echo "$html" | sed -e 's|</h2>|</h2>'"${more_html}"'|'
```

I'm now using single quotes, and inserting double quotes where needed, between the single quotes, and not escaping anything.


