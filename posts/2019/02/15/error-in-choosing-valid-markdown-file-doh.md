## Error in choosing valid markdown file (doh!)

I was converting the mdsh contents (which now contain only the sub-shells, not their output) into HTML.

But I want the *output* of those commands to be in the final HTML.

So I've fixed `create_page`, so that it (hopefully!) works now..

Here's the test:

```
Linux
```

^ we should see `uname` in the `.mdsh` file, and `Linux` in the `.md` and `.html` files...
