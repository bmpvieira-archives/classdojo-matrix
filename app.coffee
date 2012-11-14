http = require 'http'
crypto = require 'crypto'
child = require 'child_process'

# module that gets the Minimum Weight Path
matrix_walk = require './matrix_walk'
# used in cases of large matrices to reduce blocking
worker = child.fork './worker'
# value to avoid getting killed with posts bigger than memory
memory_limit = 256 * 1024 * 1024 # should be a lot smaller if to avoid processing forever
# body size max limit to fork process and avoid blocking thread
fork_threshold = 128
# to enable or disable logging
logging = true

port = process.argv[2] or process.env.PORT or 3000

http.createServer((req, res) ->
  req.setEncoding('utf8')
  if req.method is 'POST'
    body = ''
    body_size = 0
    req.on 'data', (chunk) ->
      body += chunk
      body_size += Buffer.byteLength chunk
      if body_size > memory_limit
        res.send 'Wow take it easy! You trying to kill me? Get a bigger server!'
    req.on 'end', ->
      try
        matrix = JSON.parse body
        if body_size < fork_threshold # Relatively small matrix, no need to fork
          result = matrix_walk.getMatrixMinWeight(matrix).toString()
          console.log "#{body} gave #{result}" if logging
          res.end result
        else # large matrix, send to background worker to reduce thread blocking
          id = crypto.createHash('sha1').update(body).digest("hex")
          worker.send [id, matrix]
          worker.on 'message', (message) ->
            if message[0] is id
              result = message[1].toString()
              console.log "#{body} gave #{result}" if logging
              res.end result
      catch error
        console.log "#{body} gave #{error}" if logging
        res.end 'Error: unable to process submitted data'
    req.on 'error', (err) ->
      console.log err
  else
    res.end()
).listen port
