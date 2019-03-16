// custom app JS

// func to load (using AJAX) a specific elem from another page into the the current page.
// source: https://stackoverflow.com/questions/21435877/load-specific-element-from-another-page-with-vanilla-js?answertab=votes#tab-top
//
// Usage:
//  getPage(
//   URL :    Location of remote resource ,
//   FROM :   CSS selector of source tag on remote page ,
//   TO:      CSS selector of destination tag
// )
function getPage(url, from, to) {
  var cached = sessionStorage[url];
  if (!from) {
    from = "body";
  } // default to grabbing body tag
  if (to && to.split) {
    to = document.querySelector(to);
  } // a string TO turns into an element
  if (!to) {
    to = document.querySelector(from);
  } // default re-using the source elm as the target elm
  if (cached) {
    return (to.innerHTML = cached);
  } // cache responses for instant re-use re-use

  var XHRt = new XMLHttpRequest(); // new ajax
  XHRt.responseType = "document"; // ajax2 context and onload() event
  XHRt.onload = function() {
    sessionStorage[url] = to.innerHTML = XHRt.response.querySelector(
      from
    ).innerHTML;
  };
  XHRt.open("GET", url, true);
  XHRt.send();
  return XHRt;
}

// this site includes 'cash-dom' by default, so we can use it
// for nicer DOM ready code:
$(function() {
  // DOM is ready now (all elements, styles and script loaded)
  // put your JS code here

  // site search, using Jets (https://jets.js.org/)
  if (Jets) {
    // set some Jets defaults
    var invertSearch = false;
    var callSearchManually = false;
    var hideBy =
      "opacity: 0; height: 0; width: 0; padding: 0; margin: 0; display: none;";
    var searchSelector = "*AND"; // search words in any order
    // check which page we are on - check which elems exist on the page
    var authors = document.getElementsByClassName("authors-list")[0]; // authors page
    var categories = document.getElementsByClassName("categories-list")[0]; // categories page
    var tags = document.getElementsByClassName("tags-list")[0]; // tags page
    var postPreviews = document.getElementsByClassName("post-preview")[0]; // homepage
    var searchResults = document.getElementsByClassName("search-results")[0]; // search page
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
    } else if (searchResults) {
      // search page
      contentToSearch = ".search-results";
      callSearchManually = true;
      // we will hide all items, and only show the matching ones:
      invertSearch = false;
      hideBy = "display: none;";
      // search for exact phrases (not words in any order)
      searchSelector = "*";
    } else if (postPreviews) {
      // homepage
      contentToSearch = "#content";
    } else if (posts) {
      // homepage
      contentToSearch = ".posts";
    }

    //console.log("contentToSearch", contentToSearch);

    if (contentToSearch !== "") {
      // make the site search input visible (if not on the search page)
      if (contentToSearch !== ".search-results") {
        document
          .getElementById("site-search")
          .setAttribute("style", "display: inline-block;");
      }

      // runs Jets - if NOT on search.html, it will filter the page as user types
      //           - if on search.html, it will perform the search on DOM loaded
      var jets = new Jets({
        searchTag: "#site-search",
        invert: invertSearch,
        hideBy: hideBy,
        searchSelector: searchSelector,
        callSearchManually: callSearchManually,
        contentTag: contentToSearch
      });

      // if we are on search.html
      if (searchResults) {
        // hide the search box in the page header
        $("#site-search").css("display", "none");

        // parse query string (get 's' param)
        function getQueryVariable(variable) {
          var query = window.location.search.substring(1);
          var vars = query.split("&");
          for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split("=");
            if (pair[0] == variable) {
              return pair[1];
            }
          }
          return false;
        }
        var query = decodeURI(getQueryVariable("q"))
          .replace("+", " ")
          .replace(/"/g, "");

        // if no search term given (yet) "
        if (query === "false") {
          $(".search-results .result").css("display", "none");
          // hide the 'return to search' link
          $(".search-back").remove();
          // add a search input
          $(".search-results").before(
            '<div class="search-box"><h1>Search the site</h1><form action="" method="GET"><input name="q" type="search" placeholder="Enter a search term.." /><button>Search</button></form></div>'
          );
          // else if search term found
        } else {
          // remove the search box and show the 'back to search' link
          $(".search-box").remove();
          $(".search-results").before(
            '<h1>Search results</h1><a class="search-back" href="search.html">&lt;&lt; Back to search</a>'
          );
          // perform the search
          $(".search-results").css("display", "block");
          jets.search(query);
        }
      }
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
