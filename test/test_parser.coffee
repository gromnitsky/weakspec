fs = require 'fs'
path = require 'path'
assert = require 'assert'

ws = require('../lib/parser.js')

suite 'WeakSpec', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
        this.spec01 = JSON.parse fs.readFileSync('example/01.json', "ascii")
        this.ws01 = new ws.WeakSpec this.spec01

    test 'size of a spec must be == 5', ->
        assert.equal 5, this.ws01.size()

    test 'char* validation', ->
        p = {
            "name" : "opt1",
            "desc" : "Options #1 in group #1",
            "help" : "A help string for an options #1",
            "type" : "char*",
            "default" : "ua",
            "cleanByRegexp" : null,
            "cleanCallback" : null,
            "validationRegexp" : "^[a-z]{2}$",
            "validationCallback" : null,
            "allowEmpty" : true
        }
        
        assert.throws ->
            (new ws.PrefStr 'foo', {}).validate()
        , /ws.GroupError: parser: group 'foo': missing 'name'/
        
        assert.throws ->
            (new ws.PrefStr 'foo', {"name" : null}).validate()
        , /group 'foo': invalid value in 'name'/
        
        assert.throws ->
            (new ws.PrefStr 'foo', {
                "type" : null,
                "name" : "option 1",
                "desc" : "zzz",
                "default" : []
            }).validate()
        , /invalid value in 'default'/
        
        min = {
            "type" : null,
            "name" : "option 1",
            "desc" : "zzz",
            "default" : ""
        }
        assert.doesNotThrow ->
            (new ws.PrefStr 'foo', min).validate()

        min.bar = 1
        assert.throws ->
            (new ws.PrefStr 'foo', min).validate()
        , /'bar' is unknown/
        delete min.bar

        min.cleanByRegexp = 1
        assert.throws ->
            (new ws.PrefStr 'foo', min).validate()
        , /invalid value in 'cleanByRegexp'/

        min.cleanByRegexp = null
        min.allowEmpty = undefined
        assert.throws ->
            (new ws.PrefStr 'foo', min).validate()
        , /invalid value in 'allowEmpty'/

        min.allowEmpty = false
        assert.doesNotThrow ->
            (new ws.PrefStr 'foo', min).validate()
                

        