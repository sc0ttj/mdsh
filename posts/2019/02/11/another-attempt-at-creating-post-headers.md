
## Another attempt at creating post headers

The `sed` command works much better at transforming HTML is the delimeter/separator you use is not a `/`.

Hopefully, the follwing command will now work as intended:

```
echo "$html" | sed 's|</h2>|</h2> some more text|'
```

The code above is meant to append to text after the first `<h2>` tag it encounters in the "$html" string.

IF this post has a post header included, the above worked for me.
