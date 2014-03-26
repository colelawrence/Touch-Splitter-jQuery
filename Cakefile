{spawn, exec} = require 'child_process'
build = (watch=false) ->
  filepath = './src/jquery.touchsplitter.coffee'
  coffee = spawn 'cmd', ["/c", "coffee", "-j", filepath.replace(/.coffee$/, ".js"), "-c"+(if watch then "w" else "")].concat [filepath]
  coffee.on 'error', (err) ->
    console.log 'coffee error', err
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  coffee.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'build', 'Build coffee',(options)->
  console.log "Building coffee-script from src/ to src/"
  build()

task 'watch', 'Watch coffee', ->
  console.log "Watching coffee-script from src/ to src/"
  build(true)