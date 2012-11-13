http = require 'http'
crypto = require 'crypto'
child = require 'child_process'

matrix_walk = require './matrix_walk'
worker = child.fork './worker' # used in cases of large matrices to reduce blocking

http.createServer((req, res) ->
  if req.method is 'POST'
    if req.headers['content-length'] < 1000
      # small matrix, send result
      req.on 'data', (data) ->
        data = matrix_walk.getMatrixMinWeight JSON.parse data.toString()
        res.end data.toString()
    else # large matrix, send to background worker
      id = crypto.createHash 'sha1'
      req.on 'data', (data) ->
        data = data.toString()
        id.update(data)
        id = id.digest('hex')
        worker.send [id, JSON.parse(data)]
      worker.on 'message', (message) ->
        if message[0] is id
          res.end message[1].toString()
).listen(3000)


