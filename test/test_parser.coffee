fs = require 'fs'
path = require 'path'
assert = require 'assert'

ws = require('../lib/parser.js')

# opts--an array
check_bogusVal = (prefClass, opts, bogusVal, instructions) ->
    for idx in opts
        orig = if instructions[idx] != undefined then instructions[idx] else null
        instructions[idx] = bogusVal
        assert.throws ->
            (new prefClass 'foo', instructions).validate()
        , /invalid value/
        instructions[idx] = orig

# opts--an array
check_val = (prefClass, opts, val, instructions) ->
    for idx in opts
        orig = if instructions[idx] != undefined then instructions[idx] else null
        instructions[idx] = val
        assert.doesNotThrow ->
            (new prefClass 'foo', instructions).validate()
        instructions[idx] = orig

suite 'WeakSpec', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
        this.spec01 = JSON.parse fs.readFileSync('example/01.json', "ascii")
        this.ws01 = new ws.WeakSpec this.spec01

        this.min_string = {
            "type" : null,
            "name" : "option 1",
            "desc" : "z",
            "default" : ""
        }
        this.min_int = {
            "type" : null,
            "name" : "option 2",
            "desc" : "zz",
            "default" : 42
        }
        this.min_arrayofstr = {
            "type" : null,
            "name" : "option 3",
            "desc" : "zzz",
            "default" : ['q', 'w', 'e']
        }
        this.min_arrayofint = {
            "type" : null,
            "name" : "option 4",
            "desc" : "zzzz",
            "default" : [1, 2, 3]
        }
        this.min_bool = {
            "type" : null,
            "name" : "option 5",
            "desc" : "zzzzz",
            "default" : true
        }

    test 'size of a spec must be == 5', ->
        assert.equal 5, this.ws01.size()

    test 'char* validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefStr 'foo', this.min_string).validate()

        check_val ws.PrefStr, ['allowEmpty'], false, this.min_string
        
    test 'char* validation fail', ->
        assert.throws ->
            (new ws.PrefStr 'foo', {}).validate()
        , /GroupError: parser: group 'foo': missing 'name'/
        
        check_bogusVal ws.PrefStr, ['name'], null, {"name" : null}
        check_bogusVal ws.PrefStr, ['default'], [], this.min_string
        check_bogusVal ws.PrefStr, ['cleanByRegexp', 'validationRegexp'], 1, this.min_string
        check_bogusVal ws.PrefStr, ['allowEmpty'], undefined, this.min_string

        this.min_string.bar = 1
        assert.throws =>
            (new ws.PrefStr 'foo', this.min_string).validate()
        , /'bar' is unknown/
        delete this.min_string.bar

    test 'int validaion ok', ->
        assert.doesNotThrow =>
            (new ws.PrefInt 'foo', this.min_int).validate()

        check_val ws.PrefInt, ['range'], [10, 100], this.min_int

    test 'int validation fail', ->
        check_bogusVal ws.PrefInt, ['default'], '', this.min_int
        check_bogusVal ws.PrefInt, ['range'], 'whoa', this.min_int
        check_bogusVal ws.PrefInt, ['range'], [null], this.min_int
        check_bogusVal ws.PrefInt, ['range'], [0], this.min_int
        check_bogusVal ws.PrefInt, ['range'], [0, 1, 2], this.min_int
        check_bogusVal ws.PrefInt, ['range'], [0, -1], this.min_int

    test 'char** validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefArrayOfStr 'foo', this.min_arrayofstr).validate()

        check_val ws.PrefArrayOfStr, ['size'], [1, 2], this.min_arrayofstr

    test 'char** validation fail', ->
        check_bogusVal ws.PrefArrayOfStr, ['default'], 'whoa', this.min_arrayofstr
        check_bogusVal ws.PrefArrayOfStr, ['default'], ['whoa', 1], this.min_arrayofstr

        check_bogusVal ws.PrefArrayOfStr, ['size'], 'whoa', this.min_arrayofstr
        check_bogusVal ws.PrefArrayOfStr, ['size'], [1, null], this.min_arrayofstr
        check_bogusVal ws.PrefArrayOfStr, ['size'], [-1, 1], this.min_arrayofstr

        check_bogusVal ws.PrefArrayOfStr, ['cleanByRegexp', 'validationRegexp'], 1, this.min_arrayofstr

    test 'int** validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefArrayOfInt 'foo', this.min_arrayofint).validate()

        check_val ws.PrefArrayOfInt, ['range'], [-1, 2], this.min_arrayofint
        check_val ws.PrefArrayOfInt, ['size'], [1, 2], this.min_arrayofint

    test 'int** validation fail', ->
        check_bogusVal ws.PrefArrayOfInt, ['default'], 'whoa', this.min_arrayofint
        check_bogusVal ws.PrefArrayOfInt, ['default'], ['whoa', 1], this.min_arrayofint

        check_bogusVal ws.PrefArrayOfInt, ['range'], [1, 0], this.min_arrayofint
        
        check_bogusVal ws.PrefArrayOfInt, ['size'], 'whoa', this.min_arrayofint
        check_bogusVal ws.PrefArrayOfInt, ['size'], [1, null], this.min_arrayofint
        check_bogusVal ws.PrefArrayOfInt, ['size'], [-1, 1], this.min_arrayofint

    test 'bool validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefBool 'foo', this.min_bool).validate()

        check_val ws.PrefBool, ['default'], false, this.min_bool
        
    test 'bool validation fail', ->
        check_bogusVal ws.PrefBool, ['default'], 'whoa', this.min_bool
        