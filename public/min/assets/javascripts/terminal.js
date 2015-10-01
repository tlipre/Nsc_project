(function() {

  $(function() {
    var result, socket;
    socket = io();
    result = $('#result');
    $(document).keypress(function(e) {
      var terminal;
      if (e.which === 13) {
        terminal = $('#terminal');
        if (terminal.is(":focus")) {
          socket.emit('terminal', terminal.val());
          return terminal.val('');
        }
      }
    });
    return socket.on('terminal', function(message) {
      return result.append("<li>" + message + "</li>");
    });
  });

}).call(this);
