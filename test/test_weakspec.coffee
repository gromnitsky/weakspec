fs = require 'fs'
path = require 'path'
assert = require 'assert'

ws = require '../lib/weakspec'

# opts--an array
check_bogusVal = (prefClass, opts, bogusVal, instructions) ->
    for idx in opts
        orig = if instructions[idx] != undefined then instructions[idx] else null
        instructions[idx] = bogusVal
        assert.throws ->
            (new prefClass 'foo', 'bar', instructions).validateSpec()
        , /invalid value/
        instructions[idx] = orig

# opts--an array
check_val = (prefClass, opts, val, instructions) ->
    for idx in opts
        orig = if instructions[idx] != undefined then instructions[idx] else null
        instructions[idx] = val
        assert.doesNotThrow ->
            (new prefClass 'foo', 'bar', instructions).validateSpec()
        instructions[idx] = orig

suite 'WeakSpec', ->
    setup ->
        process.chdir 'test' if path.basename(process.cwd()) != 'test'
#        @spec01 = JSON.parse fs.readFileSync('example/01.json', "ascii")
#        @ws01 = new ws.WeakSpec @spec01
        eval fs.readFileSync('example/01.json', "ascii")
        @spec01 = weakspec
        @ws01 = new ws.WeakSpec @spec01

        @min_string = {
            "type" : null,
            "desc" : "z",
            "default" : ""
        }
        @min_int = {
            "type" : null,
            "desc" : "zz",
            "default" : 42
        }
        @min_arrayofstr = {
            "type" : null,
            "desc" : "zzz",
            "default" : ['q', 'w', 'e']
        }
        @min_arrayofint = {
            "type" : null,
            "desc" : "zzzz",
            "default" : [1, 2, 3]
        }
        @min_bool = {
            "type" : null,
            "desc" : "zzzzz",
            "default" : true
        }

    test 'smoke test', ->
        assert.equal 4, @ws01.size()
        html = @ws01.toHtml()
        assert.ok html.length > 10

    test 'spec char* validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefStr 'foo', 'bar', @min_string).validateSpec()

        check_val ws.PrefStr, ['allowEmpty'], false, @min_string
        
    test 'spec char* validation fail', ->
        assert.throws ->
            (new ws.PrefStr 'foo', 'bar', {}).validateSpec()
        , /missing 'desc'/
        
        check_bogusVal ws.PrefStr, ['default'], [], @min_string
        check_bogusVal ws.PrefStr, ['cleanByRegexp', 'validationRegexp'], 1, @min_string
        check_bogusVal ws.PrefStr, ['allowEmpty'], undefined, @min_string

        @min_string.ooops = 1
        assert.throws =>
            (new ws.PrefStr 'foo', 'bar', @min_string).validateSpec()
        , /'ooops' is unknown/
        delete @min_string.ooops

    test 'spec int validaion ok', ->
        assert.doesNotThrow =>
            (new ws.PrefInt 'foo', 'bar', @min_int).validateSpec()

        check_val ws.PrefInt, ['range'], [10, 100], @min_int

    test 'spec int validation fail', ->
        check_bogusVal ws.PrefInt, ['default'], '', @min_int
        check_bogusVal ws.PrefInt, ['range'], 'whoa', @min_int
        check_bogusVal ws.PrefInt, ['range'], [null], @min_int
        check_bogusVal ws.PrefInt, ['range'], [0], @min_int
        check_bogusVal ws.PrefInt, ['range'], [0, 1, 2], @min_int
        check_bogusVal ws.PrefInt, ['range'], [0, -1], @min_int

    test 'spec char** validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefArrayOfStr 'foo', 'bar', @min_arrayofstr).validateSpec()

        check_val ws.PrefArrayOfStr, ['size'], [1, 2], @min_arrayofstr

    test 'spec char** validation fail', ->
        check_bogusVal ws.PrefArrayOfStr, ['default'], 'whoa', @min_arrayofstr
        check_bogusVal ws.PrefArrayOfStr, ['default'], ['whoa', 1], @min_arrayofstr

        check_bogusVal ws.PrefArrayOfStr, ['size'], 'whoa', @min_arrayofstr
        check_bogusVal ws.PrefArrayOfStr, ['size'], [1, null], @min_arrayofstr
        check_bogusVal ws.PrefArrayOfStr, ['size'], [-1, 1], @min_arrayofstr

        check_bogusVal ws.PrefArrayOfStr, ['cleanByRegexp', 'validationRegexp'], 1, @min_arrayofstr

    test 'spec int** validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefArrayOfInt 'foo', 'bar', @min_arrayofint).validateSpec()

        check_val ws.PrefArrayOfInt, ['range'], [-1, 2], @min_arrayofint
        check_val ws.PrefArrayOfInt, ['size'], [1, 2], @min_arrayofint

    test 'spec int** validation fail', ->
        check_bogusVal ws.PrefArrayOfInt, ['default'], 'whoa', @min_arrayofint
        check_bogusVal ws.PrefArrayOfInt, ['default'], ['whoa', 1], @min_arrayofint

        check_bogusVal ws.PrefArrayOfInt, ['range'], [1, 0], @min_arrayofint
        
        check_bogusVal ws.PrefArrayOfInt, ['size'], 'whoa', @min_arrayofint
        check_bogusVal ws.PrefArrayOfInt, ['size'], [1, null], @min_arrayofint
        check_bogusVal ws.PrefArrayOfInt, ['size'], [-1, 1], @min_arrayofint

    test 'spec bool validation ok', ->
        assert.doesNotThrow =>
            (new ws.PrefBool 'foo', 'bar', @min_bool).validateSpec()

        check_val ws.PrefBool, ['default'], false, @min_bool
        
    test 'spec bool validation fail', ->
        check_bogusVal ws.PrefBool, ['default'], 'whoa', @min_bool

    test 'char* validation', ->
        assert !@ws01.validate('Group 1', 'opt1', null)
        assert @ws01.validate('Group 1', 'opt1', 'zzz')

    test 'bool validation', ->
        assert !@ws01.validate('Group 5', 'opt1', 'whoa')
        assert @ws01.validate('Group 5', 'opt1', false)

