var Application = {
  init: function() {
    $("#header .nav li a.menuitem").mouseenter(function() {
      $("#header .nav .opened").removeClass('opened').slideUp('fast');
      $(this).next("ul.submenu").addClass('opened').slideDown('fast');
    });
    
    $("#header .nav").mouseleave(function() {
      $("#header .opened").removeClass('opened').slideUp('fast');
    });
    
    $("#flash").click(Application.hideFlash);
    setTimeout(Application.hideFlash, 5000);
    
    $("#google_signin, #yahoo_signin").click(function() {
      $('#' + $(this).attr('id') + '_form').submit();
      return false;
    });

    if (($(".github_stats").length > 0) && ($(".actions .github").length > 0)) {
      Application.fetchGitHubStats();
    }
    
    // workaround for FF bug (doesn't update radios after reload)
    $(".voting-star").each(function() {
      if ($(this).attr("data-checked")) {
        $(this).attr("checked", true);
      }
    });
    
    $(".voting-star").rating({
      required: true,
      callback: function(value, link, element) {
        var middlewareId = $(element).parents('.middleware').attr('data-middleware-id');
        var url = "/middlewares/" + middlewareId + "/vote";
        $.ajax({
          url: url,
          type: "POST",
          data: { 'score': value }
        });
      }
    });
  },
  
  hideFlash: function() {
    $("#flash").fadeOut('slow');
  },

  fetchGitHubStats: function() {
    var githubURL = $(".actions .github").attr('href');
    var match = githubURL.match(/^http:\/\/(www\.)?github.com\/([\w\-\.]+)\/([\w\-\.]+)(\/|$)/);
    if (match) {
      var repo = match[2] + "/" + match[3];
      var repoURL = "http://github.com/api/v2/json/repos/show/" + repo + "?callback=?";
      $.getJSON(repoURL, function(responseJSON) {
        if (responseJSON.repository) {
          $(".github_stats .watchers").text(responseJSON.repository.watchers);
          $(".github_stats .forks").text(responseJSON.repository.forks);
          var commitsURL = "http://github.com/api/v2/json/commits/list/" + repo + "/master?callback=?";
          $.getJSON(commitsURL, function(responseJSON) {
            if (responseJSON.commits && responseJSON.commits[0]) {
              var date = Application.dateFromRFC3339(responseJSON.commits[0].committed_date).toLocaleDateString();
              $(".github_stats .last_update").text("Last update: " + date);
              $(".github_stats").show();
            }
          });
        }
      });
    }
  },

  dateFromRFC3339: function(dString) {
    var regexp = /(\d\d\d\d)(\-)?(\d\d)(\-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+\-])(\d\d)(:)?(\d\d))/;
    var date = new Date();
    if (dString.toString().match(new RegExp(regexp))) {
      var d = dString.match(new RegExp(regexp));
      var offset = 0;
      date.setUTCDate(1);
      date.setUTCFullYear(parseInt(d[1],10));
      date.setUTCMonth(parseInt(d[3],10) - 1);
      date.setUTCDate(parseInt(d[5],10));
      date.setUTCHours(parseInt(d[7],10));
      date.setUTCMinutes(parseInt(d[9],10));
      date.setUTCSeconds(parseInt(d[11],10));
      if (d[12]) {
        date.setUTCMilliseconds(parseFloat(d[12]) * 1000);
      } else {
        date.setUTCMilliseconds(0);
      }
      if (d[13] != 'Z') {
        offset = (d[15] * 60) + parseInt(d[17],10);
        offset *= ((d[14] == '-') ? -1 : 1);
        date.setTime(date.getTime() - offset * 60 * 1000);
      }
    } else {
      date.setTime(Date.parse(dString));
    }
    return date;
  }
};

$(Application.init);