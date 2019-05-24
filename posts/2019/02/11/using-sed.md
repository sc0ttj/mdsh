

## Using Sed

Here is what I am using:

```
echo "$html" | sed -e 's|</h2>|</h2>'"${more_html}"'|'
```

I'm now using single quotes, and inserting double quotes where needed, between the single quotes, and not escaping anything.
