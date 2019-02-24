// custom app JS

// this site includes 'cash-dom' by default, so we can use it
// for nicer DOM ready code:
$(function() {
  // DOM is ready now (all elements, styles and script loaded)
  // put your JS code here

  // site search, using Jets (https://jets.js.org/)
  if (Jets) {
    // check which page we are on - check which elems exist on the page
    var archivePosts = document.getElementsByClassName("archive-posts")[0]; // archive pge
    var categories = document.getElementsByClassName("categories-list")[0]; // categories page
    var tags = document.getElementsByClassName("tags-list")[0]; // tags pge
    var posts = document.getElementsByClassName("post-preview")[0]; // homepage
    var contentToSearch = "";

    // set the container elem to search
    if (archivePosts) {
      // archive page
      contentToSearch = ".archive-posts";
    } else if (categories) {
      // categories page
      contentToSearch = ".categories-list";
    } else if (tags) {
      // tags page
      contentToSearch = ".tags-list";
    } else if (posts) {
      // homepage
      contentToSearch = "#content";
    }

    console.log("contentToSearch", contentToSearch);

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
  }
});
