assert = require 'assert'

es = require '../lib/extstorage'

suite 'ExtStorage', ->
    setup ->
        @es = new es.ExtStorage()
    
    test 'get nothing', ->
        assert.equal null, @es.get 'foo'
        assert.equal null, @es.get null
        assert.equal null, @es.get undefined
        assert.equal null, @es.get {}

    test 'set something & get it', ->
        @es.set 'Group 1', 'malware 1', ['z', 'x', 'c']
        assert ["Group 1"].join == (Object.keys @es.raw()).join # oh my
        assert.equal '{"malware 1":["z","x","c"]}', @es.raw()['Group 1']

        @es.set 'Group 1', 'malware 2', 2
        assert ["Group 1"].join == (Object.keys @es.raw()).join
        assert.equal '{"malware 1":["z","x","c"],"malware 2":2}', @es.raw()['Group 1']

        @es.set 'Group 2', 'foo', 'bar'
        assert ["Group 1", "Group 2"].join == (Object.keys @es.raw()).join
        assert.equal '{"foo":"bar"}', @es.raw()['Group 2']

        assert.equal 2, @es.size()
        
        assert.equal 2, @es.get('Group 1', 'malware 2')
        assert.equal null, @es.get('Group 1', 'bar')

#        console.log @es.raw
        @es.clean()
        assert.equal {}.toString(), @es.raw().toString()
