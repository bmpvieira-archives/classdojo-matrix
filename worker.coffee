matrix_walk = require './matrix_walk'

process.on 'message', (message) ->
  console.log 'Ready to work'
  id = message[0]
  result = matrix_walk.getMatrixMinWeight message[1]
  process.send [id, result]
