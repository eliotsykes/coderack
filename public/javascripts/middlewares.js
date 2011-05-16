var Middlewares = {
  init: function() {
    // disable "Search" button - prevents multiclick, and the value is not sent as form data 
    $('form.search').submit(function() {
      $(this).find('input[type=submit]').attr('disabled', 'disabled');
    });
    
    // add click handler for remove-links
    $(".remove_entry").live('click', function() {
      if (confirm('Your entry will be permanently removed. Are you sure?')) {
        $(this).parents("div.middleware").find("form.remove_entry_form").submit();
      }
      return false;
    });
  }
};

$(Middlewares.init);
