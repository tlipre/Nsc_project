(function() {
  var timeoutLoop;

  timeoutLoop = function(fn, reps, delay) {
    if (reps > 0) {
      return setTimeout((function() {
        fn();
        return timeoutLoop(fn, reps - 1, delay);
      }), 3000);
    }
  };

}).call(this);
