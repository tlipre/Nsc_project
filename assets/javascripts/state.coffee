timeoutLoop = (fn, reps, delay) ->
  if reps > 0
    setTimeout (->
      fn()
      timeoutLoop(fn,reps-1,delay)
    ), 3000
