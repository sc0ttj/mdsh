// custom app JS

// this site includes 'cash-dom' by default, so we can use it
// for nicer DOM ready code:
$(function() {
  // DOM is ready now (all elements, styles and script loaded)
  // put your JS code here

  // site search, using Jets (https://jets.js.org/)
  if (Jets) {
    // check which page we are on - check which elems exist on the page
    var authors = document.getElementsByClassName("authors-list")[0]; // authors page
    var categories = document.getElementsByClassName("categories-list")[0]; // categories page
    var tags = document.getElementsByClassName("tags-list")[0]; // tags pge
    var postPreviews = document.getElementsByClassName("post-preview")[0]; // homepage
    var posts = document.getElementsByClassName("posts")[0]; // indexes
    var contentToSearch = "";

    // set the container elem to search
    if (authors) {
      // authors page
      contentToSearch = ".authors-list";
    } else if (categories) {
      // categories page
      contentToSearch = ".categories-list";
    } else if (tags) {
      // tags page
      contentToSearch = ".tags-list";
    } else if (postPreviews) {
      // homepage
      contentToSearch = "#content";
    } else if (posts) {
      // homepage
      contentToSearch = ".posts";
    }

    //console.log("contentToSearch", contentToSearch);

    if (contentToSearch !== "") {
      // make the site search input visible
      document
        .getElementById("site-search")
        .setAttribute("style", "display: inline-block;");

      var jets = new Jets({
        searchTag: "#site-search",
        contentTag: contentToSearch
      });
    }

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
        for (
          var i = 0, children = node.childNodes, nodeCount = children.length;
          i < nodeCount;
          i++
        ) {
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
    $("#site-search").on("keyup change", function(ev) {
      // pull in the new value
      var searchTerm = $(this).val();

      // remove any old highlighted terms
      $("#content").removeHighlight();

      // disable highlighting if empty
      if (searchTerm) {
        // highlight the new term
        $("#content").highlight(searchTerm);
      }
    });
  } // end of site search stuff
}); // end of on DOM ready
