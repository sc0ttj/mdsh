

## Highlighting search terms on the page

Using a [jQuery plugin found at Stack Overflow]( https://stackoverflow.com/questions/41533785/how-to-highlight-search-text-in-html-with-the-help-of-js), we can add some functionality to `cash-dom` (Ken Wheelers excellent [cash-JS](https://github.com/kenwheeler/cash), a lightweight jQuery replacement) so that any search terms entered into the site search input (which appears at the top of many pages on this site) are highlighted in yellow.

Here is the code I've added to `assets/js/app.js`:

```javascript
// add highlighting of searched items as a cash JS method/plugin
// from: https://stackoverflow.com/questions/41533785/how-to-highlight-search-text-in-html-with-the-help-of-js

$.fn.highlight = function(pat) {
  function innerHighlight(node, pat) {
    var skip = 0;

    if (node.nodeType == 3) {
      var pos = node.data.toUpperCase().indexOf(pat);

      if (pos >= 0) {
        var spannode = document.createElement("span");
        spannode.className = "highlight";
        var middlebit = node.splitText(pos);
        var endbit = middlebit.splitText(pat.length);
        var middleclone = middlebit.cloneNode(true);

        spannode.appendChild(middleclone);
        middlebit.parentNode.replaceChild(spannode, middlebit);
        skip = 1;
      }
    } else if (
      node.nodeType == 1 &&
      node.childNodes &&
      !/(script|style) /i.test(node.tagName)
    ) {
      for (var i = 0; i < node.childNodes.length; ++i) {
        i += innerHighlight(node.childNodes[i], pat);
      }
    }

    return skip;
  }

  return this.each(function() {
    innerHighlight(this, pat.toUpperCase());
  });
};

$.fn.removeHighlight = function() {
  function newNormalize(node) {
    for (var i = 0, children = node.childNodes, nodeCount = children.length; i < nodeCount; i++) {
      var child = children[i];

      if (child.nodeType == 1) {
        newNormalize(child);
        continue;
      }

      if (child.nodeType != 3) {
        continue;
      }

      var next = child.nextSibling;

      if (next == null || next.nodeType != 3) {
        continue;
      }

      var combined_text = child.nodeValue + next.nodeValue;
      new_node = node.ownerDocument.createTextNode(combined_text);
      node.insertBefore(new_node, child);
      node.removeChild(child);
      node.removeChild(next);
      i--;
      nodeCount--;
    }
  }

  return this.find("span.highlight").each(function() {
    var thisParent = this.parentNode;
    thisParent.replaceChild(this.firstChild, this);
    newNormalize(thisParent);
  });
};

// add the event handler to the search input to call the highlighter
$ ("#site-search").on("keyup change", function(ev) {
  // pull in the new value

  // remove any old highlighted terms
  $ ("#content").removeHighlight();

  // disable highlighting if empty
  if (searchTerm) {
    // highlight the new term
    $ ("#content").highlight(searchTerm);
  }
});
```

In short, we added a new method to cash-js: `$.highlight()`, then use it to highlight matching items on the page.
