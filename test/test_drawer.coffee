fs = require 'fs'
path = require 'path'
assert = require 'assert'

drw = require '../lib/drawer'

suite 'Drawer', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
        
        eval fs.readFileSync('example/01.json', "ascii")
        @spec01 = weakspec
        
        @drw = new drw.Drawer @spec01

