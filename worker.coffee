matrix_walk = require './matrix_walk'

process.on 'message', (message) ->
  id = message[0]
  data = matrix_walk.getMatrixMinWeight message[1]
  process.send [id, data]
