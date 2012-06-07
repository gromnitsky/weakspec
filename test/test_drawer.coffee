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

    test 'draw something into a string', ->
        html = @drw.draw()
        assert.ok html.length > 10

    test 'uid2groupUid', ->
        assert.equal 'foo|bar|group', @drw.uid2groupUid 'foo|bar|z'
        assert.equal 'foo||group', @drw.uid2groupUid 'foo||'
        assert.equal null, @drw.uid2groupUid null
        assert.equal null, @drw.uid2groupUid ''
        assert.equal 'zzz||group', @drw.uid2groupUid 'zzz'
        