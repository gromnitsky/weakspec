fs = require 'fs'
path = require 'path'
assert = require 'assert'

drw = require '../lib/drawer'

suite 'Drawer', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
        
        eval fs.readFileSync('example/01.json', "ascii")
        @spec01 = weakspec

    test 'draw something into a string', ->
        d = new drw.Drawer @spec01
        html = d.draw()
        assert.ok html.length > 10
