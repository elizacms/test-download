$(document).on("click", "#allReleasesTable tr", function() {
  window.location = $(this).data("href");
});
