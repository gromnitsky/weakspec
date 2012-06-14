assert = require 'assert'
path = require 'path'

po = require '../for-extensions/populator'

suite 'ExtStorage', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
    
    test 'get something', ->
        @po = new po.WeakSpecPopulator("file://#{process.cwd()}/example/01.js")
        assert.equal 4, (Object.keys @po.spec).length
        assert.equal 4, (Object.keys @po.storage.raw()).length

        assert.equal '#ff7f27', @po.storage.get 'Group 5', 'opt2'
        
