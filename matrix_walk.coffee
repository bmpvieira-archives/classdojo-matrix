module.exports =
  getPaths: (x, m, options) ->
    ###
    x: top start for paths discovery in matrix
    matrix: matrix array, like [[3, 1, 4], [1, 1, 12], [5, 0, 6]]
    options:
      fast: drop path as soon as weights_sum gets larger than previous paths
      all: return all weights_sum or just the minimum
      debug: log all directions and weights obtained
    ###

    fast = options.fast or false
    all = options.all or false
    debug = options.debug or false

    m_width = m[0].length-1
    m_heigth = m.length-1

    results = []
    directions_locked = {}
    directions_locked[step] = [] for step in [1..m_heigth]

    getRange = (x, step) =>
      # helper function to get current allowed range of x
      # range limits for x at current step
      range_start = x-step
      range_end = x+step
      # cap range if outside matrix
      range_start = 0 if range_start < 0
      range_end = m_width if range_end > m[step].length-1
      range = [range_start..range_end]
      return range

    recursive_lock = =>
      # helper function to push locks upstream when limits reached downstream
      for i in [0..step]
        if i is 0 # x is still bottom x
          recursion_current_x = current_x #
        else # adjust x for direction previously taken
          recursion_current_x = recursion_current_x - directions[step-i]
        range = getRange recursion_current_x, step-i
        if step-i isnt 1 # recursion hasn't reached top of matrix
          # if direction taken was last possible push lock upstream
          if directions[step-1-i] is 1 or recursion_current_x+directions[step-1-i] is range[range.length-1]
            directions_locked[step-1-i].push directions[step-2-i]
            directions_locked[step-i] = []
          else # otherwise, there are still directions available, just break
            break
        else # recursion reached first step
          # if new direction would fall outside range, then all directionss were obtained
          if recursion_current_x+directions[step-1-i] >= range[range.length-1]
            @morepaths = false
            break
          else # otherwise there are still combinations possible below
            break

    # Travel all paths and get min weight
    @morepaths = true
    while @morepaths
      directions = []
      weights_sum = m[0][x]
      weights = [m[0][x]] if debug
      # for each step of the matrix
      for step in [1..m_heigth]
        if step > 1
          current_x = current_x + directions[step-2] # -2: 1 prev direction, 1 first step in directions[0]
        else
          current_x = x
        direction_taken = null
        range = getRange current_x, step
        # try every possible direction
        for direction in [-1..1]
          if current_x+direction in range and direction not in directions_locked[step]
            direction_taken = direction
            break
        # save direction, weigth and sum
        directions.push direction_taken
        weight = m[step][current_x+direction_taken]
        weights_sum += weight
        weights.push weight if debug
        # if reached bottom of matrix, lock direction taken to avoid repetition
        if step is m_heigth
          directions_locked[step].push direction_taken
          # if direction taken was the last possible, push locks upstream recursively
          recursive_lock()
        # fast mode: bottom wasn't reached yet but weights > than prev, so lock this path
        else if fast and results.length > 0 and weights_sum > results[results.length-1]
          directions_locked[step].push direction_taken
          recursive_lock()
      if debug # prints aditional information
        path =
          directions: directions
          weights: weights
          weights_sum: weights_sum
        console.log path
      result = weights_sum
      results.push result
    if all
      results
    else
      # Math.min.apply(null, results) # this gives stack error for big arrays
      weight_min = results[0]
      for weight in results
        if weight < weight_min
          weight_min = weight
      weight_min

  getMatrixMinWeight: (matrix) ->
    minWeight = null
    for x in [0...matrix[0].length]
      weight = @getPaths x, matrix, {}
      minWeight = weight if not minWeight?
      if weight < minWeight
        minWeight = weight
    minWeight
